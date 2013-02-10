require "fog"
require "logger"

module StaticSync
  class Storage

    def initialize(config)
      @config = config

      validate_credentials!
    end

    def exists?(id)
      ids.include?(id)
    end

    def ids
      @ids ||= begin
        result = []
        remote_directory.files.each do |file|
          result << [file.key, file.etag]
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
