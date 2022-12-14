#!/usr/bin/env ruby
# frozen_string_literal: true

require 'socket'

class String
  def find_open_ports(*ports)
    ports = (1..1024) if ports.none?
    ports = ports.first if ports.size == 1 && ports.first.is_a?(Range)
    ports = ports.map(&:to_a).flatten if ports.all? { |p| p.is_a? Enumerable }

    open_ports = []
    ports.map do |port|
      Thread.new do
        TCPSocket.open(self, port, connect_timeout: 0.75) do
          open_ports << port
        end
      rescue StandardError
      end
    end.map(&:join)
    open_ports.sort
  end
  alias scan_ports find_open_ports
end

# puts '192.168.0.200'.scan_ports(1..1024)
# puts '192.168.0.200'.scan_ports
# puts '192.168.0.200'.scan_ports(22, 80)
puts '192.168.0.200'.scan_ports((22..25), [80, 443])
