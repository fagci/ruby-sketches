#!/usr/bin/env ruby
# frozen_string_literal: true

require 'uri'

class Database
  def initialize(dsn)
    @dsn = URI dsn
  end

  def [](tbl)
    Query.new(self, tbl)
  end

  def exec(query)
    warn "Exec: #{query}"
  end
end

class Query
  attr_reader :db

  def initialize(db, tbl)
    @db = db
    @select = 'SELECT *'
    @from = [tbl]
    @where = []
  end

  def where(*params)
    params.each do |q|
      next unless q.is_a? Hash

      q.map do |k, v|
        @where <<
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
    self
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
      @select,
      @from.empty? ? '' : "FROM #{@from.join(', ')}",
      @where.empty? ? '' : "WHERE #{@where.join(' AND ')}"
    ].reject(&:empty?).join(' ') + ';'
  end
end

class String
  def connect
    Database.new self
  end
end

DB = 'sqlite:///local.db'.connect

DB[:table_name].where(a: 2).all
DB[:table_name].where(a: (1..5)).all
DB[:table_name].where(a: [1, 2, 3]).all
DB[:table_name].where(a: "te'st").all
DB[:table_name][id: (1..5).to_a, name: 'test'].all
