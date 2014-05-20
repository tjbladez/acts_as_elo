# encoding: utf-8
$:.push File.expand_path('../lib', __FILE__)
Gem::Specification.new do |s|
  s.name        = 'acts_as_elo'
  s.version     = '1.0.0'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['tjbladez']
  s.email       = ['nick@tjbladez.net']
  s.homepage    = 'http://github.com/tjbladez/acts_as_elo'
  s.summary     = %q{Sophisticated ranking made easy}
  s.description = %q{Provides sophisticated yet easy to understand ranking system with minimum changes to the system}

  # Load Paths...
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ['lib']

  # Dependencies (installed via 'bundle install')...
  s.add_dependency('yajl-ruby', '>= 0.1')
  s.add_development_dependency("bundler", ["~> 1.6.0"])
  s.add_development_dependency("rspec")
end
