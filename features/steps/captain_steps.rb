When /^I run captain$/ do
  @app.run
end

# Before, I had stubbed out all sorts of stuff with ShamRack. That got to be a
# lot to maintain. So, now I just make sure I can actually boot up the
# installation system.
Then /^I should be able to launch the resulting image "(.+)"$/ do |image_name|
  vmware_directory = Pathname.pwd.join(@app.output_directory)
  config_path      = vmware_directory.join('captain.vmx')
  hard_disk_path   = vmware_directory.join('captain.vmdk')
  cdrom_iso_path   = vmware_directory.join(image_name)

  create_a_vmware_configuration_file(config_path, hard_disk_path, cdrom_iso_path)
  create_an_empty_hard_disk_image(hard_disk_path)
  launch_vmware(config_path)
end
