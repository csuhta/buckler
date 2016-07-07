### Buckler

[![Build Status](https://travis-ci.org/csuhta/buckler.svg?branch=master)](https://travis-ci.org/csuhta/buckler)

Buckler is a Ruby command line tool for performing common actions on Amazon S3 buckets. It’s more do-what-you-want and less overwhelmingly powerful than the AWS CLI. It’s also designed to work with Heroku applications.

### Installing Buckler

Buckler requires at least Ruby 2.2.3. Get Buckler from Rubygems. The terminal command is called `bucket`.

```shell
gem install buckler
bucket help
```

### Neat Features

- Buckler will "context switch" with you as you change project folders. It discovers AWS credentials in your `.env` files and Heroku applications.
- Prompts you to confirm dangerous actions.
- Works with bucket versioning. Issues reversible `delete` commands for versioned bucket objects.
- The `bucket sync` command spends extra time doing what you want when you "copy" a bucket. The following properties on each object are also transferred: ACLs, metadata, storage class, `Cache-Control` header, and `Content-*` headers, and `Expires` header. This lets you get close to an exact copy of a bucket for testing migrations or other destructive changes.

### Command Reference

```shell
# Get a list of your buckets
bucket list

# Run any command with additional debugging info
bucket list --verbose

# Get a list of all S3 regions
bucket regions

# Create a new bucket on your account
bucket create new-bucket-name

# Create a new bucket on your account in a different region
bucket create new-bucket-name --region eu-west-1

# Remove all objects from one of your buckets
bucket empty bucket-name

# Destroy one of your buckets
bucket destroy bucket-name

# Copy the contents of one bucket into another
# This command also conveniently copies
# ACLs, headers, metadata, and a lot more.
bucket sync source-bucket-name target-bucket-name

# Get detailed help with Buckler commands
bucket help
bucket help sync
bucket help create
bucket help destroy
bucket help empty
bucket help list
bucket help regions
```

### Providing Credentials

You will need a AWS Access Key ID and AWS Secret Access Key pair with permission to mange your S3 buckets. **Do not use your root keys.** [Generate a new set of keys with S3 permissions only](http://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html#lock-away-credentials).

When you run the `bucket` command, Buckler tries to automatically discover AWS credentials around your working directory.

**Dotenv**: If the current folder has a file named `.env`, Buckler will look for variables called `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` in the file. [See Heroku’s documentation on this environment file format](https://devcenter.heroku.com/articles/heroku-local#set-up-your-local-environment-variables).

**Heroku**: If the current folder has a Git repository with a Heroku remote, Buckler will ask your Heroku application for variables named `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` using `heroku config:get`

**Command Line Options**: You can set the pair directly by providing the command line options `--id` and `--secret`

```shell
bucket list --id YOUR_AWS_ID --secret YOUR_AWS_SECRET
```

**Environment Variables**: You can set the pair directly as environment variables.

```shell
AWS_ACCESS_KEY_ID=your-id AWS_SECRET_ACCESS_KEY=your-secret bucket list
```

### Developing Buckler

**The Buckler test suite will create and destroy test buckets on your AWS account which will cost you more than 0 money.** Existing buckets won’t be affected.

```shell
# Fork or clone Buckler
git clone -o github git@github.com:csuhta/buckler.git
cd buckler

# Set your credentials in a .env
echo "AWS_ACCESS_KEY_ID=your-id" >> .env
echo "AWS_SECRET_ACCESS_KEY_ID=your-secret" >> .env

# Work on stuff, then run the test suite
rake test
```

### License

Buckler is free software, and may be redistributed under the terms of the [MIT license](https://github.com/csuhta/bucklet/blob/master/LICENSE.md). Hope you like it! ❤️
