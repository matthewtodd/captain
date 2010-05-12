require 'pathname'

module Captain
  VERSION = '0.3.0'

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

  def self.datadir
    @@datadir ||= begin
      datadir = RbConfig.datadir('captain')
      if !File.exist?(datadir)
        warn "WARN: #{datadir} does not exist.\n  Trying again with relative data directory..."
        datadir = File.expand_path('../../data/captain', __FILE__)
      end
      Pathname.new(datadir)
    end
  end
end
