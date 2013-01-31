require "./lib/static_sync/config"
require "./lib/static_sync/meta"

describe StaticSync::Meta do

  let(:config) { StaticSync::Config.new }

  subject do
    StaticSync::Meta.new(config)
  end

  it "sets files as public" do
    Dir.chdir("spec/fixtures/site") do
      subject.for("index.html").should include(:public => true)
    end
  end

  it "sets appropriate content types for a range of common file types" do
    Dir.chdir("spec/fixtures/site") do
      subject.for("index.html").should                       include(:content_type => "text/html")
      subject.for("assets/images/spinner.gif").should        include(:content_type => "image/gif")
      subject.for("assets/stylesheets/screen.css").should    include(:content_type => "text/css")
      subject.for("assets/javascripts/jquery.min.js").should include(:content_type => "application/javascript")
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

  end
end
