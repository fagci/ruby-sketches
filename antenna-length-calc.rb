#!/usr/bin/env ruby
# frozen_string_literal: true

C = 299_792_458.0

freqs_mhz = [
  0.5,
  1.8,
  3.5,
  7.1,
  10.1,
  14.0,
  18.1,
  21.0,
  24.9,
  28.0,
  130.0,
  145.5,
  255.5,
  300.2,
  434.0,
  446.0
].freeze

puts 'f,MHz |    l,m |  l/2,m |  l/4,m |  l/8,m'
puts '      |        |        |        |'

freqs_mhz.each do |f|
  l = C / f / 1_000_000.0
  res = [f, l, l / 2, l / 4, l / 8]
  puts '%5.1f | %6.2f | %6.2f | %6.2f | %6.2f' % res
end
