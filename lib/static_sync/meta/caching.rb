module StaticSync
  class Meta
    class Caching

      def initialize(config)
        @config = config
      end

      def for(file, mime)
        meta = {}
        if @config.cache.has_key?(mime.sub_type)
          expiry = @config.cache[mime.sub_type].to_i
          meta.merge!(
            :cache_control => "public, max-age=#{expiry}"
          )
        end
        meta
      end

    end
  end
end
