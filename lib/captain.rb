require 'captain/version'

# TODO Rubygems 1.5.0 deprecated RbConfig.datadir. For now, I'm going to
# introduce this spurious dependency on Rubygems, so that Gem.datadir will be
# available, but I'd love to find a better solution.
require 'rubygems'

module Captain
  autoload :Application,   'captain/application'
  autoload :Configuration, 'captain/configuration'
  autoload :Finder,        'captain/finder'
  autoload :Image,         'captain/image'
  autoload :Package,       'captain/package'
  autoload :PackageList,   'captain/package_list'
  autoload :Rake,          'captain/rake'
  autoload :Release,       'captain/release'
  autoload :Remote,        'captain/remote'
  autoload :Resource,      'captain/resource'
  autoload :VM,            'captain/vm'

  def self.datadir
    Gem.datadir('captain')
  end
end
