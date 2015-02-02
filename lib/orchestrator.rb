#!/usr/bin/env ruby

class SingelOrchestrator
  def initialize(options)
    @options = options
  end

  # main method used to kick off the run
  def run
    puts "\nsingel - unified image creation tool"
    puts "-----------------------------------------\n\n"

    check_dirs
    check_executables
    @templates = find_templates
    check_aws_keys

    execute_command(ARGV[0])
  end

  # check to make sure the packer dir exists
  def check_dirs
    ( puts "#{@options[:packer_dir]} not present. Cannot continue".to_red && exit ) unless Dir.exist?(@options[:packer_dir])
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
    if @options[:templates].empty?
      templates = []
      Dir.foreach(@options[:packer_dir]) do |item|
        templates << File.join(@options[:packer_dir], item) if File.extname(item).downcase == '.json'
      end

      if templates.empty?
        puts "No packer templates found in the 'packer' dir. Cannot continue.".to_red
        exit
      end
      templates
    else
      @options[:templates].map { |x| File.join(@options[:packer_dir], x)}
    end
  end

  # run the passed command per packer template
  def execute_command(cmd)
    @templates.each do |template|
      packer = SingelExecutor.new(template)
      puts "Packer template validation for #{template} failed.\n".to_red unless packer.validates?
      begin
        packer.send(cmd)
      rescue NoMethodError
        puts "Action \"#{cmd}\" not found.  Cannot continue".to_red
        exit
      end
    end
  end
end
