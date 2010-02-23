require 'captain'

class VMwareHelper
  attr_reader :shell

  def initialize(shell)
    @shell = shell
  end

  def create(path, cdrom_image_path)
    shell.chdir do
      Captain::VM::VMware.new(path, cdrom_image_path).create
    end
  end
end
