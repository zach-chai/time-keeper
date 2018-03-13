require 'tracker_api'

module PivotalApi
  CREDENTIALS_PATH = File.join('/opt/time_tracker',
                               '.credentials',
                               'pivotal-api.yml')

  class Client
    def self.instance
      if @client
        return @client
      end
      credentials = YAML.load_file(CREDENTIALS_PATH)
      @client = TrackerApi::Client.new(token: credentials['token'])
    end
  end
end
