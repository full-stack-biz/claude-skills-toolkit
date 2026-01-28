# spec_engine.rb - A lightweight RSpec-like testing framework
# Implements describe, context, it, expect, and matchers

module SpecEngine
  # --- Core Domain Specific Language ---

  class World
    attr_reader :example_groups

    def initialize
      @example_groups = []
    end

    def describe(description, &block)
      group = ExampleGroup.new(description, nil, &block)
      @example_groups << group
      group
    end
  end

  # Represents a 'describe' or 'context' block
  class ExampleGroup
    attr_reader :description, :children, :examples, :parent, :hooks

    def initialize(description, parent = nil, &block)
      @description = description
      @parent = parent
      @children = []
      @examples = []
      @hooks = { before: [], after: [] }
      
      # Evaluate the block in the context of this group
      instance_eval(&block) if block_given?
    end

    def describe(description, &block)
      child = ExampleGroup.new(description, self, &block)
      @children << child
      child
    end
    alias_method :context, :describe

    def it(description, &block)
      example = Example.new(description, self, &block)
      @examples << example
      example
    end

    def before(&block)
      @hooks[:before] << block
    end

    def after(&block)
      @hooks[:after] << block
    end

    # Helper to skip the entire group based on a condition
    def skip_all_if(reason = "Skipped", &block)
      @skip_condition = block
      @skip_reason = reason
    end

    def should_skip?(context_data)
      return [false, nil] unless @skip_condition
      
      # Execute condition in a context with data access
      context = ExecutionContext.new(context_data)
      should_skip = context.instance_exec(&@skip_condition)
      
      [should_skip, @skip_reason]
    end
    
    # Run the group and its children
    def run(reporter, context_data = {})
      skip, reason = should_skip?(context_data)
      
      if skip
        reporter.group_skipped(self, reason)
        return
      end

      reporter.group_started(self)

      # Run examples in this group
      @examples.each do |example|
        example.run(reporter, context_data, @hooks)
      end

      # Run child groups
      @children.each do |child|
        child.run(reporter, context_data)
      end
      
      reporter.group_finished(self)
    end

    def full_description
      return @description unless @parent
      "#{@parent.full_description} #{@description}"
    end
  end

  # Represents a single 'it' block
  class Example
    attr_reader :description, :parent

    def initialize(description, parent, &block)
      @description = description
      @parent = parent
      @block = block
    end

    def run(reporter, context_data, hooks)
      # Create an execution context (the 'self' inside the it block)
      context = ExecutionContext.new(context_data)
      
      begin
        # Run before hooks (from parent up to root? No, usually root down)
        # For simplicity, we just run current group hooks here. 
        # Ideally, we'd walk the tree.
        hooks[:before].each { |h| context.instance_eval(&h) }

        # Run the test
        context.instance_eval(&@block)
        
        reporter.example_passed(self)
      rescue ExpectationNotMetError => e
        reporter.example_failed(self, e)
      rescue SkipSignal => e
        reporter.example_skipped(self, e.message)
      rescue StandardError => e
        reporter.example_failed(self, e)
      end
    end

    def full_description
      "#{@parent.full_description} #{@description}"
    end
  end

  # --- Matchers & Expectations ---

  module Matchers
    def eq(expected)
      EqualityMatcher.new(expected)
    end

    def match(pattern)
      MatchMatcher.new(pattern)
    end

    def include(expected)
      IncludeMatcher.new(expected)
    end
    
    def be_true
      TruthyMatcher.new
    end
    
    def exist
      ExistMatcher.new
    end

    class EqualityMatcher
      def initialize(expected)
        @expected = expected
      end

      def matches?(actual)
        @actual = actual
        @actual == @expected
      end

      def failure_message
        "expected: #{@expected.inspect}\n     got: #{@actual.inspect}"
      end
    end

    class MatchMatcher
      def initialize(pattern)
        @pattern = pattern
        @pattern = Regexp.new(pattern) if pattern.is_a?(String)
      end

      def matches?(actual)
        @actual = actual
        @actual.to_s.match?(@pattern)
      end

      def failure_message
        "expected #{@actual.inspect} to match #{@pattern.inspect}"
      end
    end
    
    class IncludeMatcher
      def initialize(expected)
        @expected = expected
      end
      
      def matches?(actual)
        @actual = actual
        @actual.include?(@expected)
      end
      
      def failure_message
        "expected #{@actual.inspect} to include #{@expected.inspect}"
      end
    end
    
    class TruthyMatcher
      def matches?(actual)
        !!actual
      end
      
      def failure_message
        "expected true, got false/nil"
      end
    end
    
    class ExistMatcher
      def matches?(actual)
        @actual = actual
        File.exist?(actual)
      end
      
      def failure_message
        "expected file/directory #{@actual} to exist"
      end
    end
  end

  class ExpectationTarget
    def initialize(actual)
      @actual = actual
    end

    def to(matcher)
      unless matcher.matches?(@actual)
        raise ExpectationNotMetError, matcher.failure_message
      end
    end

    def not_to(matcher)
      if matcher.matches?(@actual)
        raise ExpectationNotMetError, matcher.failure_message_when_negated
      end
    end
  end

  # The context in which 'it' blocks execute
  class ExecutionContext
    include Matchers

    def initialize(data)
      @data = data
    end

    # Accessor for shared data (like skill_path)
    def method_missing(name, *args)
      key = name.to_s
      if @data.key?(key)
        @data[key]
      elsif @data.key?(name)
        @data[name]
      else
        super
      end
    end

    def expect(actual)
      ExpectationTarget.new(actual)
    end
    
    def skip(reason)
      raise SkipSignal, reason
    end
  end

  class SkipSignal < StandardError; end
  class ExpectationNotMetError < StandardError; end

  # --- Reporting ---

  class ConsoleReporter
    attr_reader :stats

    def initialize
      @stats = { passed: 0, failed: 0, skipped: 0, total: 0 }
      @indent_level = 0
    end

    def group_started(group)
      puts "#{'  ' * @indent_level}#{group.description}"
      @indent_level += 1
    end

    def group_finished(group)
      @indent_level -= 1
    end
    
    def group_skipped(group, reason)
      puts "#{'  ' * @indent_level}#{group.description} (skipped - #{reason})"
    end

    def example_passed(example)
      @stats[:passed] += 1
      @stats[:total] += 1
      puts "#{'  ' * @indent_level}#{example.description}"
    end

    def example_failed(example, error)
      @stats[:failed] += 1
      @stats[:total] += 1
      puts "#{'  ' * @indent_level}#{example.description} (FAILED - #{@stats[:failed]})"
      @failures ||= []
      @failures << { example: example, error: error, index: @stats[:failed] }
    end

    def example_skipped(example, reason)
      @stats[:skipped] += 1
      @stats[:total] += 1
      puts "#{'  ' * @indent_level}#{example.description} (skipped - #{reason})"
    end
    
    def print_summary
      if @failures && !@failures.empty?
        puts "\nFailures:"
        @failures.each do |f|
          puts "\n  #{f[:index]}) #{f[:example].full_description}"
          puts "     Failure/Error: #{f[:error].message}"
        end
      end

      puts "\nFinished in 0.001 seconds (mocked time)"
      puts "#{@stats[:total]} examples, #{@stats[:failed]} failures#{@stats[:skipped] > 0 ? ", #{@stats[:skipped]} skipped" : ""}"
    end
  end
  
  # Global entry point
  def self.run(spec_files, context_data = {})
    world = World.new
    
    # Load all spec files. They will call `describe` on the Main object,
    # so we need to bridge that.
    
    # Simple bridge: evaluate files in context of world
    spec_files.each do |file|
      content = File.read(file)
      world.instance_eval(content, file)
    end

    reporter = ConsoleReporter.new
    
    world.example_groups.each do |group|
      group.run(reporter, context_data)
    end
    
    reporter
  end
end
