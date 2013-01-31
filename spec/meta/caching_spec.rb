require "mime/types"
require "./lib/static_sync/config"
require "./lib/static_sync/meta/caching"

describe StaticSync::Meta::Caching do

  let(:config) { StaticSync::Config.new }

  let(:html)   { MIME::Type.new('text/html') }
  let(:plain)  { MIME::Type.new('text/plain') }
  let(:css)    { MIME::Type.new('text/css') }
  let(:gif)    { MIME::Type.new('image/gif') }
  let(:jpg)    { MIME::Type.new('image/jpg') }
  let(:png)    { MIME::Type.new('image/png') }

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

      it "does not set cache headers for text files" do
        subject.for("data.txt", plain).should_not include(:cache_control)
      end

      it "does not set cache headers for css files" do
        subject.for("screen.css", css).should_not include(:cache_control)
      end
    end
  end

  context "when caching is enabled for images" do

    before do
      config['cache'] = { 'image' => '86400' }
    end

    describe "#for" do
      it "sets cache headers for gif files" do
        subject.for("spinner.gif", gif).should include(:cache_control)
      end

      it "sets cache headers for jpg files" do
        subject.for("kitten.jpg", jpg).should include(:cache_control)
      end

      it "sets cache headers for png files" do
        subject.for("cat.png", png).should include(:cache_control)
      end
    end
  end

end
