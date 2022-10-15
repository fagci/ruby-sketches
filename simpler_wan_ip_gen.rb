#!/usr/bin/env ruby
# frozen_string_literal: true

# WAN range IP generator
class WANIPGenerator
  include Enumerable

  EXCLUDE_RANGES = [
    (0xe0000000..0xefffffff), # 224.0.0.0 - 239.255.255.255
    (0xf0000000..0xfffffffe), # 240.0.0.0 - 255.255.255.254
    (0xA000000..0xAFFFFFF),   # 10.0.0.0 - 10.255.255.255
    (0x7F000000..0x7FFFFFFF), # 127.0.0.0 - 127.255.255.255
    (0x64400000..0x647FFFFF), # 100.64.0.0 - 100.127.255.255
    (0xAC100000..0xAC1FFFFF), # 172.16.0.0 - 172.31.255.255
    (0xC6120000..0xC613FFFF), # 198.18.0.0 - 198.19.255.255
    (0xA9FE0000..0xA9FEFFFF), # 169.254.0.0 - 169.254.255.255
    (0xC0A80000..0xC0A8FFFF), # 192.168.0.0 - 192.168.255.255
    (0xC0000000..0xC00000FF), # 192.0.0.0 - 192.0.0.255
    (0xC0000200..0xC00002FF), # 192.0.2.0 - 192.0.2.255
    (0xc0586300..0xc05863ff), # 192.88.99.0 - 192.88.99.255
    (0xC6336400..0xC63364FF), # 198.51.100.0 - 198.51.100.255
    (0xCB007100..0xCB0071FF), # 203.0.113.0 - 203.0.113.255
    (0xe9fc0000..0xe9fc00ff)  # 233.252.0.0 - 233.252.0.255
  ].freeze

  def each(&block)
    loop do
      intip = rand(0x01000000...0xffffffff) # exclude current network and local broadcast
      next if EXCLUDE_RANGES.any? { |r| r.cover? intip }

      block.call [intip].pack('N').unpack('CCCC').join('.')
    end
  end
end

ip_gen = WANIPGenerator.new

puts "Single IP: #{ip_gen.first}"

puts
puts 'Multiple IPs:'

ip_gen.first(5).each do |ip|
  puts ip
end
