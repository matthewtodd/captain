require 'pathname'

module Captain
  class Resource
    PATH = Pathname.new(File.dirname(__FILE__)).join('..', '..', 'resources')

    def self.file(name)
      new(name)
    end

    def initialize(name)
      @name = name
    end

    def copy_to(*paths)
      path = File.join(paths)
      FileUtils.mkpath(File.dirname(path))
      File.open(path, 'w') { |f| f.write(PATH.join(@name).read) }
    end
  end
end