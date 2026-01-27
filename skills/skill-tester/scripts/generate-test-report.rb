#!/usr/bin/env ruby
# generate-test-report.rb - Generate markdown test report
# Usage: ruby generate-test-report.rb TEST_DIR SKILL_NAME TEST_TYPE PASSED TOTAL SKIPPED

require 'time'

class TestReportGenerator
  def initialize(test_dir, skill_name, test_type, passed, total, skipped)
    @test_dir = test_dir
    @skill_name = skill_name
    @test_type = test_type
    @passed = passed.to_i
    @total = total.to_i
    @skipped = skipped.to_i

    @skill_path = File.join(@test_dir, 'skill')
    @skill_md = File.join(@skill_path, 'SKILL.md')
    @report_path = File.join(@test_dir, 'TEST_REPORT.md')
    @original_path = File.read(File.join(@test_dir, 'original_path.txt')).strip rescue @skill_path
  end

  def generate
    effective_total = @total - @skipped
    failed = effective_total - @passed
    percentage = effective_total > 0 ? (@passed * 100 / effective_total) : 0

    report = []
    report << "# Test Report: #{@skill_name}"
    report << ""
    report << "**Test Date:** #{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S UTC')}"
    report << "**Test Type:** #{@test_type}"
    report << "**Test Directory:** #{@test_dir}"
    report << ""
    report << "## Test Environment"
    report << ""
    report << "- **Skill:** #{@skill_name}"
    report << "- **Source:** #{@original_path}"
    report << "- **Test Copy:** #{@skill_path}"
    report << "- **Method:** Isolated structural verification (read-only)"
    report << ""
    report << "## Summary"
    report << ""
    report << "| Metric | Result |"
    report << "|--------|--------|"
    report << "| **Total Tests** | #{@total} |"

    skipped_text = @skipped > 0 ? " (skipped #{@skipped})" : ""
    report << "| **Applicable** | #{effective_total}#{skipped_text} |"
    report << "| **Passed** | #{@passed} |"
    report << "| **Failed** | #{failed} |"
    report << "| **Pass Rate** | #{percentage}% |"

    status = failed == 0 ? "✓ APPROVED FOR DEPLOYMENT" : "✗ NEEDS FIXES"
    report << "| **Status** | #{status} |"
    report << ""

    # Add detailed test results if available
    test_log = File.join(@test_dir, 'test-log.txt')
    if File.exist?(test_log)
      report << "## Detailed Test Results"
      report << ""
      report << "```"
      report << File.read(test_log)
      report << "```"
      report << ""
    end

    # Add skill metrics
    report << "## Skill Metrics"
    report << ""
    report << "| Metric | Value |"
    report << "|--------|-------|"

    if File.exist?(@skill_md)
      content = File.read(@skill_md)
      report << "| **Line Count** | #{content.lines.count} |"
      report << "| **Sections** | #{content.scan(/^##/).count} |"
      report << "| **Code Blocks** | #{content.scan(/^```/).count} |"
      report << "| **References** | #{content.scan(/references\//).count} |"
      report << "| **Checklists** | #{content.scan(/^- \[ \]/).count} |"
    end
    report << ""

    # Add recommendations
    report << "## Recommendations"
    report << ""

    if failed == 0
      report << "✓ All tests passed. Ready for deployment."
      report << ""
      report << "### Next Steps:"
      report << "1. Review test report above"
      report << "2. Deploy skill to production"
      report << "3. Monitor for edge cases in real-world usage"
      report << "4. Update team documentation if needed"
      report << ""
    else
      report << "✗ #{failed} test(s) failed. Review findings below and address issues."
      report << ""
      report << "### Issues Found:"

      if File.exist?(test_log)
        File.readlines(test_log).each do |line|
          report << "- #{line.strip}" if line.include?('✗')
        end
      end

      report << ""
      report << "### Recommended Actions:"
      report << "1. Review failed test output above"
      report << "2. Fix skill structure/content as indicated"
      report << "3. Re-run tests to verify fixes"
      report << "4. Approve for deployment once all tests pass"
      report << ""
    end

    # Add file comparison if different
    original_md = File.join(@original_path, 'SKILL.md')
    if File.exist?(@skill_md) && File.exist?(original_md)
      unless FileUtils.identical?(@skill_md, original_md)
        report << "## File Comparison"
        report << ""
        report << "⚠️ Differences detected. Review changes below:"
        report << ""

        # Generate simple diff (first 50 lines)
        diff_lines = `diff -u '#{original_md}' '#{@skill_md}' 2>/dev/null | head -50`.lines
        report.concat(diff_lines.map(&:chomp)) unless diff_lines.empty?

        report << ""
        report << "(Showing first 50 lines of diff; full diff available in test directory)"
        report << ""
      end
    end

    # Footer
    report << "---"
    report << ""
    report << "**Report Generated:** #{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S UTC')}"
    report << "**Test Framework:** skill-tester v2.0.0"
    report << "**Status:** #{failed == 0 ? 'APPROVED ✓' : 'NEEDS REVIEW ✗'}"

    # Write report
    File.write(@report_path, report.join("\n"))

    puts "✓ Test report generated: #{@report_path}"
    puts ""
    puts File.read(@report_path)
  end
end

if __FILE__ == $0
  if ARGV.length < 6
    STDERR.puts "Error: Usage: ruby generate-test-report.rb TEST_DIR SKILL_NAME TEST_TYPE PASSED TOTAL SKIPPED"
    exit 1
  end

  test_dir = ARGV[0]
  skill_name = ARGV[1]
  test_type = ARGV[2] || 'full'
  passed = ARGV[3] || '0'
  total = ARGV[4] || '0'
  skipped = ARGV[5] || '0'

  generator = TestReportGenerator.new(test_dir, skill_name, test_type, passed, total, skipped)
  generator.generate
end
