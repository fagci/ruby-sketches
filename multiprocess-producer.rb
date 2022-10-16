#!/usr/bin/env ruby
# frozen_string_literal: true

require 'English'

# Creates one way channel
class Channel
  def initialize
    @read_io, @write_io = IO.pipe
  end

  def read
    @write_io.close unless @write_io.closed?
    data = @read_io.gets
    return nil unless data

    Marshal.load(data) # rubocop:disable Security/MarshalLoad
  end

  def write(data)
    @read_io.close unless @read_io.closed?
    @write_io << "#{Marshal.dump(data)}#{$RS}"
  end
end

# Run tasks using multiple processes
class Multiprocess
  def initialize(&block)
    @channel = Channel.new
    @result_callback = block
  end

  def work(workers_count = 2, &block)
    workers_count.times do
      fork do
        @channel.instance_eval(&block)
      end
    end

    while (data = @channel.read)
      @result_callback.call data
    end
  end
end

mp = Multiprocess.new do |data|
  puts data
end

mp.work do
  2.times do |i|
    write "i: #{i}, t: #{sleep(rand(5))}"
  end
end
