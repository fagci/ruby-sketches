#!/usr/bin/env ruby
# frozen_string_literal: true

require 'uri'

class Database
  def initialize(dsn)
    @dsn = URI dsn
  end

  def [](tbl)
    From.new(self, tbl)
  end

  def exec(query)
    warn "Exec: #{query}"
  end
end

class Query
  attr_reader :db

  @@kw = 'SELECT *'
  @@op = ' '

  def initialize(db, parent = nil, *params)
    @db = db
    @parent = parent
    @parts = []
  end

  def where(*params)
    Where.new(@db, self, *params)
  end

  alias [] where

  def quote(v)
    return v if v.is_a?(Numeric) || !!v == v

    escaped =
      v
      .gsub(/\\/, '\&\&')
      .gsub(/'/, "''")
    "'#{escaped}'"
  end

  def all
    @db.exec self
  end

  def to_s
    [
      @parent,
      "#{@@kw} #{@parts.join(@@op)}"
    ].compact.join(' ')
  end
end

class From < Query
  @@kw = 'FROM'
  @@op = ', '
  def initialize(db, parent, *params)
    super(db, parent)

    @parts = params
  end
end

class Where < Query
  @@kw = 'WHERE'
  @@op = ' AND '
  def initialize(db, parent, *params)
    super(db, parent)

    params.each do |q|
      next unless q.is_a? Hash

      q.map do |k, v|
        @parts <<
          case v
          when Numeric, String
            "#{k} = #{quote v}"
          when Array
            enum = v.map { |v| quote(v) }.join(', ')
            "#{k} IN (#{enum})"
          when Range
            "#{k} BETWEEN #{quote v.first} AND #{quote v.last}"
          end
      end
    end
  end
end

class String
  def connect
    Database.new self
  end
end

DB = 'sqlite:///local.db'.connect

t = DB[:table_name]

t.where(a: 2).all
t.where(a: (1..5)).all
t.where(a: [1, 2, 3]).all
t.where(a: "te'st").all
t[id: (1..5).to_a, name: 'test'].all
