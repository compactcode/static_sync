require "fog"
require "logger"

module StaticSync
  class Storage

    class Version < Struct.new(:path, :etag)
    end

    def initialize(config)
      @config = config

      validate_credentials!
    end

    def has_file?(version)
      file_versions.map(&:path).include?(version.path)
    end

    def has_version?(version)
      file_versions.include?(version)
    end

    def file_versions
      @file_versions ||= begin
        result = []
        remote_directory.files.each do |file|
          result << Version.new(file.key, file.etag)
        end
        result
      end
    end

    def create(headers)
      remote_directory.files.create(headers)
    end

    private

    def remote_directory
      @config.storage.directories.new(:key => @config.target)
    end

    def validate_credentials!
      @config.storage.get_bucket(@config.target)
    end

  end
end
