# StaticSync

This gem provides a command line tool for uploading static websites to amazon/rackspace.

### Features

* Compares the md5 cheksum of each file before deciding to upload it.
* Automatically gzips non binary files.
* Sets appropriate HTTP metadata header information for serving html files.
    * Content Type (text/css, image/png etc).
    * Cache Control (public, max-age=31536000).
    * Content Enconding (gzip).

## Requirements

* Ruby 1.9

## Installation

```bash
  gem install static_sync
```

## Example Usage

In your project directory create a `.static` file:

```
> cat .static

# What to upload
local:
  directory: build

# Where to upload
remote:
  provider: AWS
  region: ap-southeast-2
  username: my-aws-key
  password: my-aws-secret
  directory: my-aws-bucket

# Everything below this line is optional.

# What not to upload (ruby regular expression).
ignored: (psd,gz)$

# Number of seconds to cache each content type, defaults to no cache.
cache:
  html: 31536000
  javascript: 31536000
  css: 31536000
  image: 31536000

# If you wish to strictly prevent modification of existing files.
immutable_mode: false
```

And simply run the following command any time you want to upload.

```bash
  static_sync
```

### Environment Variables

You can reference environment variables in your `.static` file like this:

```
remote:
  provider: AWS
  username: <%= ENV['s3_key'] %>
  password: <%= ENV['s3_secret'] %>
  directory: <%= ENV['s3_bucket'] %>
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
