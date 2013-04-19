$:.push File.expand_path('../lib', __FILE__)

require 's3_photos_syncing/version'

Gem::Specification.new do |s|
  s.name        = 's3_photos_syncing'
  s.version     = S3PhotosSyncing::VERSION
  s.license     = 'BSD'
  s.authors     = ['Fanatic/IO']
  s.email       = ['contact@fanatic.io']
  s.homepage    = 'https://github.com/fanaticio/s3_photos_syncing'
  s.summary     = 'Fast S3 objects sync from one bucket to another'
  s.description = <<-EOF
    This gem helps you move a large number of S3 objects from one bucket to another.
    It relies on JRuby's excellent implementation of native OS Threads.
  EOF

  s.executables = ['s3_photos_syncing']

  s.add_dependency 'aws-sdk'
  s.add_dependency 'thor'

  s.add_development_dependency 'bundler'
  s.add_development_dependency 'coveralls'
  s.add_development_dependency 'rspec'

  s.files = Dir.glob('{lib}/**/*') + Dir.glob('{bin}/**/*') + %w[CHANGELOG.md README.md]

  s.require_path = 'lib'
end
