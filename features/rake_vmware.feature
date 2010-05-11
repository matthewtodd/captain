Feature: Rake VMware Task
  In order to manually test my ISO Image
  As a perennial yak-shaver
  I want some help booting it up in VMware

  @wip
  Scenario: Running from rake
    Given the following Gemfile:
      """
      source :rubygems
      gem 'captain'
      gem 'rake'
      """
    And the following Rakefile:
      """
      require 'captain'

      iso_task = Captain::Rake::ISO.new

      Captain::Rake::VMware.new do |task|
        task.iso_image = iso_task.config.iso_image_path
      end
      """
    When I run "rake vmware" inside the bundle
    Then I should be able to open "vm.vmwarevm"
