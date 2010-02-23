require 'delegate'
require 'erb'

class VMwareHelper
  attr_reader :shell

  def initialize(shell)
    @shell = shell
  end

  def create(path, cdrom_image_path)
    VirtualMachine.new(path, cdrom_image_path).create(shell)
  end

  def open(path)
    puts "Opening VMware. Cucumber will resume once VMware quits."
    shell.run "open -W -n #{path}"
  end

  private

  class VirtualMachine
    attr_reader :display_name
    attr_reader :operating_system
    attr_reader :base_path
    attr_reader :config_path
    attr_reader :hard_disk_path
    attr_reader :nvram_path
    attr_reader :cdrom_image_path

    def initialize(base_path, cdrom_image_path, name='cucumber', operating_system='ubuntu')
      @display_name     = name.capitalize
      @operating_system = operating_system

      @base_path        = Pathname.new(base_path)
      @config_path      = @base_path.join("#{name}.vmx")
      @hard_disk_path   = @base_path.join("#{name}.vmdk")
      @nvram_path       = @base_path.join("#{name}.nvram")
      @cdrom_image_path = Pathname.new(cdrom_image_path)
    end

    def create(shell)
      shell.create_file(config_path, config_contents(shell.cwd.join(base_path)))
      shell.run(create_hard_disk_command, :path => vmware_support_path)
    end

    private

    def config_contents(working_directory)
      ERB.new(config_template).result(binding)
    end

    def config_template
      File.read(__FILE__).split('__END__').last.strip
    end

    def create_hard_disk_command
      "vmware-vdiskmanager -c -s 2GB -a lsilogic -t 0 #{hard_disk_path}"
    end

    def vmware_support_path
      '/Library/Application Support/VMWare Fusion'
    end
  end
end

__END__
config.version = "8"
virtualHW.version = "7"
scsi0.present = "TRUE"
scsi0.virtualDev = "lsilogic"
memsize = "512"
scsi0:0.present = "TRUE"
scsi0:0.fileName = "<%= hard_disk_path.relative_path_from(base_path) %>"
ide1:0.present = "TRUE"
ide1:0.fileName = "<%= cdrom_image_path.relative_path_from(base_path) %>"
ide1:0.deviceType = "cdrom-image"
floppy0.present = "FALSE"
ethernet0.present = "TRUE"
usb.present = "TRUE"
sound.present = "FALSE"
displayName = "<%= display_name %>"
guestOS = "<%= operating_system %>"
nvram = "<%= nvram_path.relative_path_from(base_path) %>"
workingDir = "<%= working_directory %>"
