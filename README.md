# StaticSync

This gem provides a stand alone mechanism for uploading static websites to cloud hosting providers such as 
[Amazon AWS](http://en.wikipedia.org/wiki/Amazon_S3#Hosting_entire_websites).

### Features

* Simple command line tool.
* Custom cache headers per file type.
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

By default uploaded files have no cache headers set.

You can add cache headers on a content type basis to your `.static` file:

```
cache:
  javascript: 31536000
  css: 31536000
```

Which will cache all javscript and css files for 31536000 seconds (one year).

### Compression

By default uploaded files are not compressed.

You can configure your text files to be uploaded using gzip compression in your `.static` file:

```
gzip: true
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
