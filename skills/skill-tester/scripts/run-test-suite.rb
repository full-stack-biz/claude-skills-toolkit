#!/usr/bin/env ruby
# run-test-suite.rb - Main test runner for skill testing
# Usage: ruby run-test-suite.rb SKILL_NAME [TEST_TYPE] [--report] [SOURCE_DIR]

require_relative 'lib/spec_engine'
require_relative 'lib/skill_runner'
require_relative 'setup-test-env'
require_relative 'generate-test-report'
require 'stringio'

class TestRunner
  def initialize(skill_name, test_type = 'full', report_flag = nil, source_dir = '.', runner: 'claude')
    @skill_name = skill_name
    @test_type = test_type
    @generate_report = report_flag == '--report'
    @source_dir = source_dir
    @runner = runner || 'claude'
  end

  def run
    # Setup test environment
    puts "Setting up test environment..."
    setup = TestEnvSetup.new(@skill_name, @source_dir)

    # Capture output to get skill path
    old_stdout = $stdout
    $stdout = StringIO.new
    setup.run
    output = $stdout.string
    $stdout = old_stdout

    # Print setup output and extract paths
    puts output
    skill_path = output.lines.last.strip
    base_test_dir = File.dirname(skill_path)

    skill_md = File.join(skill_path, 'SKILL.md')
    original_path = File.read(File.join(base_test_dir, 'original_path.txt')).strip rescue skill_path
    original_copy_path = File.join(base_test_dir, 'original_copy')

    puts ""
    puts "=== Testing: #{@skill_name} ==="
    puts "Test Type: #{@test_type}"
    puts "Runner: #{@runner}"
    puts "Skill Path: #{skill_path}"
    puts ""

    # 1. Run the skill execution phase
    # We find the fixture path relative to the source dir
    fixture_path = File.join(@source_dir, 'tests', 'fixtures', @skill_name)
    runner = SkillRunner.new(@skill_name, skill_path, fixture_path, runner: @runner)
    runner.run

    # 2. Determine which specs to run
    script_dir = File.dirname(__FILE__)
    specs_dir = File.expand_path('../specs', script_dir)
    
    spec_map = {
      'gates-only' => ['preservation_gates_spec.rb'],
      'workflow-only' => ['workflow_compliance_spec.rb'],
      'preservation-only' => ['content_preservation_spec.rb'],
      'full' => ['preservation_gates_spec.rb', 'workflow_compliance_spec.rb', 'content_preservation_spec.rb']
    }
    
    # Handle aliases
    type_key = @test_type.sub(/^--/, '')
    selected_specs = spec_map[type_key] || spec_map['full']
    
    spec_files = selected_specs.map { |f| File.join(specs_dir, f) }

    # Context data exposed to specs
    context_data = {
      'skill_name' => @skill_name,
      'skill_path' => skill_path,
      'skill_md_path' => skill_md,
      'original_path' => original_path,
      'original_copy_path' => original_copy_path
    }

    # Run the specs
    reporter = SpecEngine.run(spec_files, context_data)
    reporter.print_summary
    stats = reporter.stats

    # Generate report if requested
    if @generate_report
      puts ""
      puts "Generating test report..."
      generator = TestReportGenerator.new(
        base_test_dir,
        @skill_name,
        @test_type,
        stats[:passed],
        stats[:total],
        stats[:skipped]
      )
      generator.generate
    end

    # Print final status
    if stats[:failed] == 0
      puts ""
      puts "✓ ALL TESTS PASSED"
      puts "✓ Test environment preserved at: #{base_test_dir}" unless @generate_report
      exit 0
    else
      puts ""
      puts "✗ SOME TESTS FAILED"
      puts "Test directory: #{base_test_dir}"
      exit 1
    end
  end
end

if __FILE__ == $0
  skill_name = ARGV[0]
  test_type = 'full'
  report_flag = nil
  source_dir = '.'
  runner_type = 'claude'

  # Simple argument parsing
  ARGV[1..].each do |arg|
    if arg.start_with?('--runner=')
      runner_type = arg.split('=')[1]
    elsif arg == '--report'
      report_flag = '--report'
    elsif ['full', 'gates-only', 'workflow-only', 'preservation-only'].include?(arg.sub(/^--/, ''))
      test_type = arg
    else
      # If it's not a known flag, assume it's the source dir (legacy behavior)
      source_dir = arg unless arg.start_with?('-')
    end
  end

  if skill_name.nil? || skill_name.empty?
    STDERR.puts "Error: Usage: ruby run-test-suite.rb SKILL_NAME [TEST_TYPE] [--report] [--runner=claude|gemini] [SOURCE_DIR]"
    exit 1
  end

  runner = TestRunner.new(skill_name, test_type, report_flag, source_dir, runner: runner_type)
  runner.run
end