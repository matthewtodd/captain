require 'tmpdir'

module Helpers
  def append_to_path(directory)
    ENV['PATH'] = "#{ENV['PATH']}:#{directory}"
  end

  def create_a_vmware_configuration_file(path, hard_disk_path, cdrom_iso_path)
    File.open(path, 'w') do |config|
      config.write ERB.new(File.read(__FILE__).split('__END__').last.strip).result(binding)
    end
  end

  def create_an_empty_hard_disk_image(path)
    append_to_path('/Applications/Q.app/Contents/MacOS')
    system("qemu-img create -f vmdk #{path} 512M > /dev/null") || raise('Could not create image.')
  end

  def launch_vmware(config_path)
    append_to_path('/Library/Application Support/VMware Fusion')
    system("vmrun -T fusion start #{config_path} gui") || raise('VMware Error.')
  end

  def make_a_new_temporary_directory
    directory = Dir.mktmpdir
    # whacking the temp directory hamstrings vmware! is there something else we can do?
    # at_exit { FileUtils.remove_entry_secure(directory) }
    directory
  end
end

World(Helpers)

__END__
config.version = "8"
virtualHW.version = "7"
memsize = "512"
ide0:0.present = "TRUE"
ide0:0.fileName = "<%= hard_disk_path %>"
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
workingDir = "<%= File.dirname(path) %>"
