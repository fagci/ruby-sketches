#!/usr/bin/env ruby
# frozen_string_literal: true

require 'English'

# Creates read-only channel from tasks to consumer
class Multiprocess
  def initialize(&block)
    @r, @w = IO.pipe
    @on_result = block
  end

  def work(workers_count = 4, &block)
    run_producers(workers_count, &block)
    run_consumer
  end

  protected

  def run_producers(workers_count, &block)
    workers_count.times do
      fork do
        @w << "#{Marshal.dump(block.call)}#{$RS}"
      end
    end
    @w.close
  end

  def run_consumer
    while (data = @r.gets)
      @on_result.call(Marshal.load(data))
    end
  end
end

mp = Multiprocess.new do |data|
  puts data
end

mp.work do
  sleep rand(5)
end
