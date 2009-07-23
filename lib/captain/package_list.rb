module Captain
  class PackageList
    def initialize(sources, architecture, tasks, selectors)
      @sources      = sources
      @architecture = architecture
      @tasks        = tasks
      @selectors    = selectors
      @packages     = []
    end

    def copy_to(directory)
      load_packages
    end

    private

    def load_packages
      with_each_source_component do |mirror, codename, component|
        component_manifest(mirror, codename, component).each_package do |manifest|
          add_package(manifest)
        end
      end
    end

    def with_each_source_component
      @sources.each do |source|
        mirror, codename, *components = source.split(' ')
        components.each { |component| yield mirror, codename, component }
      end
    end

    def component_manifest(mirror, codename, component)
      stream = Remote.component_file(mirror, codename, component, @architecture, 'Packages.gz').gunzipped
      ComponentManifestReader.new(stream)
    end

    def add_package(manifest)
      @packages.push(Package.new(manifest))
    end

    class ComponentManifestReader
      def initialize(stream)
        @stream = stream
        @buffer = []
      end

      def each_package
        @stream.each_line do |line|
          if line == "\n"
            yield @buffer.join
            @buffer.clear
          else
            @buffer.push(line)
          end
        end
      end
    end

  end
end
