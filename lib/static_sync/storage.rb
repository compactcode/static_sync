require_relative "meta"

module StaticSync
  class Storage

    def initialize(config)
      @config = config
      @meta   = Meta.new(config)
    end

    def sync
      Dir.chdir(@config.source) do
        Dir.glob("**/*.*") do |file|
          log.info("Uploading #{file}")
          @config.storage.directories.get(@config.storage_directory).files.create(
            @meta.for(file)
          )
        end
      end
    end

    private

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
