require "fog"
require "logger"

require_relative "meta"

module StaticSync
  class Storage

    def initialize(config)
      @config = config
      @meta   = Meta.new(config)
    end

    def sync
      verify_remote_directory
      remote_keys = []
      remote_directory.files.each do |file|
        remote_keys << [file.key, file.etag]
      end
      Dir.chdir(@config.source) do
        local_filtered_files.each do |file|
          current_file     = @meta.for(file)
          current_file_key = [current_file[:key], current_file[:etag]]

          unless remote_keys.include?(current_file_key)
            log.info("Uploading #{file}") if @config.log
            begin
              remote_directory.files.create(current_file)
            rescue => error
              log.error("Failed to upload #{file}")
              raise error
            end
          end
        end
      end
    end

    private

    def local_filtered_files
      local_files.reject do |file|
        file =~ Regexp.new(@config.ignored) if @config.ignored
      end
    end

    def local_files
      Dir.glob("**/*.*").reject do |file|
        File.directory?(file)
      end
    end

    def remote_directory
      @config.storage.directories.new(:key => @config.storage_directory)
    end

    def verify_remote_directory
      @config.storage.get_bucket(@config.storage_directory)
    end

    def log
      @log ||= begin
        logger = Logger.new(STDOUT)
        logger.formatter = proc do |severity, datetime, progname, msg|
            "#{datetime}: #{severity} -- #{msg}\n"
        end
        logger
      end
    end

  end
end
