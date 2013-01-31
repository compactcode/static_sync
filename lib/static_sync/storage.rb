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
          current_file = @meta.for(file)

          unless remote_files.map(&:key).include?(current_file[:key])
            log.info("Uploading #{file}") if @config.log
            create_remote_file(
              current_file
            )
          end
        end
      end
    end

    private

    def remote_files
      @config.storage.directories.get(@config.storage_directory).files
    end

    def create_remote_file(meta)
      remote_files.create(meta)
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
