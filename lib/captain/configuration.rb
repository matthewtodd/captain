require 'tmpdir'

module Captain
  class Configuration
    def initialize
      load_defaults
      load_file
    end

    def installer_repository_mirror_and_codename
      repositories.first.split(' ').slice(0, 2)
    end

    def iso_image_name
      "#{label} #{version} #{tag.capitalize}"
    end

    def iso_image_path
      File.join(output_directory, "#{label}-#{version}-#{tag}-#{architecture}.iso".downcase)
    end

    def respond_to?(method)
      @values.has_key?(method)
    end

    private

    def load_defaults
      @values ||= {}

      architecture          'i386'
      include_packages      ['linux-server', 'language-support-en', 'grub']
      install_packages      []
      label                 'Ubuntu'
      output_directory      '.'
      post_install_commands []
      repositories          ['http://us.archive.ubuntu.com/ubuntu jaunty main restricted']
      tasks                 ['minimal', 'standard']
      tag                   'captain'
      version               '9.04'
      working_directory     temporary_directory
    end

    def load_file(path = 'config/captain.rb')
      if File.exist?(path)
        instance_eval File.read(path)
      end
    end

    def temporary_directory
      temporary_directory = Dir.mktmpdir('captain')
      at_exit { FileUtils.remove_entry_secure(temporary_directory) }
      temporary_directory
    end

    def method_missing(symbol, *args)
      if args.length > 0
        @values[symbol] = args.first
      elsif @values.has_key?(symbol)
        @values[symbol]
      else
        super
      end
    end
  end
end
