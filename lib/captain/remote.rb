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
        File.open(File.join(paths, 'wb')) { |file| file.write(stream.read) }
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
            @uri.open(progress_meter) do |stream|
              @verifier.verify(stream)
              cache.populate(stream)
              yield(cache)
            end
          rescue Exception => exception
            retry_count = retry_count - 1
            retry_count.zero? ? raise(exception) : notify_retry(exception.message, retry_count); retry
          ensure
            cache.rewind
          end
        end
      end
    end

    def notify_retry(message, count)
      puts "#{message} #{@uri}"
      puts "Trying again... (#{count} more)"
    end

    def progress_meter
      { } #:content_length_proc => method(:puts), :progress_proc => method(:puts) }
    end

    module Verifier
      class Content
        def verify(stream)
          raise("No content.") if stream.read.length.zero?
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
        ensure
          stream.rewind
        end

        private

        def md5sum(stream)
          digest = Digest::MD5.new
          buffer = ''
          while stream.read(16384, buffer)
            digest.update(buffer)
          end
          digest.hexdigest
        end
      end
    end

    module Cache
      class Persistent
        PATH = Pathname.new(ENV['HOME']).join('.captain')

        def open(uri)
          path = PATH.join("#{uri.host}#{uri.path}")
          path.dirname.mkpath
          path.open('w+') { |cache| yield populatable(cache) }
        end

        private

        def populatable(stream)
          def stream.populate(other)
            truncate(0)
            write(other.read)
          ensure
            rewind
            other.rewind
          end
          stream
        end
      end
    end
  end
end