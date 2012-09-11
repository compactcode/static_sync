# StaticSync

This gem provides a stand alone mechanism for uploading static websites to cloud hosting providers such as 
[Amazon AWS](http://en.wikipedia.org/wiki/Amazon_S3#Hosting_entire_websites).

### Features

* Standalone.
* Configurable caching.
* Automatic gzip compression.

## Installation

```bash
  gem install static_sync
```

## Usage

In your project directory create a `.static` file:

```
> cat .static
local:
  directory: build

remote:
  provider: AWS
  username: my-aws-key
  password: my-aws-secret
  directory: my-aws-bucket
```

And run the following command any time you want to upload.

```bash
  static_sync
```

### Cache Control

By default uploaded files are not cached.

You can cache content for a given number of seconds by updating your `.static` file:

```
cache:
  javascript: 31536000
  css: 31536000
```

### Compression

By default uploaded files are not compressed.

You can gzip all non binary content by updating your `.static` file:

```
gzip: true
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
