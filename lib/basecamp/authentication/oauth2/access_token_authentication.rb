# frozen_string_literal: true

module Basecamp
  module Authentication
    module OAuth2
      # Public: A mechanism to authenticate with an OAuth2 access token (a
      # bearer token and a refresh token) or just a refresh token.
      class AccessTokenAuthentication
        # Public: Initializes a new AccessTokenAuthentication.
        #
        # access_token - [::OAuth2::AccessToken] An ::OAuth2::AccessToken
        #                object.
        def initialize(access_token)
          @token = access_token
        end

        # Public: Configures a Faraday connection injecting a bearer token,
        # auto-refreshing it when needed.
        #
        # connection - [Faraday::Connection] the Faraday connection instance.
        #
        # Returns nothing.
        def configure(connection)
          @token = @token.refresh! if @token.expired?
          connection.headers['Authorization'] = "Bearer #{@token.token}"
        end
      end
    end
  end
end
