require 'digest'
require 'pathname'
require 'zlib'

module Captain
  class Release
    attr_reader :architecture
    attr_reader :codename
    attr_reader :components
    attr_reader :version

    def initialize(codename, version, architecture, packages)
      @codename     = codename
      @version      = version
      @architecture = architecture
      @components   = organize_into_components(packages)
      @packages     = packages.sort_by { |p| p.filename }
    end

    def copy_to(directory, config)
      directory = Pathname.new(directory)

      @packages.each   { |p| p.copy_to(directory) }
      @components.each { |c| c.copy_to(directory.join('dists', @codename)) }

      Resource.template('Release.erb', binding).copy_to(directory.join('dists', @codename, 'Release'))
    end

    private

    def organize_into_components(packages)
      packages.group_by { |package| package.component }.map do |name, packages|
        Component.new(name, @architecture, packages)
      end
    end

    class Component
      attr_reader :name

      def initialize(name, architecture, packages)
        @name         = name
        @architecture = architecture
        @manifest     = gzipped_manifest(packages)
      end

      def copy_to(directory)
        path = Pathname.new(directory).join(manifest_path)
        path.dirname.mkpath
        path.open('w') { |file| file.write(@manifest) }
      end

      def manifest_checksum(algorithm)
        Digest(algorithm).hexdigest(@manifest)
      end

      def manifest_path
        "#{@name}/binary-#{@architecture}/Packages.gz"
      end

      def manifest_size
        @manifest.length
      end

      private

      def gzipped_manifest(packages)
        buffer = ''
        StringIO.open(buffer) do |stream|
          gzip = Zlib::GzipWriter.new(stream)
          packages.each { |package| package.copy_manifest_to(stream) }
          gzip.close
        end
        buffer
      end
    end

  end
end
