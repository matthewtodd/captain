Given /^the following (.+):$/ do |path, contents|
  shell.create_file(path, bundler.munge_gemfile_for('captain', contents))
end

When /^I run "(.+)" inside the bundle$/ do |command|
  shell.run(bundler.exec(command))
end

Then /^I should be able to launch the resulting image "(.+)"$/ do |image_path|
  vmware.launch(image_path, shell)
end
