require 'pathname'
root = Pathname.new(__FILE__).dirname.parent.parent

$LOAD_PATH.unshift(root.join('lib'))
require 'captain'

root.join('tmp').rmtree if root.join('tmp').directory?

Before { @app = Captain::Application.new }
