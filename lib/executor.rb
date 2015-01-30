#!/usr/bin/env ruby

# executes packer commands against template files
class SingelExecutor
  def initialize(filename)
    @filename = filename
    @packer_dir = File.absolute_path(File.join(File.dirname($0), 'packer'))
    @file_path = File.join(@packer_dir, filename)
    @builders = {}
  end

  # shell out to packer to validate the config files for correctness
  def validates?
    Dir.chdir(@packer_dir)
    `packer validate #{@file_path} 2>&1`
    Dir.chdir('..') # prevent poisening $0 path on the next instance
    $CHILD_STATUS.success? ? true : false
  end

  # inspect the json file to determine the name and type of the builders
  def parse_builders
    template_file = File.read(@file_path)
    template_json = JSON.parse(template_file)
    template_json['builders'].each do |builder|
      @builders[builder['name']] = builder['type']
    end
  end

  # print out the builders for this template
  def list
    puts @filename.gsub('.json','') + ':'
    self.parse_builders
    if @builders.empty?
      puts '- No builders found'.indent.to_red
    else
      @builders.each_pair do |name,type|
        puts "- #{name} (type: #{type})".indent
      end
    end
  end
end
