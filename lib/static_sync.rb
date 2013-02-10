require_relative "static_sync/version"
require_relative "static_sync/config"
require_relative "static_sync/processor"

module StaticSync
  def self.upload(config = {})
    Processor.new(Config.new.load.merge(config)).sync
  end
end
