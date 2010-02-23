require 'captain/version'

module Captain
  autoload :Application,   'captain/application'
  autoload :Configuration, 'captain/configuration'
  autoload :Image,         'captain/image'
  autoload :Package,       'captain/package'
  autoload :PackageList,   'captain/package_list'
  autoload :Rake,          'captain/rake'
  autoload :Release,       'captain/release'
  autoload :Remote,        'captain/remote'
  autoload :Resource,      'captain/resource'
  autoload :VM,            'captain/vm'
end
