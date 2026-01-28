# preservation_gates_spec.rb

describe "Preservation Gates" do
  # Detection Logic
  skip_all_if "Not a gated skill (missing GATE 2B / NON-DELETABLE)" do
    content = File.read(skill_md_path)
    !(content.include?("GATE 2B") && content.include?("NON-DELETABLE"))
  end

  before do
    @content = File.read(skill_md_path)
  end

  it "documents the GATE 2B non-deletable list" do
    expect(@content).to match(/GATE 2B.*NON-DELETABLE|NON-DELETABLE.*GATE 2B/)
  end

  it "documents absolute refusal rules" do
    expect(@content).to match(/REFUSE IMMEDIATELY|ABSOLUTE REFUSAL/)
  end

  it "enforces gate checkpoints" do
    expect(@content).to match(/DO NOT PROCEED.*UNTIL|UNTIL ALL GATES/)
  end

  it "documents self-protection for GATE 2B" do
    expect(@content).to match(/self-protecting|GATE 2B.*itself|This.*rule.*itself/)
  end
end
