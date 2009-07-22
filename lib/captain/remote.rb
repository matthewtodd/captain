require 'open-uri'
require 'pathname'
require 'uri'

module Captain
  class Remote
    def self.cdrom_installer(mirror, codename, architecture, file)
      md5sums = Hash.new
      new("#{mirror}/dists/#{codename}/main/installer-#{architecture}/current/images/MD5SUMS").each_line do |line|
        md5sum, path = line.split(' ')
        md5sums[path.strip] = md5sum
      end

      verifier = Verifier::MD5.new(md5sums["./cdrom/#{file}"])
      new("#{mirror}/dists/#{codename}/main/installer-#{architecture}/current/images/cdrom/#{file}", verifier)
    end

    def initialize(uri, verifier=Verifier::Content.new)
      @uri      = URI.parse(uri)
      @verifier = verifier
      @cache    = Cache::Persistent.new
    end

    def copy_to(*paths)
      open_stream do |stream|
        File.open(File.join(paths, 'w')) do |file|
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
              puts "Trying again... (#{count} more)"
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
          @expected
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
        to.rewind
      end
    end

  end
end