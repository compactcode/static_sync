require_relative "meta/caching"
require_relative "meta/compression"

module StaticSync
  class Meta

    def initialize(config)
      @config      = config
      @compression = Compression.new(@config)
      @caching     = Caching.new(@config)
    end

    def for(file)
      meta = {
        :key    => file,
        :body   => File.new(file),
        :public => true
      }
      MIME::Types::of(file).each do |mime|
        meta.merge!(
          :content_type => MIME::Type.simplified(mime)
        )
        meta.merge!(@compression.for(file, mime))
        meta.merge!(@caching.for(file, mime))
      end
      meta
    end

  end
end
