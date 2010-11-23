require 'erb'

module Captain
  class Resource
    def self.file(name)
      new(name)
    end

    def self.template(name, binding)
      Template.new(name, binding)
    end

    def initialize(name)
      @name = name
    end

    def contents
      if @name.include?(File::SEPARATOR)
        File.read(@name)
      else
        Captain.datadir.join(@name).read
      end
    end

    def copy_to(*paths)
      path = File.join(paths)
      FileUtils.mkpath(File.dirname(path))
      File.open(path, 'w') { |f| f.write(contents) }
    end

    private

    class Template < Resource
      def initialize(name, binding)
        super(name)
        @binding = binding
      end

      def contents
        ERB.new(super, nil, '<>').result(@binding)
      end
    end
  end
end
