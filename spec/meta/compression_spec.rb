require "mime/types"
require "tempfile"
require "zlib"
require "./lib/static_sync/config"
require "./lib/static_sync/meta/compression"

describe StaticSync::Meta::Compression do

  let(:config) { StaticSync::Config.new }

  let(:html)   { MIME::Type.new('text/html') }
  let(:image)  { MIME::Type.new('image/gif') }

  subject do
    StaticSync::Meta::Compression.new(config)
  end

  before do
    File.stub(:read).and_return("")
  end

  context "when compression is disabled" do

    before do
      config['gzip'] = false
    end

    describe "#for" do
      it "does not set compression headers for html files" do
        subject.for("index.html", html).should_not include(:content_encoding => "gzip")
      end
    end
  end

  context "when compression is enabled" do

    before do
      config['gzip'] = true
    end

    describe "#for" do
      it "sets compression headers for html files" do
        subject.for("index.html", html).should include(:content_encoding => "gzip")
      end

      it "does not set compression headers for binary files" do
        subject.for("assets/images/spinner.gif", image).should_not include(:content_encoding => "gzip")
      end
    end
  end

end
