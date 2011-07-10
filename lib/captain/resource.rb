require 'erb'

module Captain
  class Resource
    class << self
      attr_accessor :finder

      def file(name)
        new(name)
      end

      def template(name, binding)
        Template.new(name, binding)
      end
    end

    def initialize(name)
      @name = name
    end

    def contents
      File.read(finder.path(@name))
    end

    def copy_to(*paths)
      path = File.join(paths)
      FileUtils.mkpath(File.dirname(path))
      File.open(path, 'w') { |f| f.write(contents) }
    end

    private

    def finder
      Resource.finder
    end

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
