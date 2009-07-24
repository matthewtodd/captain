module Captain
  class Release
    def initialize(codename, packages)
      @codename   = codename
      @components = organize_into_components(packages)
    end

    def copy_to(directory)
      @components.each { |component| component.copy_to(directory) }
      # TODO write Release file
    end

    private

    def organize_into_components(packages)
      components = []
      packages.group_by { |package| package.component }.each do |name, packages|
        components.push(Component.new(name, packages))
      end
      components
    end

    class Component
      def initialize(name, packages)
        @name     = name
        @packages = packages
      end

      def copy_to(directory)
        @packages.each { |package| package.copy_to(directory) }
        # TODO write Packages.gz file
      end
    end

  end
end
