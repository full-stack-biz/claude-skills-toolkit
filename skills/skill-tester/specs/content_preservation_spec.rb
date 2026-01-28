# content_preservation_spec.rb

describe "Content Preservation" do
  # Always runs to ensure skill integrity
  
  it "has no unauthorized deletions (diff clean)" do
    # Verify that the skill hasn't had content removed compared to the original
    # We use 'diff -u' to check if lines were removed
    # Note: additions are usually fine (refinement), but deletions require approval
    
    # We check if 'diff' shows any removed lines (starting with '-')
    diff_output = `diff -u '#{original_copy_path}/SKILL.md' '#{skill_path}/SKILL.md'`
    removed_lines = diff_output.lines.select { |l| l.start_with?('-') && !l.start_with?('---') }
    
    unless removed_lines.empty?
      raise SpecEngine::ExpectationNotMetError, "Unauthorized deletions detected:\n#{removed_lines.first(5).join}..."
    end
  end

  it "preserves mandatory architectural sections (80% rule)" do
    # According to the 80% rule, core procedural content must stay in SKILL.md.
    # We "pin" the essential sections that must exist for any valid toolkit skill.
    content = File.read("#{skill_path}/SKILL.md")
    
    expect(content).to match(/#.*Quick Start|##.*Quick Start/i)
    expect(content).to match(/##.*When to Use/i)
    expect(content).to match(/##.*Workflow|##.*Implementation/i)
  end

  it "keeps reference links intact" do
    # Ensure references/ directory paths are still linked and not orphaned
    content = File.read("#{skill_path}/SKILL.md")
    expect(content).to include("references/")
  end

  it "maintains markdown structural integrity" do
    # Ensure the document still follows a hierarchical heading structure
    content = File.read("#{skill_path}/SKILL.md")
    expect(content).to match(/^# /)
    expect(content).to match(/^## /)
  end
end