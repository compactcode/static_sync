require "awsraw/s3/client"
require "logger"
require "nokogiri"

require_relative "uploadable"

module StaticSync
  class Storage

    class FatalError < StandardError
    end

    def initialize(config)
      @config = config
    end

    def sync

      s3 = AWSRaw::S3::Client.new(
        @config.remote['username'],
        @config.remote['password']
      )

      Dir.chdir(@config.local['directory']) do
        local_filtered_files.each do |file|
          current_file = Uploadable.new(file, @config)

          if remote_file_ids(s3).include?(current_file.id)
            log.debug("Ignoring #{current_file.path}")
          else
            log.info("Uploading #{current_file.path}")

            response = s3.request(
              :method  => "PUT",
              :region  => @config.remote['region'],
              :bucket  => @config.remote['directory'],
              :key     => current_file.path,
              :content => current_file.content,
              :headers => current_file.headers
            )

            validate_response(response)
          end
        end
      end
    end

    private

    def validate_response(response)
      if response.failure?
        log.error("HTTP(#{response.code}) while communicationg with the #{@config.remote['directory']} bucket.")
        log.error(response.content)
        exit(false)
      end
    end

    # TODO: This method is horrible.
    def remote_file_ids(s3)
      @remote_file_ids ||= begin
        results = []

        no_more_objects = false

        until no_more_objects

          response = s3.request(
            :method => "GET",
            :region => @config.remote['region'],
            :bucket => @config.remote['directory'],
            :query  => "marker=#{results.fetch(-1, []).first}"
          )

          validate_response(response)

          @doc = Nokogiri::XML(response.content)
          @doc.remove_namespaces!

          keys = @doc.xpath("//Contents/Key").map do |node|
            node.inner_text
          end

          etags = @doc.xpath("//Contents/ETag").map do |node|
            node.inner_text.gsub("\"", "")
          end

          results.concat(keys.zip(etags))

          no_more_objects = @doc.at_xpath("//IsTruncated").content == 'false'

        end

        results
      end
    end

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

    def log
      @log ||= begin
        logger = Logger.new(STDOUT)
        logger.level = @config.log_level
        logger.formatter = proc do |severity, datetime, progname, msg|
            "#{datetime}: #{severity} -- #{msg}\n"
        end
        logger
      end
    end

  end
end
