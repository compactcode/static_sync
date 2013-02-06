require "digest/md5"
require "mime/types"
require "tempfile"
require "zlib"

module StaticSync
  class Uploadable < Struct.new(:path, :config)

    def id
      [path, etag]
    end

    def mime
      MIME::Types::of(path).first
    end

    def content_type
      if mime
        MIME::Type.simplified(mime)
      end
    end

    def gzipped?
      mime && mime.ascii?
    end

    def content_enconding
      if gzipped?
        'gzip'
      end
    end

    def cache_control
      if mime
        type = mime.sub_type
        type = mime.media_type if mime.media_type == "image"
        if config.cache.has_key?(type)
          return "public, max-age=#{config.cache[type].to_i}"
        end
      end
    end

    def content
      @content ||= begin
        result = File.open(path, 'rb') { |f| f.read }
        if gzipped?
          result = File.open(gzip(result), 'rb') { |f| f.read }
        end
        result
     end
    end

    def etag
      @etag ||= Digest::MD5.hexdigest(content)
    end

    def headers
      base_headers = {
        'x-amz-acl'           => 'public-read',
        'x-amz-storage-class' => 'REDUCED_REDUNDANCY',
      }
      base_headers.merge!('Content-Type'     => content_type)      if content_type
      base_headers.merge!('Content-Encoding' => content_enconding) if content_enconding
      base_headers.merge!('Cache-Control'    => cache_control)     if cache_control
      base_headers
    end

    private

    def gzip(content)
      zipped = Tempfile.new("static_sync")
      Zlib::GzipWriter.open(zipped) do |archive|
        # Gzip by default incorporates file creation time into the content.
        # For the purpose of repeatable etag comparison we want avoid this.
        archive.mtime = 1
        archive.write content
      end
      zipped
    end

  end
end
