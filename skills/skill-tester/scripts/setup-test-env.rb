#!/usr/bin/env ruby
# setup-test-env.rb - Create isolated test environment for skill testing
# Usage: ruby setup-test-env.rb SKILL_NAME [SOURCE_DIR]

require 'fileutils'
require 'pathname'

class TestEnvSetup
  TEST_BASE = '/tmp/skill-test'

  def initialize(skill_name, source_dir = '.')
    @skill_name = skill_name
    @source_dir = File.expand_path(source_dir)
    @test_dir = File.join(TEST_BASE, @skill_name)
  end

  def run
    skill_path = find_skill(@skill_name)

    unless skill_path
      STDERR.puts "Error: Skill not found: #{@skill_name}"
      STDERR.puts "Searched: #{@source_dir}/skills/#{@skill_name}, #{@source_dir}/.claude/skills/#{@skill_name}"
      exit 1
    end

    puts "Setting up test environment for: #{@skill_name}"
    puts "Source: #{skill_path}"

    # Create test directory (clean if exists)
    FileUtils.rm_rf(@test_dir) if File.exist?(@test_dir)
    FileUtils.mkdir_p(@test_dir)

    # Copy skill to test directory as isolated copy
    skill_dest = File.join(@test_dir, 'skill')
    FileUtils.cp_r(skill_path, skill_dest)

    # Create a static copy for comparison (so we don't depend on source dir not changing)
    original_copy = File.join(@test_dir, 'original_copy')
    FileUtils.cp_r(skill_path, original_copy)

    # Store original path for metadata
    File.write(File.join(@test_dir, 'original_path.txt'), skill_path)

    puts "✓ Test environment created at: #{@test_dir}"
    puts "✓ Skill copied to: #{skill_dest}"
    puts "✓ Static original copy: #{original_copy}"
    puts "✓ Original at: #{skill_path}"

    # Output skill path for use by other scripts (last line)
    puts skill_dest
  end

  private

  def find_skill(name)
    # Search project paths
    candidates = [
      File.join(@source_dir, 'skills', name),
      File.join(@source_dir, 'tests', 'fixtures', name),
      File.join(@source_dir, '.claude', 'skills', name),
      File.join(Dir.home, '.claude', 'skills', name)
    ]

    candidates.find { |path| File.directory?(path) }
  end
end

if __FILE__ == $0
  skill_name = ARGV[0]
  source_dir = ARGV[1] || '.'

  if skill_name.nil? || skill_name.empty?
    STDERR.puts "Error: Usage: ruby setup-test-env.rb SKILL_NAME [SOURCE_DIR]"
    exit 1
  end

  setup = TestEnvSetup.new(skill_name, source_dir)
  setup.run
end
