World(Module.new do
  attr_accessor :bundler
  attr_accessor :shell
  attr_accessor :vmware
end)

Before do
  self.bundler = BundlerHelper.new
  self.shell   = ShellHelper.new('captain-cucumber')
  self.vmware  = VMwareHelper.new(shell)
end
