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
          archive.write File.read(file)
        end
        zipped
      end

    end
  end
end
