#!/usr/bin/env ruby

lib =  File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

begin
  require 'optparse'
  require 'English'
  require 'aws-sdk-core'
  require 'json'
  require 'orchestrator.rb'
  require 'executor.rb'
rescue LoadError => e
  raise "Missing gem or lib #{e}"
end

class String
  # make text green
  def to_green
    "\033[32m#{self}\033[0m"
  end

  def to_red
    "\033[31m#{self}\033[0m"
  end

  def indent(double_space_count = 1)
    double_space_count.times { insert(0, '  ') }
    self
  end
end

def parse_opts
  options = { :templates => [], :builders => [] }
  banner = "Singel - Unified system image creation using Packer\n\n" +
            "Usage: singel [action] [options]\n\n" +
            "  Actions:\n" +
            "    build: Build system images\n" +
            "    list: List available image templates and builder types (AMI, Virtualbox, etc)\n\n" +
            "  Options:\n"
  OptionParser.new do |opts|
    opts.banner = banner
    opts.on('-t', '--templates', "Build only the specified comma separated list of templates") do
      options[:templates] = []
    end
    opts.on('-b', '--builders', "Build only the specified comma separated list of builder types") do
      options[:builers] = []
    end
    opts.on('-h', '--help', 'Displays Help') do
      puts opts
      exit
    end
  end.parse!

  options
end

# make sure the user provided a server name
unless ARGV[0]
  puts "You must provide an action for singel to execute on\n".to_red
  ARGV << '-h'
end

# parse the user provided options
options = parse_opts

SingelOrchestrator.new(options).run
