module Captain
  class Finder
    def initialize(*paths)
      @paths = paths
    end

    def contents(name)
      if path = find(name)
        File.read(path)
      else
        raise Errno::ENOENT.new(name)
      end
    end

    private

    def find(name)
      paths(name).find { |path| File.file?(path) }
    end

    def paths(name)
      @paths.map { |path| File.join(path, name) }
    end
  end
end
