require "erb"
require "logger"
require "yaml"

module StaticSync
  class Config < Hash

    def log_level
      self.fetch('log_level', Logger::INFO)
    end

    def cache
      self.fetch('cache', {})
    end

    def local
      self.fetch('local', {})
    end

    def remote
      self.fetch('remote', {})
    end

    def gzip
      self.fetch('gzip', true)
    end

    def ignored
      self['ignored']
    end

    def load(path = '.static')
      content = '{}'
      begin
        content = File.read(path)
      rescue
        # Loading config from file is not mandatory.
      end
      self.replace(YAML.load(ERB.new(content).result))
      self
    end

  end
end
