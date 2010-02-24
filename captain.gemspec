# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{captain}
  s.version = "0.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Matthew Todd"]
  s.date = %q{2010-02-24}
  s.email = %q{matthew.todd@gmail.com}
  s.extra_rdoc_files = ["README.rdoc"]
  s.files = ["Rakefile", "lib/captain", "lib/captain/application.rb", "lib/captain/configuration.rb", "lib/captain/image.rb", "lib/captain/package.rb", "lib/captain/package_list.rb", "lib/captain/rake", "lib/captain/rake/iso_task.rb", "lib/captain/rake/vmware_task.rb", "lib/captain/rake.rb", "lib/captain/release.rb", "lib/captain/remote.rb", "lib/captain/resource.rb", "lib/captain/resources", "lib/captain/resources/disk_base_components.erb", "lib/captain/resources/disk_base_installable.erb", "lib/captain/resources/disk_cd_type.erb", "lib/captain/resources/disk_info.erb", "lib/captain/resources/disk_udeb_include.erb", "lib/captain/resources/isolinux.bin", "lib/captain/resources/isolinux.cfg", "lib/captain/resources/preseed.seed.erb", "lib/captain/resources/release.erb", "lib/captain/resources/release_component.erb", "lib/captain/version.rb", "lib/captain/vm", "lib/captain/vm/vmware.rb", "lib/captain/vm.rb", "lib/captain.rb", "README.rdoc", "examples/chef_client.rake", "captain.gemspec", "test/configuration_test.rb", "test/rake", "test/rake/iso_task_test.rb", "test/rake/vmware_task_test.rb", "test/test_helper.rb", "features/rake_iso_task.feature", "features/rake_vmware_task.feature", "features/steps", "features/steps/captain_steps.rb", "features/support", "features/support/bundler.rb", "features/support/env.rb", "features/support/shell.rb", "features/support/vmware.rb"]
  s.rdoc_options = ["--main", "README.rdoc", "--title", "captain-0.2.0", "--inline-source"]
  s.require_paths = ["lib"]
  s.requirements = ["mkisofs"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Builds an Ubuntu installation CD just as you like it.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
