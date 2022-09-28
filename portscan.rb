#!/usr/bin/env ruby
# frozen_string_literal: true

require 'socket'

class String
  def find_open_ports(*ports)
    host = self
    ports = (1..1024) if ports.none?
    ports = ports.first if ports.size == 1 && ports.first.is_a?(Range)

    open_ports = []
    ports.map do |port|
      Thread.new do
        TCPSocket.open(host, port, connect_timeout: 0.75) do
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
puts '192.168.0.200'.scan_ports
