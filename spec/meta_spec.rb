require "cgi"
require "mime/types"
require "tempfile"
require "zlib"
require "./lib/static_sync/config"
require "./lib/static_sync/meta"

describe StaticSync::Meta do

  let(:config) { StaticSync::Config.new }

  subject do
    StaticSync::Meta.new(config)
  end

  it "sets appropriate content types for a range of common file types" do
    Dir.chdir("spec/fixtures/site") do
      subject.for("index.html").should                       include(:content_type => "text/html")
      subject.for("assets/images/spinner.gif").should        include(:content_type => "image/gif")
      subject.for("assets/stylesheets/screen.css").should    include(:content_type => "text/css")
      subject.for("assets/javascripts/jquery.min.js").should include(:content_type => "application/javascript")
    end
  end

  context "when gzip is disabled" do
    before do
      config['gzip'] = false
    end

    it "does not gzip html files" do
      Dir.chdir("spec/fixtures/site") do
        subject.for("index.html").should_not include(:content_encoding => "gzip")
      end
    end
  end

  context "when gzip is enabled" do
    before do
      config['gzip'] = true
    end

    it "gzips html files" do
      Dir.chdir("spec/fixtures/site") do
        subject.for("index.html").should include(:content_encoding => "gzip")
      end
    end

    it "does not gzip binary files" do
      Dir.chdir("spec/fixtures/site") do
        subject.for("assets/images/spinner.gif").should_not include(:content_encoding => "gzip")
      end
    end
  end

  describe "all files" do

    it "should be public" do
      Dir.chdir("spec/fixtures/site") do
        subject.for("index.html").should include(
          :key          => "index.html",
          :content_type => "text/html",
          :public       => true
        )
        subject.for("assets/stylesheets/screen.css").should include(
          :key          => "assets/stylesheets/screen.css",
          :content_type => "text/css",
          :public       => true
        )
        subject.for("assets/javascripts/jquery.min.js").should include(
          :key          => "assets/javascripts/jquery.min.js",
          :content_type => "application/javascript",
          :public       => true
        )
      end
    end

    it "should cache files when requested" do
      config['cache'] = {
        'css'        => '86400',
        'javascript' => '86400'
      }
      Dir.chdir("spec/fixtures/site") do
        subject.for("index.html").should_not include(
          :cache_control
        )
        subject.for("assets/stylesheets/screen.css").should include(
          :cache_control
        )
        subject.for("assets/javascripts/jquery.min.js").should include(
          :cache_control
        )
      end
    end

  end
end
