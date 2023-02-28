# frozen_string_literal: true

require_relative 'oauth2/bearer_token_authentication'
require_relative 'oauth2/access_token_authentication'

module Basecamp
  module Authentication
    # Public: Deals with OAuth2 authentication. Contains a function to get an
    # access token throught a browserless authentication flow, needed for some
    # applications such as CLI applications.
    module OAuth2
    end
  end
end
