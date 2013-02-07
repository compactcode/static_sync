require 'cgi'

module StaticSync
  class Meta
    class Caching

      def initialize(config)
        @config = config
      end

      def for(file, mime)
        meta = {}
        type = mime.sub_type
        type = mime.media_type if mime.media_type == "image"
        if @config.cache.has_key?(type)
          expiry = @config.cache[type].to_i
          meta.merge!(
            :cache_control => "public, max-age=#{expiry}",
            :expires       => CGI.rfc1123_date(Time.now + expiry)
          )
        end
        meta
      end

    end
  end
end
