require 'delegate'
require 'erb'

class VMwareHelper < DelegateClass(ShellHelper)
  attr_reader :display_name
  attr_reader :operating_system
  attr_reader :config_path
  attr_reader :hard_disk_path
  attr_reader :nvram_path

  def initialize(shell, name='cucumber', operating_system='ubuntu')
    super(shell)

    @display_name     = name.capitalize
    @operating_system = operating_system

    @config_path    = "#{name}.vmx"
    @hard_disk_path = "#{name}.vmdk"
    @nvram_path     = "#{name}.nvram"
  end

  def launch(cdrom_image_path)
    create_file config_path, config_contents(cdrom_image_path, cwd)

    run create_hard_disk_command, :path => vmware_support_path
    run launch_vmware_command,    :path => vmware_support_path

    wait('Will resume once VMWare quits.') do
      Dir.glob('*.lck').empty?
    end
  end

  private

  def config_contents(cdrom_image_path, working_directory)
    ERB.new(config_template).result(binding)
  end

  def config_template
    File.read(__FILE__).split('__END__').last.strip
  end

  def create_hard_disk_command
    "vmware-vdiskmanager -c -s 2GB -a lsilogic -t 0 #{hard_disk_path}"
  end

  def launch_vmware_command
    "vmrun -T fusion start #{config_path} gui"
  end

  def vmware_support_path
    '/Library/Application Support/VMWare Fusion'
  end
end

__END__
config.version = "8"
virtualHW.version = "7"
scsi0.present = "TRUE"
scsi0.virtualDev = "lsilogic"
memsize = "512"
scsi0:0.present = "TRUE"
scsi0:0.fileName = "<%= hard_disk_path %>"
ide1:0.present = "TRUE"
ide1:0.fileName = "<%= cdrom_image_path %>"
ide1:0.deviceType = "cdrom-image"
floppy0.present = "FALSE"
ethernet0.present = "TRUE"
usb.present = "TRUE"
sound.present = "FALSE"
displayName = "<%= display_name %>"
guestOS = "<%= operating_system %>"
nvram = "<%= nvram_path %>"
workingDir = "<%= working_directory %>"
