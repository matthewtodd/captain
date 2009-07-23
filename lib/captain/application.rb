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
      assemble_installer
      assemble_boot_loader
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

    def assemble_installer
      mirror, codename = installer.split(' ')
      Remote.installer_file(mirror, codename, architecture, 'cdrom', 'vmlinuz').copy_to(working_directory, 'install', 'vmlinuz')
      Remote.installer_file(mirror, codename, architecture, 'cdrom', 'initrd.gz').copy_to(working_directory, 'install', 'initrd.gz')
    end

    def assemble_boot_loader
      Resource.file('isolinux.bin').copy_to(working_directory, 'isolinux', 'isolinux.bin')
      Resource.file('isolinux.cfg').copy_to(working_directory, 'isolinux', 'isolinux.cfg')
    end

    def create_iso_image
      Image.new(working_directory).burn(iso_image_path)
    end

    def iso_image_path
      File.join(output_directory, "#{label.downcase}-#{version}-#{tag}-#{architecture}.iso")
    end

    def load_default_configuration
      @configuration = Hash.new

      architecture      'i386'
      installer         'http://us.archive.ubuntu.com/ubuntu jaunty'
      label             'Ubuntu'
      output_directory  '.'
      repositories      ['http://us.archive.ubuntu.com/ubuntu jaunty main']
      selectors         ['^standard']
      tag               'captain'
      version           '9.04'
      working_directory 'image'
    end

    def load_configuration
      instance_eval(File.read('config/captain.rb')) if File.exist?('config/captain.rb')
    end
  end
end