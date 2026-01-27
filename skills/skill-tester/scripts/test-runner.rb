#!/usr/bin/env ruby
# test-runner.rb - Pure Ruby test engine
# No bash, no subprocess hell, just clean Ruby

require 'yaml'
require 'pathname'
require 'open3'

class TestRunner
  PASS = '✓'
  FAIL = '✗'
  SKIP = '⊘'

  def initialize(skill_md, skill_path, original_path, suites_dir)
    @skill_md = skill_md
    @skill_path = skill_path
    @original_path = original_path
    @suites_dir = suites_dir
    @skill_content = File.read(skill_md)

    @passed = 0
    @failed = 0
    @skipped = 0
    @total = 0
  end

  def run_suites(suite_names)
    suite_names.each { |name| run_suite(name) }
  end

  def run_suite(name)
    suite_file = File.join(@suites_dir, "#{name}.yaml")
    return unless File.exist?(suite_file)

    suite = YAML.load_file(suite_file)
    return unless suite

    print_header(name)

    unless should_run_suite?(suite)
      skip_all_tests(suite)
      return
    end

    suite['tests']&.each { |test| run_test(test) }
    puts ""
  end

  def stats
    {
      total: @total,
      passed: @passed,
      failed: @failed,
      skipped: @skipped,
      applicable: @total - @skipped
    }
  end

  private

  def print_header(name)
    display = name.tr('-', ' ').upcase
    puts display
    puts display.gsub(/./, '=') + '========='
  end

  def should_run_suite?(suite)
    detection = suite['detection'] || {}
    logic = detection['logic'] || 'always'
    markers = detection['markers'] || []

    case logic
    when 'always'
      true
    when 'and'
      markers.all? { |m| @skill_content.match?(Regexp.new(m['pattern'])) }
    when 'or'
      markers.any? { |m| @skill_content.match?(Regexp.new(m['pattern'])) }
    else
      false
    end
  end

  def skip_all_tests(suite)
    suite['tests']&.each do |test|
      @total += 1
      @skipped += 1
      puts "#{SKIP} #{test['name']} (skipped - not applicable)"
    end
  end

  def run_test(test)
    @total += 1
    name = test['name']
    enabled = test.fetch('enabled', true)

    unless enabled
      @skipped += 1
      puts "#{SKIP} #{name} (skipped - disabled)"
      return
    end

    assertion = test['assertion']
    return unless assertion

    if check_assertion(assertion)
      @passed += 1
      puts "#{PASS} #{name}"
    else
      @failed += 1
      puts "#{FAIL} #{name} FAILED"
    end
  end

  def check_assertion(assertion)
    type = assertion['type']

    case type
    when 'grep'
      check_grep(assertion)
    when 'diff'
      check_diff(assertion)
    when 'custom'
      check_custom(assertion)
    else
      false
    end
  end

  def check_grep(assertion)
    pattern = assertion['pattern']
    target = expand_vars(assertion['target'])

    return false unless File.exist?(target)

    content = File.read(target)
    content.match?(Regexp.new(pattern))
  rescue
    false
  end

  def check_diff(assertion)
    files = assertion['files'] || []
    return false if files.length < 2

    file1 = expand_vars(files[0])
    file2 = expand_vars(files[1])

    return false unless File.exist?(file1) && File.exist?(file2)

    File.read(file1) == File.read(file2)
  rescue
    false
  end

  def check_custom(assertion)
    script = assertion['script']
    return false unless script

    # Create environment
    env = {
      'SKILL_MD' => @skill_md,
      'SKILL_PATH' => @skill_path,
      'ORIGINAL_PATH' => @original_path
    }

    # Execute with bash
    stdout, stderr, status = Open3.capture3(env, 'bash', '-c', script)
    status.success?
  rescue
    false
  end

  def expand_vars(str)
    return str unless str.is_a?(String)

    str
      .gsub('$SKILL_MD', @skill_md)
      .gsub('$SKILL_PATH', @skill_path)
      .gsub('$ORIGINAL_PATH', @original_path)
  end
end

# Main CLI
def main
  skill_name = ARGV[0]
  test_type = ARGV[1] || 'full'
  skill_md = ARGV[2]
  skill_path = ARGV[3]
  original_path = ARGV[4]
  suites_dir = ARGV[5]

  runner = TestRunner.new(skill_md, skill_path, original_path, suites_dir)

  suites = case test_type
           when 'gates-only', '--gates-only'
             ['preservation-gates']
           when 'workflow-only', '--workflow-only'
             ['workflow-compliance']
           when 'preservation-only', '--preservation-only'
             ['content-preservation']
           when 'full', '--full'
             ['preservation-gates', 'workflow-compliance', 'content-preservation']
           else
             [test_type]
           end

  runner.run_suites(suites)

  stats = runner.stats
  puts "TEST SUMMARY"
  puts "============"
  puts "Total Tests: #{stats[:total]}"
  puts "Passed: #{stats[:passed]}"
  puts "Failed: #{stats[:failed]}"
  puts "Skipped: #{stats[:skipped]}"

  if stats[:applicable] > 0
    puts "Applicable: #{stats[:applicable]} (skipped #{stats[:skipped]})"
  end

  if stats[:failed] == 0
    puts ""
    puts "✓ ALL TESTS PASSED"
    exit 0
  else
    puts ""
    puts "✗ SOME TESTS FAILED"
    exit 1
  end
end

main if __FILE__ == $0
