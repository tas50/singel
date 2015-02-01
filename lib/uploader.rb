#!/usr/bin/env ruby

# uploads the packer artifacts to S3
class SingelUploader
  def initialize(template)
    @file_path = template
  end

  def push
    puts "- Would be uploading the artifact for #{File.basename(@file_path, '.json')}".to_green.indent
  end

end
