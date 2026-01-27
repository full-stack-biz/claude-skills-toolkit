#!/usr/bin/env ruby
# run-test-suite.rb - Main test runner for skill testing
# Usage: ruby run-test-suite.rb SKILL_NAME [TEST_TYPE] [--report] [SOURCE_DIR]

require_relative 'lib/test-engine'
require_relative 'setup-test-env'
require_relative 'generate-test-report'

class TestRunner
  def initialize(skill_name, test_type = 'full', report_flag = nil, source_dir = '.')
    @skill_name = skill_name
    @test_type = test_type
    @generate_report = report_flag == '--report'
    @source_dir = source_dir
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

    puts ""
    puts "=== Testing: #{@skill_name} ==="
    puts "Test Type: #{@test_type}"
    puts "Skill Path: #{skill_path}"
    puts ""

    # Get suites directory
    script_dir = File.dirname(__FILE__)
    suites_dir = File.expand_path('../suites', script_dir)

    # Run test engine
    engine = TestEngine.new(skill_md, skill_path, original_path, suites_dir)

    suites = case @test_type
             when 'gates-only', '--gates-only'
               ['preservation-gates']
             when 'workflow-only', '--workflow-only'
               ['workflow-compliance']
             when 'preservation-only', '--preservation-only'
               ['content-preservation']
             when 'full', '--full'
               ['preservation-gates', 'workflow-compliance', 'content-preservation']
             else
               [@test_type]
             end

    suites.each { |suite| engine.run_suite(suite) }

    puts "TEST SUMMARY"
    puts "============"
    puts "Total Tests: #{engine.total_count}"
    puts "Passed: #{engine.pass_count}"
    puts "Failed: #{engine.fail_count}"
    puts "Skipped: #{engine.skip_count}"

    if engine.total_count > engine.skip_count
      puts "Applicable: #{engine.total_count - engine.skip_count} (skipped #{engine.skip_count})"
    end

    # Generate report if requested
    if @generate_report
      puts ""
      puts "Generating test report..."
      generator = TestReportGenerator.new(
        base_test_dir,
        @skill_name,
        @test_type,
        engine.pass_count,
        engine.total_count,
        engine.skip_count
      )
      generator.generate
    end

    # Print final status
    if engine.fail_count == 0
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
  require 'stringio'

  skill_name = ARGV[0]
  test_type = ARGV[1] || 'full'
  report_flag = ARGV[2]
  source_dir = ARGV[3] || '.'

  if skill_name.nil? || skill_name.empty?
    STDERR.puts "Error: Usage: ruby run-test-suite.rb SKILL_NAME [TEST_TYPE] [--report] [SOURCE_DIR]"
    exit 1
  end

  runner = TestRunner.new(skill_name, test_type, report_flag, source_dir)
  runner.run
end
