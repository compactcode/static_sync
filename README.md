# StaticSync

TODO: Write a gem description

## Installation

```bash
  gem install static_sync
```

## Usage

In your project directory create a *.static* configuration file:

```yaml
local:
  directory: build # The directory to upload

remote:
  provider: AWS
  username: my-aws-key
  password: my-aws-secret
  directory: my-aws-bucket
```

Simply run the following command any time you want to upload your site.

```bash
  static_sync
```

### Cache Control

Specified in seconds.

```yaml
cache:
  javascript: 31536000
  css: 31536000
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
