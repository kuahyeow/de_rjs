Gem::Specification.new do |spec|
  spec.name     = 'de_rjs'
  spec.version  = '0.4.3'
  spec.summary  = 'de-RJS your application'
  spec.homepage = 'http://github.com/kuahyeow/de_rjs'
  spec.author   = 'Thong Kuah'
  spec.email    = 'kuahyeow@gmail.com'
  spec.license  = 'MIT'

  spec.files = %w(README.md Rakefile Gemfile) + Dir['bin/*', 'lib/**/*', 'test/**/*']
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency('rails', '>= 4.2', '< 5.1')
  spec.add_runtime_dependency('parser', '>= 2.3.1.2', '< 2.5')
  spec.add_development_dependency('byebug', '~> 9.0')
end
