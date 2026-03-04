#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'time'
require 'fileutils'

# Usage: ruby aggregate_benchmark.rb <path/to/iteration-N>
# Reads all eval-N/{with_skill,baseline}/{grading,timing}.json
# Outputs: benchmark.json with aggregated stats

iteration_path = ARGV[0]

unless iteration_path && Dir.exist?(iteration_path)
  puts 'Usage: ruby aggregate_benchmark.rb <path/to/iteration-N>'
  puts 'Example: ruby aggregate_benchmark.rb workspace/iteration-1'
  exit 1
end

# Discover all eval directories (eval-1, eval-2, etc.)
eval_dirs = Dir.glob("#{iteration_path}/eval-*").select { |f| File.directory?(f) }.sort

unless eval_dirs.any?
  puts "Error: No eval-* directories found in #{iteration_path}"
  exit 1
end

# Extract iteration number from path (e.g., iteration-2 → 2)
iteration_num = File.basename(iteration_path).match(/iteration-(\d+)/)[1].to_i

# Initialize benchmark structure
benchmark = {
  skill_name: '',
  iteration: iteration_num,
  timestamp: Time.now.iso8601,
  evals: [],
  summary: {
    with_skill_avg_pass_rate: 0.0,
    baseline_avg_pass_rate: 0.0,
    improvement: 0.0,
    avg_tokens_with_skill: 0,
    avg_tokens_baseline: 0,
    token_cost: 0,
    avg_duration_ms_with_skill: 0,
    avg_duration_ms_baseline: 0
  }
}

# Process each eval directory
with_skill_pass_rates = []
baseline_pass_rates = []
with_skill_tokens = []
baseline_tokens = []
with_skill_durations = []
baseline_durations = []

eval_dirs.each do |eval_dir| # rubocop:disable Metrics/BlockLength
  eval_id = File.basename(eval_dir).match(/eval-(\d+)/)[1].to_i

  with_skill_grading_path = "#{eval_dir}/with_skill/grading.json"
  with_skill_timing_path = "#{eval_dir}/with_skill/timing.json"
  baseline_grading_path = "#{eval_dir}/baseline/grading.json"
  baseline_timing_path = "#{eval_dir}/baseline/timing.json"

  # Read grading and timing data
  with_skill_grading = File.exist?(with_skill_grading_path) ? JSON.parse(File.read(with_skill_grading_path)) : {}
  with_skill_timing = File.exist?(with_skill_timing_path) ? JSON.parse(File.read(with_skill_timing_path)) : {}
  baseline_grading = File.exist?(baseline_grading_path) ? JSON.parse(File.read(baseline_grading_path)) : {}
  baseline_timing = File.exist?(baseline_timing_path) ? JSON.parse(File.read(baseline_timing_path)) : {}

  # Extract metrics
  with_skill_pass_rate = with_skill_grading.dig('summary', 'pass_rate') || 0.0
  baseline_pass_rate = baseline_grading.dig('summary', 'pass_rate') || 0.0
  with_skill_tokens = with_skill_timing['total_tokens'] || 0
  baseline_tokens = baseline_timing['total_tokens'] || 0
  with_skill_duration = with_skill_timing['duration_ms'] || 0
  baseline_duration = baseline_timing['duration_ms'] || 0

  # Build eval result
  eval_result = {
    eval_id: eval_id,
    with_skill: {
      pass_rate: with_skill_pass_rate,
      assertions_passed: with_skill_grading.dig('summary', 'assertions_passed') || 0,
      assertions_total: with_skill_grading.dig('summary', 'assertions_total') || 0,
      avg_tokens: with_skill_tokens,
      avg_duration_ms: with_skill_duration
    },
    baseline: {
      pass_rate: baseline_pass_rate,
      assertions_passed: baseline_grading.dig('summary', 'assertions_passed') || 0,
      assertions_total: baseline_grading.dig('summary', 'assertions_total') || 0,
      avg_tokens: baseline_tokens,
      avg_duration_ms: baseline_duration
    },
    delta: {
      pass_rate: (with_skill_pass_rate - baseline_pass_rate).round(4),
      tokens: with_skill_tokens - baseline_tokens,
      duration_ms: with_skill_duration - baseline_duration
    }
  }

  benchmark[:evals] << eval_result

  # Collect metrics for summary
  with_skill_pass_rates << with_skill_pass_rate
  baseline_pass_rates << baseline_pass_rate
  with_skill_durations << with_skill_duration
  baseline_durations << baseline_duration
end

# Calculate summary statistics
avg_with_skill_pass_rate = if with_skill_pass_rates.empty?
                             0.0
                           else
                             (with_skill_pass_rates.sum.to_f / with_skill_pass_rates.length).round(4)
                           end
avg_baseline_pass_rate = if baseline_pass_rates.empty?
                           0.0
                         else
                           (baseline_pass_rates.sum.to_f / baseline_pass_rates.length).round(4)
                         end
improvement = (avg_with_skill_pass_rate - avg_baseline_pass_rate).round(4)

# For tokens and duration, calculate average across evals
avg_with_skill_tokens = 0
avg_baseline_tokens = 0
avg_with_skill_duration = 0
avg_baseline_duration = 0

unless benchmark[:evals].empty?
  eval_count = benchmark[:evals].length.to_f
  with_skill_token_sum = benchmark[:evals].map { |e| e[:with_skill][:avg_tokens] }.sum.to_f
  baseline_token_sum = benchmark[:evals].map { |e| e[:baseline][:avg_tokens] }.sum.to_f
  with_skill_duration_sum = benchmark[:evals].map { |e| e[:with_skill][:avg_duration_ms] }.sum.to_f
  baseline_duration_sum = benchmark[:evals].map { |e| e[:baseline][:avg_duration_ms] }.sum.to_f

  avg_with_skill_tokens = (with_skill_token_sum / eval_count).round(0).to_i
  avg_baseline_tokens = (baseline_token_sum / eval_count).round(0).to_i
  avg_with_skill_duration = (with_skill_duration_sum / eval_count).round(0).to_i
  avg_baseline_duration = (baseline_duration_sum / eval_count).round(0).to_i
end

benchmark[:summary] = {
  with_skill_avg_pass_rate: avg_with_skill_pass_rate,
  baseline_avg_pass_rate: avg_baseline_pass_rate,
  improvement: improvement,
  avg_tokens_with_skill: avg_with_skill_tokens,
  avg_tokens_baseline: avg_baseline_tokens,
  token_cost: avg_with_skill_tokens - avg_baseline_tokens,
  avg_duration_ms_with_skill: avg_with_skill_duration,
  avg_duration_ms_baseline: avg_baseline_duration,
  duration_cost_ms: avg_with_skill_duration - avg_baseline_duration
}

# Write benchmark.json
benchmark_path = "#{iteration_path}/benchmark.json"
File.write(benchmark_path, JSON.pretty_generate(benchmark))

puts "✓ Benchmark aggregated: #{benchmark_path}"
puts ''
puts 'Summary:'
puts "  Evals processed: #{benchmark[:evals].length}"
puts "  With Skill pass rate: #{(avg_with_skill_pass_rate * 100).round(1)}%"
puts "  Baseline pass rate: #{(avg_baseline_pass_rate * 100).round(1)}%"
puts "  Improvement: +#{(improvement * 100).round(1)} percentage points"

token_cost = avg_with_skill_tokens - avg_baseline_tokens
token_cost_str = token_cost.positive? ? "+#{token_cost}" : token_cost.to_s
puts "  Token cost: #{token_cost_str}"

duration_cost = avg_with_skill_duration - avg_baseline_duration
duration_cost_str = duration_cost.positive? ? "+#{duration_cost}" : duration_cost.to_s
puts "  Duration cost: #{duration_cost_str}ms"
