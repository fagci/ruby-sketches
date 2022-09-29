#!/usr/bin/env ruby
# frozen_string_literal: true

C = 299_792_458.0

freqs_mhz = [
  0.5,
  1.8, # 160 m
  3.5, # 80 m
  7.1, # 40 m
  10.1, # 30 m
  14.0, # 20 m
  18.1, # 17 m
  21.0, # 15 m
  24.9, # 12 m
  27.1, # CB
  28.5, # 10 m
  130.0,
  145.5, # 2 m
  255.5,
  300.2,
  434.0, # 70 cm
  446.0
].freeze

def cell(value)
  " #{value.to_s.rjust(6)} "
end

def row(cols)
  cols.map { |c| cell c }.join('|')
end

def table(cols, rows)
  [
    row(cols),
    (['--------'] * cols.size).join('+'),
    *rows.map { |r| row r }
  ].join("\n")
end

divs = (0..4).map { |v| 2**v }

cols = ['f,MHz', *divs.map { |d| d == 1 ? 'l' : "l/#{d}" }]

rows = freqs_mhz.map do |f|
  l = C / f / 1_000_000.0
  [f, *(divs.map { |d| format('%.2f', l / d) })]
end

puts table(cols, rows)
