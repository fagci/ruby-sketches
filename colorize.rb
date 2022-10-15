#!/usr/bin/env ruby
# frozen_string_literal: true

class String
  COLORS = {
    black: 0,
    red: 1,
    green: 2,
    yellow: 3,
    blue: 4,
    magenta: 5,
    cyan: 6,
    white: 7,
    default: 9,
    light_black: 60,
    light_red: 61,
    light_green: 62,
    light_yellow: 63,
    light_blue: 64,
    light_magenta: 65,
    light_cyan: 66,
    light_white: 67
  }.freeze

  COLORS.each do |c, v|
    define_method c do
      "\033[#{v + 30};1m#{self}\033[0m"
    end
    define_method :"bg_#{c}" do
      "\033[#{v + 40};1m#{self}\033[0m"
    end
  end
end

puts 'test'.red.bg_light_green
