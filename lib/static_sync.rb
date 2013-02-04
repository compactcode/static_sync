require_relative "static_sync/version"
require_relative "static_sync/config"
require_relative "static_sync/storage"

module StaticSync
  def self.upload(config = {})
    Storage.new(Config.new.load.merge(config)).sync
  end
end
