Feature: Repositories
  In order to make a nice installation disk
  As a developer
  I want to assemble packages from various repositories

  Scenario: Default Configuration
     When I run captain
     Then I should be able to launch the resulting image "ubuntu-9.04-captain-i386.iso"
