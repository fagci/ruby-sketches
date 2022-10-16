#!/usr/bin/env ruby
# frozen_string_literal: true

require 'etc'
require 'English'

module Concurrent
  # Creates one way channel
  class Channel
    def initialize
      @read_io, @write_io = IO.pipe
    end

    def read
      @write_io.close unless @write_io.closed?
      data = @read_io.gets
      return nil unless data

      Marshal.load data # rubocop:disable Security/MarshalLoad
    end

    def write(data)
      @read_io.close unless @read_io.closed?
      @write_io << "#{Marshal.dump(data)}#{$RS}"
    end
  end

  # Run tasks using multiple processes
  class Parallel
    def initialize(&block)
      @channel = Channel.new
      @result_callback = block
    end

    def work(workers_count = 2, &block)
      spawn_workers(workers_count, &block)

      while (data = @channel.read)
        @result_callback.call data
      end
    end

    def spawn_workers(count, &block)
      proc_count, thr_count = Parallel.calc_resources count
      proc_count.times do |i|
        ::Process.fork do
          spawn_threads(thr_count, i, &block).each(&:join)
        end
      end
    end

    def spawn_threads(count, proc_i, &block)
      count.times.map do |i|
        Thread.new do
          @channel.instance_exec(proc_i, i, &block)
        end
      end
    end

    class << self
      def calc_resources(count)
        kernels_count = Etc.nprocessors
        proc_count = [count, kernels_count].min
        thr_count = [1, count / proc_count].max
        [proc_count, thr_count]
      end
    end
  end
end

def time
  Process.clock_gettime(Process::CLOCK_MONOTONIC)
end

mp = Concurrent::Parallel.new do |data|
  puts data
end

start = time
mp.work(2) do |proc_i, thr_i|
  2.times do |i|
    sleep_time = sleep(rand(5))
    write "[#{format('%6.3f', (time - start))}] proc#{proc_i} thr#{thr_i} i#{i} sleep(#{sleep_time})"
  end
end
