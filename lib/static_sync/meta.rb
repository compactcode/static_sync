module StaticSync
  class Meta
    def initialize(config)
      @config = config
    end
    def for(file)
      meta = {
        :key    => file,
        :body   => File.open(file),
        :public => true
      }
      MIME::Types::of(file).each do |mime|
        meta.merge!(
          :content_type => MIME::Type.simplified(mime)
        )
        if @config.cache.has_key?(mime.sub_type)
          expiry = @config.cache[mime.sub_type].to_i
          meta.merge!(
            :cache_control => "public, max-age=#{expiry}",
            :expires       => CGI.rfc1123_date(Time.now + expiry)
          )
        end
      end
      meta
    end
  end
end
