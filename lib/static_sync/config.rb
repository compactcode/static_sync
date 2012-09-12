module StaticSync
  class Config < Hash

    # TODO Validate.

    def cache
      self['cache'] || {}
    end

    def source
      self['local']['directory']
    end

    def storage
      Fog::Storage.new({
        :provider              => self['remote']['provider'],
        :aws_access_key_id     => self['remote']['username'],
        :aws_secret_access_key => self['remote']['password']
      })
    end

    def storage_directory
      self['remote']['directory']
    end

    def gzip
      self['gzip']
    end

    def load(path = '.static')
      self.replace(YAML.load_file(ERB.new(path).result))
      self
    end

  end
end
