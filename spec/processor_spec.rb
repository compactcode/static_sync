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

  let(:storage) { double }

  subject do
    StaticSync::Processor.new(config, storage)
  end

  describe "#handle_conflict" do
    let(:file) { double }

    context "when in overwrite mode" do
      let(:config) do
        StaticSync::Config.new.merge({
          'conflict_mode' => 'overwrite'
        })
      end

      it "does nothing" do
        subject.handle_conflict(file)
      end
    end

    context "when in fail mode" do
      let(:config) do
        StaticSync::Config.new.merge({
          'conflict_mode' => 'fail'
        })
      end

      it "raises a conflict error" do
        expect {
          subject.handle_conflict(file)
        }.to raise_error(StaticSync::Processor::ConflictError)
      end
    end

    context "when in fail on cache mode" do
      let(:file) { double(:cached? => false) }

      let(:config) do
        StaticSync::Config.new.merge({
          'conflict_mode' => 'fail_if_cached'
        })
      end

      it "does nothing by default" do
        subject.handle_conflict(file)
      end

      context "when the file is cached" do
        let(:file) { double(:cached? => true) }

        it "raises a conflict error" do
          expect {
            subject.handle_conflict(file)
          }.to raise_error(StaticSync::Processor::ConflictError)
        end
      end
    end
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
