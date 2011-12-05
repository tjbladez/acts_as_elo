# encoding: utf-8
$:.push File.expand_path('../lib', __FILE__)
Gem::Specification.new do |s|

  # Description Meta...
  s.name        = 'acts_as_elo'
  s.version     = '0.0.1'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['tjbladez']
  s.email       = ['nick@tjbladez.net']
  s.homepage    = 'http://github.com/tjbladez/acts_as_elo'
  s.summary     = %q{A gem implementing an elo ranking.}
  s.description = %q{Allows you to use Elo ranking within your system.}

  # Load Paths...
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  # Dependencies (installed via 'bundle install')...
  s.add_development_dependency("bundler", ["~> 1.0.0"])
  s.add_development_dependency("riot")
end
