require 'pathname'

project_root = Pathname.new(__FILE__).dirname.parent.parent
$LOAD_PATH.unshift(project_root.join('lib'))
require 'captain'

project_root.join('tmp').rmtree

Before { @app = Captain::Application.new }
