# frozen_string_literal: true

require 'oauth2'

module Basecamp
  class Client
    # Internal: Represents a configuration DSL for an Basecamp::Client.
    #
    # Examples
    #
    #   config = Configuration.new
    #   config.authentication :oauth, bearer_token: 'token'
    #   config.adapter :typhoeus
    #   config.configure_faraday { |conn| conn.use MyMiddleware }
    #   config.to_h
    #   # => { authentication: #<Authentication::TokenAuthentication>,
    #          faraday_adapter: :typhoeus,
    #          faraday_configuration: #<Proc> }
    #
    class Configuration
      # Public: Initializes an empty configuration object.
      def initialize
        @configuration = {}
      end

      # Public: Sets an authentication strategy.
      #
      # type  - [:oauth2, :api_token] the kind of authentication strategy to use
      # value - [::OAuth2::AccessToken, String, Hash] the configuration for the
      #         chosen authentication strategy.
      #
      # Returns nothing.
      #
      # Raises ArgumentError if the arguments are invalid.
      def authentication(type, value)
        auth =
          case type
          when :oauth2 then oauth2(value)
          else error "unsupported authentication type #{type}"
          end
        @configuration[:authentication] = auth
      end

      # Public: Sets an account ID from Basecamp.
      #
      # value - [Interger] the ID.
      #
      # Returns nothing.
      def account_id(value)
        @configuration[:account_id] = value
      end

      # Public: Sets an application info to be passed to Basecamp in User-Agent header.
      #
      # Returns nothing.
      def application_info(value)
        @configuration[:application_info] = value
      end

      # Public: Sets a custom network adapter for Faraday.
      #
      # adapter - [Symbol, Proc] the adapter.
      #
      # Returns nothing.
      def faraday_adapter(adapter)
        @configuration[:faraday_adapter] = adapter
      end

      # Public: Sets a custom configuration block for the Faraday connection.
      #
      # config - [Proc] the configuration block.
      #
      # Returns nothing.
      def configure_faraday(&config)
        @configuration[:faraday_configuration] = config
      end

      # Public: Configures the client in debug mode, which will print verbose
      # information on STDERR.
      #
      # Returns nothing.
      def debug_mode
        @configuration[:debug_mode] = true
      end

      # Public: Configures the client to always send the given headers
      #
      # Returns nothing.
      def default_headers(value)
        @configuration[:default_headers] = value
      end

      # Public:
      # Returns the configuration [Hash].
      def to_h
        @configuration
      end

      private

      # Internal: Configures an OAuth2 authentication strategy from either an
      # OAuth2 access token object, or a plain refresh token, or a plain bearer
      # token.
      #
      # value - [::OAuth::AccessToken, String] the value to configure the
      #         strategy from.
      #
      # Returns [Basecamp::Authentication::OAuth2::AccessTokenAuthentication,
      #          Basecamp::Authentication::OAuth2::BearerTokenAuthentication]
      #         the OAuth2 authentication strategy.
      #
      # Raises ArgumentError if the OAuth2 configuration arguments are invalid.
      #
      # rubocop:disable Metrics/MethodLength
      def oauth2(value)
        case value
        when ::OAuth2::AccessToken
          from_access_token(value)
        when ->(v) { v.is_a?(Hash) && v[:bearer_token] }
          from_bearer_token(value[:bearer_token])
        else
          error 'Invalid OAuth2 configuration: pass in either an ' \
            '::OAuth2::AccessToken object of your own or a hash ' \
            'containing :refresh_token or :bearer_token.'
        end
      end

      # Internal: Configures an OAuth2 AccessTokenAuthentication strategy.
      #
      # access_token - [::OAuth2::AccessToken] the OAuth2 access token object
      #
      # Returns a [Authentication::OAuth2::AccessTokenAuthentication] strategy.
      def from_access_token(access_token)
        Authentication::OAuth2::AccessTokenAuthentication
          .new(access_token)
      end

      # Internal: Configures an OAuth2 BearerTokenAuthentication strategy.
      #
      # bearer_token - [String] the plain OAuth2 bearer token
      #
      # Returns a [Authentication::OAuth2::BearerTokenAuthentication] strategy.
      def from_bearer_token(bearer_token)
        Authentication::OAuth2::BearerTokenAuthentication
          .new(bearer_token)
      end

      def requiring(hash, *keys)
        missing_keys = keys.select { |k| !hash.key?(k) }
        missing_keys.any? && error("Missing keys: #{missing_keys.join(", ")}")
        keys.map { |k| hash[k] }
      end

      def error(msg)
        raise ArgumentError, msg
      end
    end
  end
end
