$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', 'lib'))
require 'captain'

Before do
  @app = Captain::Application.new
end
