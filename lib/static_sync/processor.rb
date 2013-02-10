require "fog"
require "logger"

require_relative "storage"
require_relative "uploadable"

module StaticSync
  class Processor

    class ImmutableError < StandardError
    end

    def initialize(config, storage = nil)
      @config  = config
      @storage = storage || StaticSync::Storage.new(config)
    end

    def sync
      log.info("Synching #{@config.source} to #{@config.target}.") if @config.log
      Dir.chdir(@config.source) do
        local_filtered_files.each do |file|
          current_file = Uploadable.new(file, @config)

          unless @storage.has_version?(current_file.version)
            if @storage.has_file?(current_file.version)
              log.info("Overwriting #{file}") if @config.log
              if @config.immutable_mode
                raise ImmutableError, "immutable_mode does not allow modifications to existing files."
              end
            else
              log.info("Uploading #{file}") if @config.log
            end
            begin
              @storage.create(current_file.headers)
            rescue => error
              log.error("Failed to upload #{file}")
              raise error
            end
          end
        end
      end
      log.info("Synching done.") if @config.log
    end

    def local_filtered_files
      local_files.reject do |file|
        file =~ Regexp.new(@config.ignored) if @config.ignored
      end
    end

    private

    def local_files
      Dir.glob("**/*.*").reject do |file|
        File.directory?(file)
      end
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
