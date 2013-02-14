module StaticSync
  class StorageCache

    class Version < Struct.new(:path, :etag)
    end

    def initialize(versions)
      @versions = versions
    end

    def has_file?(file)
      @versions.any? do |version|
        file.path == version.path
      end
    end

    def has_version?(file)
      @versions.any? do |version|
        file.path == version.path && file.etag == version.etag
      end
    end

    def has_conflict?(file)
      @versions.any? do |version|
        file.path == version.path && file.etag != version.etag
      end
    end

  end
end
