When /^I run captain$/ do
  @app.output_directory(make_a_new_temporary_directory)
  @app.working_directory(make_a_new_temporary_directory)
  @app.run
end

Then /^I should be able to launch the resulting image "(.+)"$/ do |image_name|
  vmware_directory = make_a_new_temporary_directory
  config_path      = File.join(vmware_directory, 'captain.vmx')
  hard_disk_path   = File.join(vmware_directory, 'captain.vmdk')
  cdrom_iso_path   = File.join(@app.output_directory, image_name)

  create_a_vmware_configuration_file(config_path, hard_disk_path, cdrom_iso_path)
  create_an_empty_hard_disk_image(hard_disk_path)
  launch_vmware(config_path)
end
