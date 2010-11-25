require 'delegate'
require 'tmpdir'

module Captain
  class Application < DelegateClass(Configuration)
    def configuration
      __getobj__
    end

    def run
      create_bundle_directory
      create_packages
      create_installer_and_its_supporting_files
      create_boot_loader
      create_ubuntu_symlink
      create_iso_image
    end

    private

    # This is a convenient way to put arbitrary content on the disk.
    def create_bundle_directory
      FileUtils.cp_r(bundle_directory, working_directory, :preserve => true) if File.directory?(bundle_directory)
    end

    def create_packages
      PackageList.new(repositories, architecture, tasks, include_packages.concat(install_packages)).copy_to(working_directory, self)
    end

    def create_installer_and_its_supporting_files
      mirror, codename = installer_repository_mirror_and_codename

      Remote.installer_file(mirror, codename, architecture, 'cdrom', 'vmlinuz'  ).copy_to(working_directory, 'install', 'vmlinuz')
      Remote.installer_file(mirror, codename, architecture, 'cdrom', 'initrd.gz').copy_to(working_directory, 'install', 'initrd.gz')

      Resource.template('preseed.seed.erb',          binding).copy_to(working_directory, 'install', 'preseed.seed')
      Resource.template('disk_base_components.erb',  binding).copy_to(working_directory, '.disk', 'base_components')
      Resource.template('disk_base_installable.erb', binding).copy_to(working_directory, '.disk', 'base_installable')
      Resource.template('disk_cd_type.erb',          binding).copy_to(working_directory, '.disk', 'cd_type')
      Resource.template('disk_info.erb',             binding).copy_to(working_directory, '.disk', 'info')
      Resource.template('disk_udeb_include.erb',     binding).copy_to(working_directory, '.disk', 'udeb_include')
    end

    # FIXME adjust isolinux.cfg to provide a boot menu, defaulting to first
    # hard disk, just in case the machine's configured to prefer booting from
    # the CD.
    def create_boot_loader
      Resource.file('isolinux.bin').copy_to(working_directory, 'isolinux', 'isolinux.bin')
      Resource.template('isolinux.erb', binding).copy_to(working_directory, 'isolinux', 'isolinux.cfg')
    end

    def create_ubuntu_symlink
      Dir.chdir(working_directory) do
        FileUtils.symlink('.', 'ubuntu')
      end
    end

    def create_iso_image
      Image.new(working_directory).burn(iso_image_path, iso_image_name)
    end
  end
end
