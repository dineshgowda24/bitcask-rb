# frozen_string_literal: true

require 'benchmark'
require 'benchmark/ips'
require 'faker'
require_relative 'lib/bitcask'

include Benchmark

disk_store = Bitcask::DiskStore.new('bitcask_benchmark.db')
value = Faker::Lorem.sentence(word_count: 10)

puts "Benchmarked with value_size of #{value.length} bytes"

Benchmark.benchmark(CAPTION, 50, FORMAT, 'avg_put:', 'avg_get:') do |benchmark|
  tt_put_10k = benchmark.report('DiskStore.put : 10k records') {
    10_000.times do |n_time|
      disk_store.put("10_000#{n_time}", value)
    end
  }

  tt_get_10k = benchmark.report('DiskStore.get : 10k records') {
    10_000.times do
      disk_store.get("10_000#{rand(1..10_000)}")
    end
  }

  tt_put_100k = benchmark.report('DiskStore.put : 100k records') {
    100_000.times do |n_time|
      disk_store.put("100_000#{n_time}", value)
    end
  }

  tt_get_100k = benchmark.report('DiskStore.get : 100k records') {
    100_000.times do
      disk_store.get("100_000#{rand(1..100_000)}")
    end
  }

  tt_put_1M = benchmark.report('DiskStore.put : 1M records') {
    1_000_000.times do |n_time|
      disk_store.put("1_000_000#{n_time}", value)
    end
  }

  tt_get_1M = benchmark.report('DiskStore.get : 1M records') {
    1_000_000.times do
      disk_store.get("1_000_000#{rand(1..1_000_000)}")
    end
  }

  [(tt_put_10k + tt_put_100k + tt_put_1M) / (10_000 + 100_000 + 1_000_000).to_f,
   (tt_get_10k + tt_get_100k + tt_get_1M) / (10_000 + 100_000 + 1_000_000).to_f]
end

value_1 = Faker::Lorem.sentence(word_count: 100)
value_2 = Faker::Lorem.sentence(word_count: 1000)
value_3 = Faker::Lorem.sentence(word_count: 100_000)

Benchmark.ips do |benchmark|
  benchmark.report("DiskStore.put : 100 records with data size: #{value_1.length} Bytes") do
    100.times do |n_time|
      disk_store.put("10_000_#{value_1.length}#{n_time}", value_1)
    end
  end

  benchmark.report("DiskStore.get : 100 records, value size: #{value_1.length} Bytes") do
    100.times do
      disk_store.get("10_000#{value_1.length}#{rand(1..10_000)}")
    end
  end

  benchmark.report("DiskStore.put : 100 records, value size: #{value_2.length / 1024} Kb") do
    100.times do |n_time|
      disk_store.put("10_000#{value_2.length}#{n_time}", value_2)
    end
  end

  benchmark.report("DiskStore.get : 100 records, value size: #{value_2.length / 1024} Kb") do
    100.times do
      disk_store.get("10_000#{value_2.length}#{rand(1..10_000)}")
    end
  end

  benchmark.report("DiskStore.put : 100 records, value size: #{value_3.length / 1024} Kb") do
    100.times do |n_time|
      disk_store.put("10_000#{value_3.length}#{n_time}", value_3)
    end
  end

  benchmark.report("DiskStore.get : 100 records, value size: #{value_3.length / 1024} Kb") {
    100.times do
      disk_store.get("10_000#{value_3.length}#{rand(1..10_000)}")
    end
  }
end

File.delete('bitcask_benchmark.db')
