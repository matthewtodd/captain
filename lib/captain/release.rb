require 'digest'
require 'zlib'

module Captain
  class Release
    attr_reader :architecture
    attr_reader :codename
    attr_reader :components

    def initialize(codename, architecture, packages)
      @codename     = codename
      @architecture = architecture
      @components   = organize_into_components(packages)
      @packages     = packages.sort_by { |p| p.filename }
    end

    def copy_to(directory, config)
      directory = Pathname.new(directory)

      @packages.each   { |p| p.copy_to(directory) }
      @components.each { |c| c.copy_to(directory.join('dists', @codename)) }

      Resource.template('release.erb', binding).copy_to(directory.join('dists', @codename, 'Release'))
    end

    private

    def organize_into_components(packages)
      packages.group_by { |package| package.component }.map do |name, packages|
        Component.new(name, @architecture, packages)
      end
    end

    def deb_components
      @components.reject { |c| c.udeb? }
    end

    class Component
      attr_reader :name
      attr_reader :files

      def initialize(name, architecture, packages)
        @name    = name
        manifest = manifest(packages)
        @files   = []
        @files.push Manifest.new("#{name}/binary-#{architecture}/Release", Resource.template('release_component.erb', binding).contents)
        @files.push Manifest.new("#{name}/binary-#{architecture}/Packages", manifest)
        @files.push Manifest.new("#{name}/binary-#{architecture}/Packages.gz", gzip(manifest))
      end

      def copy_to(directory)
        files.each { |file| file.copy_to(directory) }
      end

      def udeb?
        name =~ /debian-installer/
      end

      private

      def manifest(packages)
        io = StringIO.new
        packages.each { |package| package.copy_manifest_to(io) }
        io.string
      end

      def gzip(string)
        io = StringIO.new
        gzip = Zlib::GzipWriter.new(io)
        gzip.write(string)
        gzip.close
        io.string
      end

      class Manifest
        attr_reader :path

        def initialize(path, contents)
          @path     = path
          @contents = contents
        end

        def copy_to(directory)
          file = Pathname.new(directory).join(path)
          file.dirname.mkpath
          file.open('w') { |io| io.write(@contents) }
        end

        def checksum(algorithm)
          Digest(algorithm).hexdigest(@contents)
        end

        def size
          @contents.bytesize
        end
      end
    end

  end
end
