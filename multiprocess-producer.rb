#!/usr/bin/env ruby
# frozen_string_literal: true

class Multiprocess
  def initialize(&block)
    @r, @w = IO.pipe
    @on_result = block
  end

  def work(workers = 4, &block)
    run_producers(workers, &block)
    run_consumer
  end

  protected

  def run_producers(workers, &block)
    workers.times do
      fork do
        @w << "#{Marshal.dump(block.call)}#{$/}"
      end
    end
    @w.close
  end

  def run_consumer
    loop do
      data = @r.gets
      break unless data

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
