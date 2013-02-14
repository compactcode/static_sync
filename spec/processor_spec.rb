require "./lib/static_sync/config"
require "./lib/static_sync/processor"

describe StaticSync::Processor do

  let(:config) do
    StaticSync::Config.new.merge({
      'log' => false,
      'local' => {
        'directory' => 'spec/fixtures/site'
      }
    })
  end

  let(:storage) { stub }

  subject do
    StaticSync::Processor.new(config, storage)
  end

  describe "#local_filtered_files" do

    before do
      config.merge!(
        'ignored' => '(css|gif)$'
      )
    end

    it "does not include files matching the ignore regex" do
      Dir.chdir(config.local_directory) do
        subject.local_filtered_files.should == [
          "assets/javascripts/jquery.min.js",
          "cat.com/index.html",
          "index.html"
        ]
      end
    end

  end
end
