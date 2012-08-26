#!/usr/bin/env ruby

$:.unshift(File.dirname(__FILE__) + "/lib")

require "nagiosplugin"
require "nagiosplugin/default_options"

class MyPlugin < NagiosPlugin::Plugin
  include NagiosPlugin::DefaultOptions

  VERSION = 1.0

  class << self
    def run(*args)
      self.new(*args).run
    end
  end

  def parse_options(*args)
    @options = {}
    OptionParser.new do |opts|
      opts.banner  = "% #{File.basename($0)} --filename <file>"
      opts.separator ""
      opts.separator "Specific options:"
      opts.separator ""

      opts.on('-f', '--filename <name>', 'Filename that should exist.') do |s|
        @options[:filename] = s
      end

      yield(opts) if block_given?

      begin
        opts.parse!(args)
        @options
      rescue => e
        puts "#{e}\n\n#{opts}"
        exit(3)
      end
    end
  end

  def initialize(*args)
    parse_options(*args, &default_options)
    @warn = @options[:warn] if @options[:warn]
    @crit = @options[:crit] if @options[:crit]
    @reverse = @options[:reverse] if @options[:reverse]
    @filename = @options[:filename]
  end

  def check
    if File.executable?(@filename)
      ok("#{@filename} is excutable")
    elsif File.exists?(@filename)
      warning("#{@filename} is not excutable")
    else
      critical("#{@filename} does not exist")
    end
  end
end

MyPlugin.run(*ARGV)
