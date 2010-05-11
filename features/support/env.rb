module Accessors
  attr_accessor :shell
end

World(Accessors)

Before do
  self.shell = ShellHelper.new
end
