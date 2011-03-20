module Captain
  class Finder
    def initialize(*paths)
      @paths = paths
    end

    def path(name)
      paths(name).find(not_found(name)) { |path| File.exist?(path) }
    end

    private

    def not_found(name)
      lambda { raise(Errno::ENOENT.new(name)) }
    end

    def paths(name)
      @paths.map { |path| File.join(path, name) }
    end
  end
end
