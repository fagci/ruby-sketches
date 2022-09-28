#!/usr/bin/env ruby
# frozen_string_literal: true

require 'faraday'

class Sites
  def initialize(&block)
    @domain_paths = Hash.new { |h, k| h[k] = [] }
    instance_eval(&block) if block_given?
  end

  def add(domain, paths)
    @domain_paths[domain] |= paths
  end

  def broken_links
    @domain_paths.filter_map do |domain, paths|
      client = Faraday.new(domain)
      res = paths.filter_map do |path|
        status = client.get(path).status
        [path, status] unless status == 200
      end
      res.map { |p, s| "[#{s}] #{domain}#{p}" }
    end.join("\n")
  end
end

class Task
  def notify(user, msg)
    return if msg.to_s.empty?

    warn "[Notify] #{user}:\n#{msg}"
  end
end

def task(_name, &block)
  Task.new.instance_eval(&block)
end

sites = Sites.new do
  add 'https://www.hackthissite.org', %w[
    /news
    /non-existent-link
  ]
end

task 'broken links' do
  notify 'fagci', sites.broken_links
end
