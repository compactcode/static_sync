require "digest/md5"
require "mime/types"

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
        :key                => file,
        :body               => File.new(file),
        :public             => true,
        :storage_class      => 'REDUCED_REDUNDANCY'
      }

      mime = MIME::Types::of(file).first

      if mime
        meta.merge!(
          :content_type => MIME::Type.simplified(mime)
        )
        meta.merge!(@compression.for(file, mime))
        meta.merge!(@caching.for(file, mime))
      end

      body = meta[:body].read

      meta.merge!(
        :etag        => Digest::MD5.hexdigest(body),   # A local version of the etag expected after upload.
        :content_md5 => Digest::MD5.base64digest(body) # Enable checksum validation during uploads.
      )
    end

  end
end
