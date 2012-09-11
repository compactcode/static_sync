module StaticSync
  class Meta

    def initialize(config)
      @config = config
    end

    #TODO This class / method has too many responsibilities.
    def for(file)
      meta = {
        :key    => file,
        :body   => File.new(file),
        :public => true
      }
      MIME::Types::of(file).each do |mime|
        if @config.gzip
          unless mime.binary?
            meta.merge!(
              :body             => gzip(file),
              :content_encoding => 'gzip'
            )
          end
        end
        meta.merge!(
          :content_type => MIME::Type.simplified(mime)
        )
        if @config.cache.has_key?(mime.sub_type)
          expiry = @config.cache[mime.sub_type].to_i
          meta.merge!(
            :cache_control => "public, max-age=#{expiry}"
          )
        end
      end
      meta
    end

    def gzip(file)
      zipped = Tempfile.new("static_sync")
      Zlib::GzipWriter.open(zipped) do |archive|
        archive.write File.read(file)
      end
      zipped
    end

  end
end
