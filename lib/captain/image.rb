require 'pathname'

module Captain
  class Image
    def initialize(base_directory)
      @base_directory = base_directory
    end

    def burn(path)
      path = Pathname.new(path)
      path.parent.mkpath unless path.parent.directory?

      system('mkisofs',
        '-boot-info-table',
        '-boot-load-size', '4',
        '-cache-inodes',
        '-eltorito-boot', 'isolinux/isolinux.bin',
        '-eltorito-catalog', 'isolinux/boot.cat',
        '-full-iso9660-filenames',
        '-joliet',
        '-no-emul-boot',
        '-output', path,
        '-rational-rock',
        '-volid', 'Name',
        @base_directory) || raise('Error creating iso image.')
    end
  end
end
