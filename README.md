# TimeKeeper

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/time_keeper`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'time_keeper'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install time-keeper

## Setup

Create `.credentials` directory

Download `client_secret.json` file from your Google Application and place in the new directory.

Create `harvest-api.yaml` file with harvest credentials and place in the new directory
```yaml
access_token: '1dsf9df9hg'
account_id: '385937'
user_agent: 'TimeKeeper (example@email.com)'
```

## Usage

```
docker-compose run --rm gem exe/time-keeper sync --dry-run
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
