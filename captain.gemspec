# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{captain}
  s.version = "0.1.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Matthew Todd"]
  s.date = %q{2009-08-24}
  s.default_executable = %q{captain}
  s.email = %q{matthew.todd@gmail.com}
  s.executables = ["captain"]
  s.extra_rdoc_files = ["README.rdoc"]
  s.files = ["Rakefile", "captain.gemspec", "README.rdoc", "bin/captain", "examples/chef_client.rb", "features/installer_image.feature", "features/steps", "features/steps/captain_steps.rb", "features/support", "features/support/env.rb", "features/support/helpers.rb", "lib/captain", "lib/captain/application.rb", "lib/captain/image.rb", "lib/captain/package.rb", "lib/captain/package_list.rb", "lib/captain/release.rb", "lib/captain/remote.rb", "lib/captain/resource.rb", "lib/captain.rb", "resources/disk_base_components.erb", "resources/disk_base_installable.erb", "resources/disk_cd_type.erb", "resources/disk_info.erb", "resources/disk_udeb_include.erb", "resources/isolinux.bin", "resources/isolinux.cfg", "resources/preseed.seed.erb", "resources/release.erb", "resources/release_component.erb"]
  s.rdoc_options = ["--main", "README.rdoc", "--title", "captain-0.1.2", "--inline-source"]
  s.require_paths = ["lib"]
  s.requirements = ["mkisofs"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Builds an Ubuntu installation CD just as you like it.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<matthewtodd-shoe>, [">= 0"])
      s.add_development_dependency(%q<cucumber>, [">= 0"])
    else
      s.add_dependency(%q<matthewtodd-shoe>, [">= 0"])
      s.add_dependency(%q<cucumber>, [">= 0"])
    end
  else
    s.add_dependency(%q<matthewtodd-shoe>, [">= 0"])
    s.add_dependency(%q<cucumber>, [">= 0"])
  end
end
