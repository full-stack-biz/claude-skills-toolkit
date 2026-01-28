#!/usr/bin/env ruby
require_relative '../skills/skill-tester/scripts/lib/spec_engine'
require_relative '../skills/skill-tester/scripts/lib/skill_runner'
require_relative '../skills/skill-tester/scripts/setup-test-env'

def run_test_case(name, skill_name, expected_result, test_type='full', runner: 'claude')
  puts "\n=== Meta-Test: #{name} (Runner: #{runner}) ==="
  
  source_dir = File.expand_path('.', File.absolute_path(File.join(File.dirname(__FILE__), '..')))
  
  # 1. Setup Environment
  setup = TestEnvSetup.new(skill_name, source_dir)
  # Capture stdout to silence setup logs
  original_stdout = $stdout
  $stdout = File.open(File::NULL, 'w')
  setup.run
  $stdout = original_stdout
  
  base_test_dir = "/tmp/skill-test/#{skill_name}"
  skill_path = File.join(base_test_dir, 'skill')
  skill_md = File.join(skill_path, 'SKILL.md')
  original_path = File.read(File.join(base_test_dir, 'original_path.txt')).strip
  
  # 2. Execution Phase
  if name != "Simulated Content Loss" # Don't run real skill for content loss simulation
    fixture_path = File.join(source_dir, 'tests', 'fixtures', skill_name)
    skill_runner = SkillRunner.new(skill_name, skill_path, fixture_path, runner: runner)
    
    # Silence runner output for meta-test unless it fails
    $stdout = File.open(File::NULL, 'w')
    runner_success = skill_runner.run
    $stdout = original_stdout
    
    puts "  -> SkillRunner executed."
  end
  
  # 2. Special Case: Simulate Content Loss
  if name == "Simulated Content Loss"
    puts "  -> Gutting skill file (keeping headers, removing body) to simulate data loss..."
    content = File.read(skill_md)
    # Keep headers but replace body with nothing
    gutted = content.gsub(/^[^#\n].*$/, "") 
    File.write(skill_md, gutted)
  end
  
  # 4. Configure Specs
  specs_dir = File.expand_path('../skills/skill-tester/specs', File.dirname(__FILE__))
  spec_map = {
    'gates-only' => ['preservation_gates_spec.rb'],
    'preservation-only' => ['content_preservation_spec.rb'],
    'full' => ['preservation_gates_spec.rb', 'workflow_compliance_spec.rb', 'content_preservation_spec.rb']
  }
  
  selected_specs = spec_map[test_type] || spec_map['full']
  spec_files = selected_specs.map { |f| File.join(specs_dir, f) }
  
  context_data = {
    'skill_name' => skill_name,
    'skill_path' => skill_path,
    'skill_md_path' => skill_md,
    'original_path' => original_path,
    'original_copy_path' => File.join(base_test_dir, 'original_copy')
  }
  
  # 5. Run Specs
  # Capture reporter
  reporter = SpecEngine.run(spec_files, context_data)
  
  # 6. Assert Results
  success = (reporter.stats[:failed] == 0)
  
  if success == expected_result
    verdict = success ? "Successfully validated" : "Correctly identified failures in"
    puts "✓ #{verdict} #{skill_name}"
  else
    puts "✗ FAILED META-ASSERTION: #{skill_name}"
    puts "   Expected success to be #{expected_result}, but got #{success}"
    reporter.print_summary
    exit 1
  end
end

# Define Test Cases
run_test_case("Valid Skill", "valid-skill", true)
run_test_case("Broken Gates", "broken-gate-skill", false, "full")
run_test_case("Simulated Content Loss", "content-loss-skill", false, "preservation-only")

puts "\n✓ Framework Validation Complete: All checks passed."
