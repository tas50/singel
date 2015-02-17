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
  # instance of a single packer template with methods to validate and extract data
  class PackerTemplate
    attr_accessor :path, :name

    def initialize(path)
      @path = File.expand_path(path)
      @name = File.basename(@path, '.json')
      @file = File.read(path)
    end

    def json
      @parsed || @parsed = JSON.parse(@file)
    end

    def builders
      json['builders'].map { |b| b['name'] }
    end

    def builders_hash
      builders = {}
      json['builders'].each do |builder|
        builders[builder['name']] = builder['type']
      end
      builders
    end

    # shell out to packer to validate the config files for correctness
    def validates?
      Dir.chdir(File.dirname(@path))
      `packer validate #{@path} 2>&1`
      $CHILD_STATUS.success? ? true : false
    end
  end
end
