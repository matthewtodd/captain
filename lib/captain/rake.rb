module Captain
  class Rake
    attr_reader :app

    def initialize
      @app = Application.new
      yield app if block_given?
      define
    end

    def define
      file app.send(:iso_image_path) do
        app.run
      end
    end
  end
end
