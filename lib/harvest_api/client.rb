require 'harvest'

module HarvestApi
  CREDENTIALS_PATH = File.join('/opt/time_tracker',
                               '.credentials',
                               'harvest-api.yml')

  class Client
    def self.instance
      if @client
        return @client
      end
      credentials = YAML.load_file(CREDENTIALS_PATH)
      @client = Harvest.client(access_token: credentials['access_token'],
                               account_id: credentials['account_id'],
                               user_agent: credentials['user_agent'])
    end
  end
end
