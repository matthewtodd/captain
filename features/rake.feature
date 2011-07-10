Feature: Rake ISO Task
  In order to install a custom Ubuntu system
  As a perennial yak-shaver
  I want to assemble my own installer CD

  Background:
    Given the following Rakefile:
      """
      require 'captain'

      Captain::Rake::ISO.new do |task|
        task.label        = 'Ubuntu'
        task.version      = '10.04'
        task.tag          = 'captain'
        task.architecture = 'i386'

        task.repositories = [
          'http://us.archive.ubuntu.com/ubuntu lucid main restricted'
        ]

        Captain::Rake::VMware.new do |vm|
          vm.iso_image = task.iso_image_path
        end
      end
      """

  Scenario: Running from rake
    When I run "rake vmware"
    Then I should be able to open "vm.vmwarevm"
