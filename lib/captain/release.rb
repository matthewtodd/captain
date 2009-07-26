require 'zlib'

module Captain
  class Release
    def initialize(codename, architecture, packages)
      @codename     = codename
      @architecture = architecture
      @components   = organize_into_components(packages)
    end

    def copy_to(directory)
      @components.each { |component| component.copy_to(directory) }
      # TODO write Release file
    end

    private

    def organize_into_components(packages)
      components = []
      packages.group_by { |package| package.component }.each do |name, packages|
        components.push(Component.new(@codename, name, @architecture, packages))
      end
      components
    end

    class Component
      def initialize(codename, name, architecture, packages)
        @codename     = codename
        @name         = name
        @architecture = architecture
        @packages     = packages
      end

      def copy_to(directory)
        @packages.each { |package| package.copy_to(directory) }

        full_manifest_path = File.join(directory, 'dists', @codename, manifest_path)
        FileUtils.mkpath(File.dirname(full_manifest_path))
        File.open(full_manifest_path, 'w') do |file|
          begin
            stream = Zlib::GzipWriter.new(file)
            @packages.each { |package| package.copy_manifest_to(stream) }
          ensure
            stream.close
          end
        end
      end

      def manifest_path
        "#{@name}/binary-#{@architecture}/Packages.gz"
      end
    end

  end
end
