$:.unshift File.expand_path('../lib', __FILE__)
require 'captain/version'

# Feel free to change whatever you like! This file is yours now.
Gem::Specification.new do |spec|
  spec.name    = 'captain'
  spec.version = Captain::VERSION

  spec.summary = 'A Ruby-based understaing of APT repositories.'
  spec.description = <<-END.gsub(/^ */, '')
    #{spec.summary}

    Provides a rake task to build a custom installation disk that pulls in just
    the packages you request, allows bundling of arbitrary files, and provides
    hooks into common preseeding options.
  END

  spec.author = 'Matthew Todd'
  spec.email  = 'matthew.todd@gmail.com'
  spec.homepage = 'http://github.com/matthewtodd/captain'

  spec.requirements = ['mkisofs']
  spec.add_runtime_dependency 'rake'
  spec.add_runtime_dependency 'virtualbox'
  spec.add_development_dependency 'cucumber'
  spec.add_development_dependency 'shoe'

  # The kooky &File.method(:basename) trick keeps us from accidentally
  # shadowing a variable named "file" in the context that evaluates this
  # gemspec. I actually ran into this problem with Bundler!
  spec.files            = Dir['**/*.rdoc', 'bin/*', 'data/**/*', 'ext/**/*.{rb,c}', 'lib/**/*.rb', 'man/**/*', 'test/**/*.rb']
  spec.executables      = Dir['bin/*'].map &File.method(:basename)
  spec.extensions       = Dir['ext/**/extconf.rb']
  spec.extra_rdoc_files = Dir['**/*.rdoc', 'ext/**/*.c']
  spec.test_files       = Dir['test/**/*_test.rb']

  spec.rdoc_options = %W(
    --main README.rdoc
    --title #{spec.full_name}
    --inline-source
    --webcvs http://github.com/matthewtodd/captain/blob/v#{spec.version}/
  )
end
