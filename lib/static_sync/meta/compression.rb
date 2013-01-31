require "tempfile"
require "zlib"

module StaticSync
  class Meta
    class Compression

      def initialize(config)
        @config = config
      end

      def for(file, mime)
        meta = {}
        if @config.gzip && !mime.binary?
          meta.merge!(
            :body             => gzip(file),
            :content_encoding => 'gzip'
          )
        end
        meta
      end

      private

      def gzip(file)
        zipped = Tempfile.new("static_sync")
        Zlib::GzipWriter.open(zipped) do |archive|
          # Gzip by default incorporates file creation time into the content.
          # For the purpose of repeatable etag comparison we want avoid this.
          archive.mtime = 1
          archive.write File.read(file)
        end
        zipped
      end

    end
  end
end
