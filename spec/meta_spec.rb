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
          :cache_control,
          :expires
        )
        subject.for("assets/stylesheets/screen.css").should include(
          :cache_control,
          :expires
        )
        subject.for("assets/javascripts/jquery.min.js").should include(
          :cache_control,
          :expires
        )
      end
    end

    it "should gzip files when requested" do
      Dir.chdir("spec/fixtures/site") do
        subject.for("index.html").should_not include(
          :content_encoding => 'gzip'
        )
        config['gzip'] = true
        subject.for("index.html").should include(
          :content_encoding => 'gzip'
        )
        subject.for("assets/stylesheets/screen.css").should include(
          :content_encoding => 'gzip'
        )
        subject.for("assets/javascripts/jquery.min.js").should include(
          :content_encoding => 'gzip'
        )
      end
    end

  end
end
