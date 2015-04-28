# encoding: UTF-8
#
# Author:: Tim Smith (<tim@cozy.co>)
# Copyright:: Copyright (c) 2014 Tim Smith
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# main orchestrator of singel runs
module Singel
  require 'singel/config.rb'
  require 'singel/executor.rb'
  require 'singel/uploader.rb'
  require 'singel/template.rb'
  require 'string.rb'

  include Singel::Config

  # main method used to kick off the run
  def self::run
    # flush output immediatly so job status shows up in jenkins
    $stdout.sync = $stderr.sync = true
    @options = Config.config
    puts "\nsingel - unified image creation tool"
    puts "-----------------------------------------\n\n"

    check_dirs
    check_executables
    @templates = find_templates
    check_aws_keys

    execute_command(ARGV[0])
  end

  private

  # check to make sure the packer dir exists
  def self::check_dirs
    unless Dir.exist?(@options[:packer_dir])
      puts "#{@options[:packer_dir]} not present.".to_red
      puts "See help for information on specifying an alternate dir.\n".to_red
      exit!
    end
  end

  # make a test connection using the AWS keys to determine if they're valid
  def self::check_aws_keys
    ec2 = Aws::EC2::Client.new(region: 'us-east-1')
    ec2.describe_instance_status
  rescue
    puts 'Could not connect to EC2. Check your local AWS credentials before continuing.'.to_red
    STDOUT.flush
    exit!
  end

  # check to make sure the prereq binaries present
  def self::check_executables
    { 'Virtualbox' => 'vboxwebsrv', 'Packer' => 'packer' }.each_pair do |name, binary|
      `which #{binary} 2>&1`
      unless $CHILD_STATUS.success?
        puts "Could not find #{name} binary #{binary}. You must install #{name} before continuing.".to_red unless $CHILD_STATUS
        exit!
      end
    end
  end

  # find the available packer templates on the host
  def self::find_templates
    # find packer templates on disk since none were passed via args
    if @options[:templates].empty?
      templates = []
      Dir.foreach(@options[:packer_dir]) do |item|
        templates << File.join(@options[:packer_dir], item) if File.extname(item).downcase == '.json'
      end

      # throw and error and exist if we still dont find any templates
      if templates.empty?
        puts "No packer templates found in the 'packer' dir. Cannot continue.".to_red
        exit!
      end
      templates
    else # parse the arg provided template list
      @options[:templates].map { |x| File.join(@options[:packer_dir], x) }
    end
  end

  # run the passed command per packer template
  def self::execute_command(cmd)
    @templates.each do |t|
      template = PackerTemplate.new(t)
      executor = PackerExecutor.new(template, @options[:builders])
      puts "Packer template validation for #{template.path} failed.\n".to_red unless template.validates?
      begin
        executor.send(cmd)
      rescue NoMethodError
        puts "Action \"#{cmd}\" not found.  Cannot continue".to_red
        exit!
      end
    end
  end
end
