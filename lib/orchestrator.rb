#!/usr/bin/env ruby

class SingelOrchestrator
  def initialize(options)
    @templates = find_templates
    @options = options
  end

  # main method used to kick off the run
  def run
    puts "\nsingel - unified image creation tool"
    puts "-----------------------------------------\n\n"

    check_dirs
    check_aws_keys
    check_executables

    execute_command(ARGV[0])
  end

  # check to make sure necessary directories exist
  def check_dirs
    %w(packer output).each do |dir|
      unless File.directory?(dir)
        puts "#{dir.capitalize} directory not present. Create directory '#{dir}' in the root of the singel directory before continuing.".to_red
        exit
      end
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
    templates = []
    Dir.foreach('packer/') do |item|
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
