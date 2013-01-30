require "./lib/static_sync"

describe StaticSync::Storage do

  let(:config) do
    StaticSync::Config.new.merge({
      'local' => {
        'directory' => 'spec/fixtures/site'
      },
      'remote' => {
        'provider'  => 'AWS',
        'username'  => 'lol',
        'password'  => 'cat',
        'directory' => 'bucket'
      }
    })
  end

  subject do
    StaticSync::Storage.new(config)
  end

  before do
    Fog.mock!
  end

  after do
    Fog::Mock.reset
  end

  context "when syncing a simple html website" do

    before do
      config.storage.directories.create(
        :key    => config.storage_directory,
        :public => true
      )
    end

    it "uploads all files" do
      subject.sync

      config.storage.directories.get(config.storage_directory).files.map(&:key).should == [
        "assets/images/spinner.gif",
        "assets/javascripts/jquery.min.js",
        "assets/stylesheets/screen.css",
        "index.html"
      ]
    end

  end

end
