require 'google/apis/calendar_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'

require 'fileutils'

module GoogleCalendarApi
  OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
  APPLICATION_NAME = 'Time Tracker Script'
  CLIENT_SECRETS_PATH = File.join(Dir.home,
                                  '.credentials',
                                  'client_secret.json')
  CREDENTIALS_PATH = File.join(Dir.home,
                              '.credentials',
                              'google-api.yaml')
  SCOPE = Google::Apis::CalendarV3::AUTH_CALENDAR_READONLY

  class Client
    def self.instance
      if @client
        return @client
      end
      @client = Google::Apis::CalendarV3::CalendarService.new
      @client.client_options.application_name = APPLICATION_NAME
      @client.authorization = authorize
      @client
    end

    private

    def self.authorize
      FileUtils.mkdir_p(File.dirname(CREDENTIALS_PATH))

      client_id = Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
      token_store = Google::Auth::Stores::FileTokenStore.new(file: CREDENTIALS_PATH)
      authorizer = Google::Auth::UserAuthorizer.new(
        client_id, SCOPE, token_store)
      user_id = 'default'
      credentials = authorizer.get_credentials(user_id)
      if credentials.nil?
        url = authorizer.get_authorization_url(
          base_url: OOB_URI)
        puts "Open the following URL in the browser and enter the " +
             "resulting code after authorization"
        puts url
        code = STDIN.gets
        credentials = authorizer.get_and_store_credentials_from_code(
          user_id: user_id, code: code, base_url: OOB_URI)
      end
      credentials
    end
  end
end
