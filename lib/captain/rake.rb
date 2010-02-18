module Captain
  class Rake
    def initialize
      @app = Application.new
      yield @app.configuration if block_given?
      define
    end

    def define
      file @app.iso_image_path do
        @app.run
      end

      task :captain => @app.iso_image_path
    end
  end
end
