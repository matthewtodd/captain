module Captain
  class PackageList
    def initialize(sources, architecture, tasks, selectors)
      @sources      = sources
      @architecture = architecture
      @tasks        = tasks
      @selectors    = selectors
    end

    def copy_to(directory)
      releases = organize_into_releases(select(all_packages))
      releases.each { |release| release.copy_to(directory) }
    end

    private

    def all_packages
      packages = []
      with_each_source_component do |mirror, codename, component|
        component_manifest(mirror, codename, component).each_package do |manifest|
          packages.push(Package.new(mirror, codename, component, manifest))
        end
      end
      packages
    end

    def select(packages)
      selected_by_task, remaining_by_task  = select_packages_by_task(packages)
      selected_by_name, remaining_by_name  = select_packages_by_name(remaining_by_task)
      selected_by_dependencies             = select_packages_by_dependencies(remaining_by_name, selected_by_name)

      selected_by_task.concat(selected_by_name).concat(selected_by_dependencies)
    end

    def organize_into_releases(packages)
      releases = []
      packages.group_by { |package| package.codename }.each do |codename, packages|
        releases.push(Release.new(codename, packages))
      end
      releases
    end

    def with_each_source_component
      @sources.each do |source|
        mirror, codename, *components = source.split(' ')
        components.each { |component| yield mirror, codename, component }
      end
    end

    def component_manifest(mirror, codename, component)
      stream = Remote.component_file(mirror, codename, component, @architecture, 'Packages.gz').gunzipped
      ComponentManifestReader.new(stream)
    end

    def select_packages_by_task(packages)
      packages.partition { |package| !package.tasks.intersection(@tasks).empty? }
    end

    def select_packages_by_name(packages, names=@selectors)
      packages.partition { |package| !package.name_and_provides.intersection(names).empty? }
    end

    def select_packages_by_dependencies(packages, dependent_packages)
      if dependent_packages.empty?
        []
      else
        dependencies        = dependent_packages.map { |package| package.required_and_recommended_dependencies }.inject { |all, each| all.merge(each) }
        selected, remaining = select_packages_by_name(packages, dependencies)
        selected + select_packages_by_dependencies(remaining, selected)
      end
    end

    class ComponentManifestReader
      def initialize(stream)
        @stream = stream
        @buffer = []
      end

      def each_package
        @stream.each_line do |line|
          if line == "\n"
            yield @buffer.join
            @buffer.clear
          else
            @buffer.push(line)
          end
        end
      end
    end

  end
end
