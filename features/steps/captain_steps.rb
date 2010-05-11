Given /^the following (.+):$/ do |path, contents|
  shell.create_file(path, contents)
end

When /^I run "(.+)"$/ do |command|
  shell.run(command)
end

When /^I create a VMware virtual machine at "([^\"]*)" using "([^\"]*)"$/ do |name, iso_image|
  vmware.create(name, iso_image)
end

Then /^I should be able to open "([^\"]*)"$/ do |path|
  shell.open(path)
end
