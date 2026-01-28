# workflow_compliance_spec.rb

describe "Workflow Compliance" do
  # Detection Logic
  skip_all_if "Not a workflow skill (missing skill-workflow.md reference)" do
    content = File.read(skill_md_path)
    !(content.include?("skill-workflow.md") && content.include?("80%"))
  end

  before do
    @content = File.read(skill_md_path)
  end

  it "loads the unified workflow" do
    expect(@content).to include("skill-workflow.md")
  end

  it "runs gates (Step 1-3) before editing (Step 4)" do
    # Using a custom check logic inside the block
    gate_match = @content.match(/(GATE 1|GATE 2B|preservation.*gate)/)
    edit_match = @content.match(/(Make.*Approved Changes|^#### Step 4)/)
    
    expect(gate_match).to be_true
    expect(edit_match).to be_true
    
    gate_pos = @content.index(gate_match[0])
    edit_pos = @content.index(edit_match[0])
    
    if gate_pos >= edit_pos
      raise SpecEngine::ExpectationNotMetError, "Expected gates to appear before editing steps"
    end
  end

  it "applies the 80% rule language" do
    expect(@content).to match(/80%|Core.*Supplementary|core.*supplementary/)
  end

  it "requires explicit approval for deletions" do
    expect(@content).to match(/explicit.*approval|user.*approval|operator.*approval/)
  end

  it "documents validation phases" do
    expect(@content).to match(/Phase 1|Phase 2|Phase 3|File Inventory.*Read All.*Frontmatter/)
  end
end
