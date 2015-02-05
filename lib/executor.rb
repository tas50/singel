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

# executes packer commands against template files
class SingelExecutor
  def initialize(template)
    @file_path = template
    @packer_dir = File.dirname(template)
    @builders = {}
  end

  # shell out to packer to validate the config files for correctness
  def validates?
    Dir.chdir(@packer_dir)
    `packer validate #{@file_path} 2>&1`
    $CHILD_STATUS.success? ? true : false
  end

  # inspect the json file to determine the name and type of the builders
  def parse_builders
    template_file = File.read(@file_path)
    template_json = JSON.parse(template_file)
    template_json['builders'].each do |builder|
      @builders[builder['name']] = builder['type']
    end
  rescue Errno::ENOENT
    puts "- Could not find the passed template file #{@file_path}".indent.to_red
    exit!
  end

  # print out the builders for this template
  def list
    puts File.basename(@file_path, '.json') + ':'
    parse_builders
    if @builders.empty?
      puts '- No builders found'.indent.to_red
    else
      @builders.each_pair do |name, type|
        puts "- #{name} (type: #{type})".indent
      end
    end
  end

  def build
    puts "Building #{File.basename(@file_path, '.json')}:".to_green
    IO.popen("packer build #{@file_path}") do |cmd|
      cmd.each { |line| puts line }
    end

    SingelUploader.new(@file_path).push
  end
end
