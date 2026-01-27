#!/usr/bin/env ruby
# test-engine.rb - Generic skill test engine
# Loads test suites from YAML and executes assertions

require 'yaml'
require 'pathname'
require 'shellwords'

class TestEngine
  SYMBOLS = {
    pass: '✓',
    fail: '✗',
    skip: '⊘'
  }

  attr_reader :pass_count, :fail_count, :skip_count, :total_count

  def initialize(skill_md_path, skill_path, original_path, suites_dir)
    @skill_md = skill_md_path
    @skill_path = skill_path
    @original_path = original_path
    @suites_dir = suites_dir
    @skill_md_content = File.read(@skill_md) rescue ''

    @pass_count = 0
    @fail_count = 0
    @skip_count = 0
    @total_count = 0
  end

  def run_suite(suite_name)
    suite_file = File.join(@suites_dir, "#{suite_name}.yaml")
    return false unless File.exist?(suite_file)

    suite = YAML.load_file(suite_file)
    return false unless suite

    # Check if suite should run
    unless should_run_suite?(suite)
      skip_all_tests(suite)
      return true
    end

    # Print suite header
    display_name = suite_name.tr('-', ' ').upcase
    puts "#{display_name} TESTS"
    puts display_name.gsub(/./, '=') + '========='

    # Run each test
    suite['tests']&.each do |test|
      run_test(test)
    end

    puts ""
    true
  end

  private

  def should_run_suite?(suite)
    detection = suite['detection'] || {}
    logic = detection['logic'] || 'always'

    case logic
    when 'always'
      true
    when 'and'
      # All markers must be present
      markers = detection['markers'] || []
      markers.all? { |m| marker_matches?(m['pattern']) }
    when 'or'
      # Any marker must be present
      markers = detection['markers'] || []
      markers.any? { |m| marker_matches?(m['pattern']) }
    else
      false
    end
  end

  def marker_matches?(pattern)
    @skill_md_content.match?(Regexp.new(pattern))
  end

  def skip_all_tests(suite)
    suite['tests']&.each do |test|
      @total_count += 1
      @skip_count += 1
      puts "#{SYMBOLS[:skip]} #{test['name']} (skipped - not applicable)"
    end
  end

  def run_test(test)
    @total_count += 1
    name = test['name']
    enabled = test.fetch('enabled', true)

    unless enabled
      @skip_count += 1
      puts "#{SYMBOLS[:skip]} #{name} (skipped - disabled)"
      return
    end

    assertion = test['assertion']
    return unless assertion

    if run_assertion(assertion)
      @pass_count += 1
      puts "#{SYMBOLS[:pass]} #{name}"
    else
      @fail_count += 1
      puts "#{SYMBOLS[:fail]} #{name} FAILED"
    end
  end

  def run_assertion(assertion)
    type = assertion['type']

    case type
    when 'grep'
      run_grep_assertion(assertion)
    when 'diff'
      run_diff_assertion(assertion)
    when 'custom'
      run_custom_assertion(assertion)
    else
      false
    end
  end

  def run_grep_assertion(assertion)
    pattern = assertion['pattern']
    target = expand_vars(assertion['target'])

    return false unless File.exist?(target)

    content = File.read(target)
    content.match?(Regexp.new(pattern))
  rescue
    false
  end

  def run_diff_assertion(assertion)
    files = assertion['files'] || []
    return false if files.length < 2

    file1 = expand_vars(files[0])
    file2 = expand_vars(files[1])

    return false unless File.exist?(file1) && File.exist?(file2)

    File.read(file1) == File.read(file2)
  rescue
    false
  end

  def run_custom_assertion(assertion)
    check_type = assertion['check_type']
    return false unless check_type

    case check_type
    when 'line_order'
      # Check if first_pattern appears before second_pattern in file
      file = expand_vars(assertion['file'] || '$SKILL_MD')
      first_pattern = assertion['first_pattern']
      second_pattern = assertion['second_pattern']

      content = File.read(file)
      first_match = content.match(Regexp.new(first_pattern))
      second_match = content.match(Regexp.new(second_pattern))

      first_match && second_match && content.index(first_match[0]) < content.index(second_match[0])

    when 'line_count'
      # Check if file line count meets criteria
      file = expand_vars(assertion['file'])
      original_file = expand_vars(assertion['original_file'])
      threshold = assertion['threshold'] || 5  # Allow up to 5% variance

      current_lines = File.readlines(file).count
      original_lines = File.readlines(original_file).count

      current_lines >= (original_lines - threshold)

    when 'file_exists'
      # Check if file exists
      file = expand_vars(assertion['file'])
      File.exist?(file)

    when 'has_directory'
      # Check if directory exists
      dir = expand_vars(assertion['directory'])
      File.directory?(dir)

    else
      false
    end
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

if __FILE__ == $0
  # CLI usage
  skill_name = ARGV[0]
  test_type = ARGV[1] || 'full'
  skill_md = ARGV[2]
  skill_path = ARGV[3]
  original_path = ARGV[4]
  suites_dir = ARGV[5]

  engine = TestEngine.new(skill_md, skill_path, original_path, suites_dir)

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

  if engine.fail_count == 0
    puts ""
    puts "✓ ALL TESTS PASSED"
    exit 0
  else
    puts ""
    puts "✗ SOME TESTS FAILED"
    exit 1
  end
end
