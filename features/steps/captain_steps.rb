Given /^the following (.+):$/ do |path, contents|
  # FIXME Dir.pwd can become '.' with Bundler 0.9.8
  shell.create_file(path, bundler.add_path_for('captain', Dir.pwd).munge_gemfile(contents))
end

When /^I run "(.+)" inside the bundle$/ do |command|
  shell.run(bundler.exec(command))
end

When /^I create a VMware virtual machine at "([^\"]*)" using "([^\"]*)"$/ do |path, image_path|
  vmware.create(path, image_path)
end

Then /^I should be able to open "([^\"]*)"$/ do |path|
  vmware.open(path)
end
