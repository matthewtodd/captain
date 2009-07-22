Feature: Installer Image
  In order to install a custom Ubuntu system
  As a perennial yak-shaver
  I want to assemble my own installer CD

  Scenario: Default Configuration
     When I run captain
     Then I should be able to launch the resulting image "ubuntu-9.04-captain-i386.iso"
