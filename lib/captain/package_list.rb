module Captain
  class PackageList
    def initialize(sources, architecture, tasks, selectors)
      @sources      = sources
      @architecture = architecture
      @tasks        = tasks
      @selectors    = selectors
    end

    def copy_to(directory, configuration)
      capture_version_number(@sources.first)
      each_release { |release| release.copy_to(directory, configuration) }
    end

    private

    def capture_version_number(repository)
      mirror, codename, *components = repository.split(' ')
      @version = Remote.release_file(mirror, codename).grep(/^Version: /).first.split(/\s+/).last.strip
    end

    def each_release
      winnow_down(deb_packages).concat(udeb_packages).group_by { |package| package.codename }.each do |codename, packages|
        yield Release.new(codename, @version, @architecture, packages)
      end
    end

    def winnow_down(packages)
      selected_by_task, remaining_by_task  = select_packages_by_task(packages)
      selected_by_name, remaining_by_name  = select_packages_by_name(remaining_by_task)
      selected_by_dependencies             = select_packages_by_dependencies(remaining_by_name, selected_by_name)

      selected_by_task.concat(selected_by_name).concat(selected_by_dependencies)
    end

    def select_packages_by_task(pool)
      pool.partition { |package| !package.tasks.intersection(@tasks).empty? }
    end

    def select_packages_by_name(pool, names=@selectors)
      pool.partition { |package| !package.name_and_provides.intersection(names).empty? }
    end

    def select_packages_by_dependencies(pool, dependent_packages)
      if dependent_packages.empty?
        []
      else
        selected, remaining = select_packages_by_name(pool, dependencies_of(dependent_packages))
        selected + select_packages_by_dependencies(remaining, selected)
      end
    end

    def dependencies_of(packages)
      # We have todo this goofy inject instead of a simple flatten because the dependencies are returned as Sets.
      packages.map { |package| package.required_and_recommended_dependencies }.inject { |all, each| all.merge(each) }
    end

    def deb_packages
      deb_components.map { |component| component.packages }.flatten
    end

    def deb_components
      @sources.map do |source|
        mirror, codename, *components = source.split(' ')
        components.map do |component|
          ComponentManifest.new(mirror, codename, component, @architecture)
        end
      end.flatten
    end

    def udeb_packages
      mirror, codename, *components = @sources.first.split(' ')
      ComponentManifest.new(mirror, codename, 'main/debian-installer', @architecture).packages
    end

    class ComponentManifest
      include Enumerable

      def initialize(mirror, codename, component, architecture)
        @mirror       = mirror
        @codename     = codename
        @component    = component
        @architecture = architecture
      end

      def each
        buffer = []
        open_stream.each_line do |line|
          if line == "\n"
            yield Package.new(@mirror, @codename, @component, buffer.join)
            buffer.clear
          else
            buffer.push(line)
          end
        end
      end

      alias_method :packages, :to_a

      private

      def open_stream
        Remote.component_file(@mirror, @codename, @component, @architecture, 'Packages.gz').gunzipped
      end
    end

  end
end
