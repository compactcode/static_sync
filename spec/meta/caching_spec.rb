require "mime/types"
require "tempfile"
require "zlib"
require "./lib/static_sync/config"
require "./lib/static_sync/meta/caching"

describe StaticSync::Meta::Caching do

  let(:config) { StaticSync::Config.new }

  let(:html)   { MIME::Type.new('text/html') }
  let(:css)    { MIME::Type.new('text/css') }

  subject do
    StaticSync::Meta::Caching.new(config)
  end

  context "when caching is completely disabled" do

    before do
      config['cache'] = { }
    end

    describe "#for" do
      it "does not set cache headers for html files" do
        subject.for("index.html", html).should_not include(:cache_control)
      end
    end
  end

  context "when caching is enabled for html only" do

    before do
      config['cache'] = { 'html' => '86400' }
    end

    describe "#for" do
      it "sets cache headers for html files" do
        subject.for("index.html", html).should include(:cache_control)
      end

      it "does not set cache headers for css files" do
        subject.for("screen.css", css).should_not include(:cache_control)
      end
    end
  end

end
