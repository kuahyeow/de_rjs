Gem::Specification.new do |spec|
  spec.name     = 'de_rjs'
  spec.version  = '0.2.0'
  spec.summary  = 'de-RJS your application'
  spec.homepage = 'http://github.com/kuahyeow/jquery-rjs'
  spec.author   = 'Thong Kuah'
  spec.email    = 'kuahyeow@gmail.com'

  spec.files = %w(README Rakefile Gemfile) + Dir['lib/**/*', 'vendor/**/*', 'test/**/*']

  spec.add_dependency('rails', '>= 4.2', '< 5.1')
  spec.add_dependency('parser', '>= 2.3.1.2', '< 2.5')
  spec.add_development_dependency('byebug', '~> 9.0')
end
