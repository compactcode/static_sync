require "rubygems"

require_relative "static_sync/version"
require_relative "static_sync/config"
require_relative "static_sync/storage"

module StaticSync
  def self.upload
    Storage.new(Config.new.load).sync
  end
end
