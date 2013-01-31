require "./lib/static_sync/config"
require "./lib/static_sync/storage"

describe StaticSync::Storage do

  let(:config) do
    StaticSync::Config.new.merge({
      'log' => false,
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

  context "with a remote storage directory" do

    before do
      config.storage.directories.create(
        :key    => config.storage_directory,
        :public => true
      )
    end

    context "syncing a new html website" do

      describe "#sync" do

        it "sets a unique key for each uploaded file" do
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

    context "syncing an existing html website" do

      before(:each) do
        subject.sync
      end

      describe "#sync" do

        it "does not upload existing identical files" do
          subject.stub(:create_remote_file).and_raise('should not upload existing files')

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
  end
end
