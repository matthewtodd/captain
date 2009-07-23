require 'digest'
require 'open-uri'
require 'pathname'
require 'uri'
require 'zlib'

module Captain
  class Remote
    def self.release_file(mirror, codename)
      # TODO verify the Release file with GPG
      new("#{mirror}/dists/#{codename}/Release")
    end

    def self.component_file(mirror, codename, component, architecture, *rest)
      uri    = component_uri(mirror, codename, component, architecture, *rest)
      path   = [component, "binary-#{architecture}", *rest].join('/')
      md5sum = release_file(mirror, codename).grep(%r{^ \w{32}\s+\d+\s+#{path}}).first.split(' ').first
      new(uri, Verifier::MD5.new(md5sum))
    end

    def self.installer_file(mirror, codename, architecture, *rest)
      uri        = installer_uri(mirror, codename, architecture, *rest)
      md5sum_uri = installer_uri(mirror, codename, architecture, 'MD5SUMS')
      md5sum     = new(md5sum_uri).grep(%r{#{rest.join('/')}}).first.split(' ').first
      new(uri, Verifier::MD5.new(md5sum))
    end

    def self.component_uri(mirror, codename, component, architecture, *rest)
      ["#{mirror}/dists/#{codename}/#{component}/binary-#{architecture}", *rest].join('/')
    end

    def self.installer_uri(mirror, codename, architecture, *rest)
      ["#{mirror}/dists/#{codename}/main/installer-#{architecture}/current/images", *rest].join('/')
    end

    include Enumerable

    def initialize(uri, verifier=Verifier::Content.new)
      @uri      = URI.parse(uri)
      @verifier = verifier
      @cache    = Cache::Persistent.new
    end

    def copy_to(*paths)
      path = Pathname.new(File.join(paths))
      path.dirname.mkpath

      open_stream do |stream|
        File.open(path, 'w') do |file|
          Stream.copy(stream, file)
        end
      end
    end

    def each_line
      open_stream do |stream|
        stream.each_line do |line|
          yield line
        end
      end
    end
    alias_method :each, :each_line

    def gunzipped
      Adapter::Gunzip.new(self)
    end

    private

    def open_stream(retry_count=4)
      @cache.open(@uri) do |cache|
        begin
          @verifier.verify(cache)
          yield(cache)
        rescue
          begin
            @uri.open(ProgressMeter.new(@uri).to_open_uri_hash) do |stream|
              @verifier.verify(stream)
              cache.populate(stream)
              yield(cache)
            end
          rescue Exception => exception
            retry_count -= 1
            if retry_count.zero?
              raise exception
            else
              puts "#{exception.message} #{@uri}"
              puts "Trying again... (#{retry_count} more)"
              retry
            end
          end
        end
      end
    end

    module Verifier
      class Content
        def verify(stream)
          raise("No content.") unless stream.read(1)
        ensure
          stream.rewind
        end
      end

      class MD5
        def initialize(expected)
          @expected = expected
          raise("No expected MD5Sum given.") unless @expected
        end

        def verify(stream)
          actual = md5sum(stream)
          raise("MD5Sum mismatch: expected #{@expected} but was #{actual}") unless @expected == actual
        end

        private

        def md5sum(stream)
          digest = Digest::MD5.new
          Stream.copy(stream, digest, :update)
          digest.hexdigest
        end
      end
    end

    module Cache
      class Persistent
        PATH = Pathname.new(ENV['HOME']).join('.captain')

        def open(uri)
          # I didn't expect to have to use string concatenation here, but PATH
          # gets confused when uri.path starts with a /.
          path = PATH.join("#{uri.host}#{uri.path}")
          if path.exist?
            path.open('r+') { |cache| yield populatable(cache) }
          else
            path.dirname.mkpath
            path.open('w+') { |cache| yield populatable(cache) }
          end
        end

        private

        def populatable(stream)
          def stream.populate(other)
            Stream.copy(other, self)
          end
          stream
        end
      end
    end

    class ProgressMeter
      def initialize(uri)
        puts(uri)
      end

      def to_open_uri_hash
        { :content_length_proc => method(:max), :progress_proc => method(:step) }
      end

      def max(size)
        @max = size
      end

      def step(size)
        @current = size
        report
      end

      private

      # TODO report percent complete
      # TODO report time spent
      # TODO report time remaining
      def report
        puts "  #{@current} of #{@max}\e[0F"
      end
    end

    class Stream
      def self.copy(from, to, method = :write)
        buffer = ''
        to.truncate(0) if to.respond_to?(:truncate)
        to.send(method, buffer) while from.read(16384, buffer)
      ensure
        from.rewind
        to.rewind if to.respond_to?(:rewind)
      end
    end

    module Adapter
      class Gunzip
        include Enumerable

        def initialize(stream)
          @stream = stream
        end

        def each_line
          open_stream do |stream|
            stream.each_line do |line|
              yield line
            end
          end
        end
        alias_method :each, :each_line

        private

        def open_stream
          @stream.send(:open_stream) do |stream|
            yield Zlib::GzipReader.new(stream)
          end
        end
      end
    end

  end
end