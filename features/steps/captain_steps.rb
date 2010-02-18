Given /^the following (.+):$/ do |path, contents|
  shell.create_file(path, bundler.add_path_for('captain', Dir.pwd).munge_gemfile(contents))
end

When /^I run "(.+)" inside the bundle$/ do |command|
  shell.run(bundler.exec(command))
end

Then /^I should be able to launch the resulting image "(.+)"$/ do |image_path|
  vmware.launch(image_path)
end
