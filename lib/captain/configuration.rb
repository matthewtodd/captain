require 'tmpdir'

module Captain
  class Configuration
    def initialize
      self.architecture          = 'i386'
      self.include_packages      = ['linux-server', 'language-support-en', 'grub']
      self.install_packages      = []
      self.label                 = 'Ubuntu'
      self.output_directory      = '.'
      self.post_install_commands = []
      self.repositories          = ['http://us.archive.ubuntu.com/ubuntu jaunty main restricted']
      self.tasks                 = ['minimal', 'standard']
      self.tag                   = 'captain'
      self.version               = '9.04'
      self.working_directory     = temporary_directory

      load_file
    end

    attr_accessor :architecture
    attr_accessor :install_packages
    attr_accessor :label
    attr_accessor :output_directory
    attr_accessor :post_install_commands
    attr_accessor :repositories
    attr_accessor :tag
    attr_accessor :version
    attr_accessor :working_directory

    def include_packages
      @include_packages.dup
    end

    def include_packages=(packages)
      @include_packages ||= []
      @include_packages.push(*packages)
      @include_packages.uniq!
    end

    def tasks
      @tasks.dup
    end

    def tasks=(tasks)
      @tasks ||= []
      @tasks.push(*tasks)
      @tasks.uniq!
    end

    def installer_repository_mirror_and_codename
      repositories.first.split(' ').slice(0, 2)
    end

    def iso_image_name
      "#{label} #{version} #{tag.capitalize}"
    end

    def iso_image_path
      iso_image_basename = "#{label}-#{version}-#{tag}-#{architecture}.iso".downcase

      Pathname.new(output_directory).
              join(iso_image_basename).cleanpath.to_s
    end

    private

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
  end
end
