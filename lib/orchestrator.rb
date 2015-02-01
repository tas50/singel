#!/usr/bin/env ruby

class SingelOrchestrator
  def initialize(options)
    @options = options
    @templates = find_templates
  end

  # main method used to kick off the run
  def run
    puts "\nsingel - unified image creation tool"
    puts "-----------------------------------------\n\n"

    check_aws_keys
    check_executables

    execute_command(ARGV[0])
  end

  # check to make sure necessary directories exist
  def check_dirs
    unless Dir.exist?(@options[:packer_dir])
      puts "#{@options[:packer_dir]} not present. Cannot continue".to_red
      exit
    end
  end

  # make a test connection using the AWS keys to determine if they're valid
  def check_aws_keys
    ec2 = Aws::EC2::Client.new(region: 'us-east-1')
    ec2.describe_instance_status
  rescue
    puts 'Could not connect to EC2. Check your local AWS credentials before continuing.'.to_red
    exit
  end

  # check to make sure the prereq binaries present
  def check_executables
    { 'Virtualbox' => 'vboxwebsrv', 'Packer' => 'packer' }.each_pair do |name, binary|
      `which #{binary} 2>&1`
      unless $CHILD_STATUS.success?
        puts "Could not find #{name} binary #{binary}. You must install #{name} before continuing.".to_red unless $CHILD_STATUS
        exit
      end
    end
  end

  # find the available packer templates on the host
  def find_templates
    check_dirs
    templates = []
    Dir.foreach(@options[:packer_dir]) do |item|
      templates << item if File.extname(item).downcase == '.json'
    end

    if templates.empty?
      puts "No packer templates found in the 'packer' dir. Cannot continue.".to_red
      exit
    end
    templates
  end

  # run the passed command per packer template
  def execute_command(cmd)
    @templates.each do |template|
      packer = SingelExecutor.new(template)
      puts "Packer template validation for #{template} failed.".to_red unless packer.validates?
      packer.send(cmd)
    end
  end
end
