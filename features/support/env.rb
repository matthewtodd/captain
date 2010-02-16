require 'pathname'
root = Pathname.new(__FILE__).dirname.parent.parent

$LOAD_PATH.unshift(root.join('lib'))
require 'captain'

Before do
  root.join('tmp').rmtree if root.join('tmp').directory?
  @app = Captain::Application.new
  @app.output_directory = 'tmp'
end
