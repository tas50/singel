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

# executes packer commands against template object
class PackerExecutor
  def initialize(template, builders)
    @template = template
    @file_path = template.path
    @template_builders = template.builders
    @specified_builders = builders
  end

  # print out the builders for this template
  def list
    puts File.basename(@file_path, '.json') + ':'

    builders = @template.builders_hash
    if builders.empty?
      puts '- No builders found'.indent.to_red
    else
      builders.each_pair do |name, type|
        puts "- #{name} (type: #{type})".indent
      end
    end
  end

  def build
    puts "Building #{File.basename(@file_path, '.json')}:".to_green
    stream_cmd("packer build #{build_options} #{@file_path}")
  end

  # specify the builders if any were passed
  def build_options
    "-only=#{@specified_builders.join(',')}" unless @specified_builders.empty?
  end

  def stream_cmd(command)
    PTY.spawn(command) do |r, _w, _pid|
      begin
       r.each { |line| print line; }
    rescue Errno::EIO
     end
    end
 rescue PTY::ChildExited
   puts 'The child process exited!'
  end
end
