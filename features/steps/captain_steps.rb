Given /^the following (.+):$/ do |path, contents|
  # FIXME Dir.pwd can become '.' with Bundler 0.9.8
  shell.create_file(path, bundler.add_path_for('captain', Dir.pwd).munge_gemfile(contents))
end

When /^I run "(.+)" inside the bundle$/ do |command|
  shell.run(bundler.exec(command))
end

When /^I create a VMware virtual machine named "([^\"]*)" using "([^\"]*)"$/ do |name, iso_image|
  vmware.create(name, iso_image)
end

Then /^I should be able to open "([^\"]*)"$/ do |path|
  shell.open(path)
end
