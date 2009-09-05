require 'tmpdir'

module Captain
  class Application
    def self.run
      new.run
    end

    def initialize
      load_default_configuration
      load_configuration
    end

    def run
      create_bundle_directory
      create_packages
      create_installer_and_its_supporting_files
      create_boot_loader
      create_ubuntu_symlink
      create_iso_image
    end

    def method_missing(symbol, *args)
      if args.length > 0
        @configuration[symbol] = args.first
      elsif @configuration.has_key?(symbol)
        @configuration[symbol]
      else
        super
      end
    end

    private

    # This is a convenient way to put arbitrary content on the disk.
    def create_bundle_directory
      FileUtils.cp_r('bundle', working_directory) if File.directory?('bundle')
    end

    def create_packages
      PackageList.new(repositories, architecture, tasks, include_packages.concat(install_packages)).copy_to(working_directory, self)
    end

    def create_installer_and_its_supporting_files
      mirror, codename = installer_repository_mirror_and_codename

      Remote.installer_file(mirror, codename, architecture, 'cdrom', 'vmlinuz'  ).copy_to(working_directory, 'install', 'vmlinuz')
      Remote.installer_file(mirror, codename, architecture, 'cdrom', 'initrd.gz').copy_to(working_directory, 'install', 'initrd.gz')

      Resource.template('preseed.seed.erb',          template_binding).copy_to(working_directory, 'install', 'preseed.seed')
      Resource.template('disk_base_components.erb',  template_binding).copy_to(working_directory, '.disk', 'base_components')
      Resource.template('disk_base_installable.erb', template_binding).copy_to(working_directory, '.disk', 'base_installable')
      Resource.template('disk_cd_type.erb',          template_binding).copy_to(working_directory, '.disk', 'cd_type')
      Resource.template('disk_info.erb',             template_binding).copy_to(working_directory, '.disk', 'info')
      Resource.template('disk_udeb_include.erb',     template_binding).copy_to(working_directory, '.disk', 'udeb_include')
    end

    # FIXME adjust isolinux.cfg to provide a boot menu, defaulting to first
    # hard disk, just in case the machine's configured to prefer booting from
    # the CD.
    def create_boot_loader
      Resource.file('isolinux.bin').copy_to(working_directory, 'isolinux', 'isolinux.bin')
      Resource.file('isolinux.cfg').copy_to(working_directory, 'isolinux', 'isolinux.cfg')
    end

    def create_ubuntu_symlink
      Dir.chdir(working_directory) do
        FileUtils.symlink('.', 'ubuntu')
      end
    end

    def create_iso_image
      Image.new(working_directory).burn(iso_image_path, iso_image_name)
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

    def template_binding
      binding
    end

    def load_default_configuration
      @configuration = Hash.new

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

    def load_configuration
      instance_eval(File.read('config/captain.rb')) if File.exist?('config/captain.rb')
    end

    def temporary_directory
      temporary_directory = Dir.mktmpdir('captain')
      at_exit { FileUtils.remove_entry_secure(temporary_directory) }
      temporary_directory
    end
  end
end
