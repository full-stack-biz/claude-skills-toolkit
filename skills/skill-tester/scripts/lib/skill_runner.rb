# skill_runner.rb - Executes a skill against a fixture
require 'open3'
require 'yaml'

class SkillRunner
  def initialize(skill_name, skill_path, fixture_path, runner: 'claude')
    @skill_name = skill_name
    @skill_path = skill_path
    @fixture_path = fixture_path
    @runner = runner || 'claude'
    
    # Map runner type to CLI command
    @runner_cmd = case @runner.downcase
                  when 'gemini' then 'gemini'
                  else 'claude'
                  end
  end

  def run
    # 1. Read the task prompt from the fixture
    task_file = File.join(@fixture_path, 'task.txt')
    unless File.exist?(task_file)
      puts "  ! No task.txt found in fixture, skipping execution phase."
      return true
    end
    
    task_prompt = File.read(task_file).strip

    # 2. Parse allowed-tools from SKILL.md frontmatter
    skill_md = File.join(@skill_path, 'SKILL.md')
    allowed_tools_str = ""
    if File.exist?(skill_md)
      begin
        content = File.read(skill_md)
        if content =~ /\A---(.*?)---/m
          frontmatter = YAML.safe_load($1)
          if frontmatter && frontmatter['allowed-tools']
            tools = frontmatter['allowed-tools']
            allowed_tools_str = tools.is_a?(Array) ? tools.join(',') : tools.to_s.strip
          end
        end
      rescue => e
        puts "  ! Warning: Failed to parse frontmatter for tools: #{e.message}"
      end
    end
    
    # 3. Check if command exists
    unless system("command -v #{@runner_cmd} >/dev/null 2>&1")
      puts "  ! Command '#{@runner_cmd}' not found. Skipping actual execution (Mock mode)."
      return true
    end

    full_prompt = "Using the skill at '#{@skill_path}', please perform the following task on the files in the current directory: #{task_prompt}"
    
    puts "  -> Executing skill: #{@skill_name} with #{@runner}"
    
    # 4. Prepare arguments for safe execution
    if @runner.downcase == 'gemini'
      # Gemini style: positional prompt first, then kebab-case --allowed-tools
      args = [@runner_cmd, full_prompt]
      args << "--allowed-tools" << allowed_tools_str unless allowed_tools_str.empty?
    else
      # Claude style: -p [prompt] --allowedTools (camelCase)
      args = [@runner_cmd, "-p", full_prompt]
      args << "--allowedTools" << allowed_tools_str unless allowed_tools_str.empty?
    end
    
    # Custom log formatting for transparency
    log_cmd = @runner.downcase == 'gemini' ? 
      "#{@runner_cmd} \"#{full_prompt}\" --allowed-tools \"#{allowed_tools_str}\"" :
      "#{@runner_cmd} -p \"#{full_prompt}\" --allowedTools \"#{allowed_tools_str}\""
    puts "  -> Command: #{log_cmd}"
    
    success = false
    Dir.chdir(@skill_path) do
      # Run the command with array to avoid shell issues
      stdout, stderr, status = Open3.capture3(*args)
      
      if status.success?
        puts "  ✓ Skill execution completed."
        success = true
      else
        puts "  ✗ Skill execution failed (Exit code: #{status.exitstatus})"
        # If there's no stderr but there is stdout, maybe it's there
        puts "     Error: #{stderr.empty? ? stdout : stderr}"
        success = false
      end
    end
    
    success
  end
end
