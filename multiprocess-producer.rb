#!/usr/bin/env ruby
# frozen_string_literal: true

require 'English'

# Creates read-only channel from tasks to consumer
class Channel
  def initialize
    @r, @w = IO.pipe
  end

  def read
    data = @r.gets
    return nil unless data

    Marshal.load(data) # rubocop:disable Security/MarshalLoad
  end

  def write(data)
    @w << "#{Marshal.dump(data)}#{$RS}"
  end

  def close_r
    @r.close
  end

  def close_w
    @w.close
  end
end

class Multiprocess
  def initialize(&block)
    @channel = Channel.new
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
        @channel.close_r
        @channel.instance_eval(&block)
      end
    end
    @channel.close_w
  end

  def run_consumer
    while (data = @channel.read)
      @on_result.call(data)
    end
  end
end

mp = Multiprocess.new do |data|
  puts data
end

mp.work do
  4.times do |i|
    write "i: #{i}, t: #{sleep(rand(5))}"
  end
end