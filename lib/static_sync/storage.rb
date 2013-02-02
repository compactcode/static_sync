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
      Dir.chdir(@config.source) do
        local_files.each do |file|
          current_file = @meta.for(file)

          unless remote_files.map(&:etag).include?(current_file[:etag])
            log.info("Uploading #{file}") if @config.log
            begin
              remote_files.create(current_file)
            rescue => error
              log.error("Failed to upload #{file}")
              raise error
            end
          end
        end
      end
    end

    private

    def local_files
      Dir.glob("**/*.*").reject do |file|
        File.directory?(file)
      end
    end

    def remote_files
      @remote_files ||= @config.storage.directories.get(@config.storage_directory).files
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
