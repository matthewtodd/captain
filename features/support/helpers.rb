require 'erb'

module Helpers
  def append_to_path(directory)
    ENV['PATH'] = "#{ENV['PATH']}:#{directory}" if File.directory?(directory)
  end

  def create_a_vmware_configuration_file(path, hard_disk_path, cdrom_iso_path)
    template = File.read(__FILE__).split('__END__').last.strip

    File.open(path, 'w') do |config|
      config.write ERB.new(template).result(binding)
    end
  end

  def create_an_empty_hard_disk_image(path)
    append_to_path('/Library/Application Support/VMware Fusion')
    system("vmware-vdiskmanager -c -s 2GB -a lsilogic -t 0 #{path}") || raise('Could not create image.')
  end

  def launch_vmware(config_path)
    append_to_path('/Library/Application Support/VMware Fusion')
    system("vmrun -T fusion start #{config_path} gui") || raise('VMware Error.')
  end
end

World(Helpers)

__END__
config.version = "8"
virtualHW.version = "7"
scsi0.present = "TRUE"
scsi0.virtualDev = "lsilogic"
memsize = "512"
scsi0:0.present = "TRUE"
scsi0:0.fileName = "<%= hard_disk_path %>"
ide1:0.present = "TRUE"
ide1:0.fileName = "<%= cdrom_iso_path %>"
ide1:0.deviceType = "cdrom-image"
floppy0.present = "FALSE"
ethernet0.present = "TRUE"
usb.present = "TRUE"
sound.present = "FALSE"
displayName = "Captain - Cucumber"
guestOS = "ubuntu"
nvram = "captain.nvram"
workingDir = "<%= path.dirname %>"
