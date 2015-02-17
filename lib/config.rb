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

module Singel
  # allow fetching the config anywhere in the app
  module Config
    # return the config object or parse the options fresh
    def self.config
      @config ||= parse_opts
    end

    # parse options passed from the command line
    def self.parse_opts
      options = { :templates => [], :builders => [], :packer_dir => File.expand_path('./packer') }
      banner = "Singel - Unified system image creation using Packer\n\n" \
                "Usage: singel [action] [options]\n\n" \
                "  Actions:\n" \
                "    build: Build system images\n" \
                "    list: List available image templates and builder types (AMI, Virtualbox, etc)\n\n" \
                "  Options:\n"
      OptionParser.new do |opts|
        opts.banner = banner
        opts.on('-t', '--templates t1.json,t2.json', Array, 'Build only the specified comma separated list of templates') do |t|
          options[:templates] = t
        end
        opts.on('-b', '--builders type1,type2', Array, 'Build only the specified comma separated list of builder types') do |b|
          options[:builders] = b
        end
        opts.on('-p', '--packer_dir PATH', 'Path to the packer dir containing templates and other files') do |p|
          options[:packer_dir] = File.expand_path(p)
        end
        opts.on('-h', '--help', 'Displays Help') do
          puts opts
          exit
        end
      end.parse!(ARGV)

      options
    end
  
    # if no argument was passed or the first arg starts with - (aka it's not actually an action)
    if ARGV[0].nil? || ARGV[0][0] == '-' 
      puts "You must provide an action for singel to execute on\n".to_red
      puts "single ACTION [OPTIONS]".to_red
      ARGV << '-h'
    end
  end
end
