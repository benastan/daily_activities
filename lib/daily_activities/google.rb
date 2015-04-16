require 'json'

module DailyActivities
  class Google < Faraday::Connection
    def initialize
      super('https://www.googleapis.com')
    end

    def authorization_url(state:)
      uri = URI('https://accounts.google.com/o/oauth2/auth')
      uri.query = Rack::Utils.build_query(
        client_id: Google.client_id,
        response_type: 'code',
        scope: 'openid email',
        redirect_uri: Google.redirect_uri,
        state: state
      )
      uri.to_s
    end

  def fetch_access_token(code:)
      data = {
        code: code,
        client_id: Google.client_id,
        client_secret: Google.client_secret,
        grant_type: 'authorization_code',
        redirect_uri: Google.redirect_uri
      }

      res = post('/oauth2/v3/token', data)
      json = JSON.parse(res.body)
      @access_token = json['access_token']
      authorization(:Bearer, @access_token)
      @access_token
    end

    def me
      JSON.parse(get('/plus/v1/people/me').body)
    end

    protected

    def self.redirect_uri
      ENV['GOOGLE_REDIRECT_URI']
    end

    def self.client_id
      ENV['GOOGLE_CLIENT_ID']
    end

    def self.client_secret
      ENV['GOOGLE_CLIENT_SECRET']
    end
  end
end
