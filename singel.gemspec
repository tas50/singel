Gem::Specification.new do |s|
  s.name        = 'singel'
  s.version     = '0.2.5'
  s.date        = Date.today.to_s
  s.platform = Gem::Platform::RUBY
  s.extra_rdoc_files = ['README.md', 'LICENSE']
  s.summary     = 'Unified system image creation using Packer'
  s.description = s.summary
  s.authors     = ['Tim Smith']
  s.email       = 'tsmith@chef.io'
  s.homepage    = 'http://www.github.com/tas50/singel'
  s.license     = 'Apache-2.0'

  s.required_ruby_version = '>= 2.1.0'
  s.add_dependency 'aws-sdk-core'
  s.add_development_dependency 'rake', '~> 11.0'
  s.add_development_dependency 'rubocop', '~> 0.42.0'

  s.files         = `git ls-files -z`.split("\x0")
  s.executables   = s.name
  s.require_paths = ['lib']
  s.extra_rdoc_files = ['README.md']
  s.rdoc_options = ['--line-numbers', '--inline-source', '--title', 'singel', '--main', 'README.md']
end
