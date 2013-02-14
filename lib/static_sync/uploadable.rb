require "cgi"
require "digest/md5"
require "mime/types"
require "tempfile"
require "zlib"

require_relative "storage_cache"

module StaticSync
  class Uploadable < Struct.new(:path, :config)

    def version
      StorageCache::Version.new(path, etag)
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

    def content_encoding
      if gzipped?
        'gzip'
      end
    end

    def cache_time
      if mime
        type = mime.sub_type
        type = mime.media_type if mime.media_type == "image"
        if config.cache.has_key?(type)
          return config.cache[type].to_i
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
      rescue
        ""
      end
    end

    def etag
      @etag ||= Digest::MD5.hexdigest(content)
    end

    def md5
      @md5 ||= Digest::MD5.base64digest(content)
    end

    def headers
      base_headers = {
        :key           => path,
        :body          => content,
        :etag          => etag,
        :content_md5   => md5,
        :storage_class => 'REDUCED_REDUNDANCY',
        :public        => true
      }
      base_headers.merge!(:cache_control    => "public, max-age=#{cache_time}")         if cache_time
      base_headers.merge!(:content_type     => content_type)                            if content_type
      base_headers.merge!(:content_encoding => content_encoding)                        if content_encoding
      base_headers.merge!(:expires          => CGI.rfc1123_date(Time.now + cache_time)) if cache_time
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
