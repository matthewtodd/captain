require 'captain'

class VMwareHelper
  attr_reader :shell

  def initialize(shell)
    @shell = shell
  end

  def create(name, iso_image)
    shell.chdir do
      vm = Captain::VM::VMware.new
      vm.name      = name
      vm.iso_image = iso_image
      vm.create
    end
  end
end
