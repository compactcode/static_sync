require "logger"

require_relative "storage"
require_relative "uploadable"

module StaticSync
  class Processor

    class ConflictError < StandardError
    end

    def initialize(config, storage = nil)
      @config  = config
      @storage = storage || StaticSync::Storage.new(config)
      @skip    = false
    end

    def sync
      log.info("Synching #{@config.local_directory} to #{@config.remote_directory}.") if @config.log
      Dir.chdir(@config.local_directory) do
        local_filtered_files.each do |file|
          current_file = Uploadable.new(file, @config)

          unless @storage.has_version?(current_file.version)
            if @storage.has_file?(current_file.version)
              handle_conflict(current_file)
            else
              log.info("Uploading #{file}") if @config.log
            end
            begin
              @storage.create(current_file.headers) unless @skip
            rescue => error
              log.error("Failed to upload #{file}")
              raise error
            end
          end
        end
      end
      log.info("Synching done.") if @config.log
    end

    def handle_conflict(file)
      log.info("Overwriting #{file}") if @config.log
      if @config.fail_on_conflict?
        raise ConflictError, "modifications to existing files are not allowed."
      elsif @config.fail_on_conflict_if_cached?
        if file.cached?
          raise ConflictError, "modifications to existing cached files are not allowed."
        end
      elsif @config.ignore_conflict?
        @skip = true
        log.info("#{file} already exist, skipping.") if @config.log
      end
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
