# frozen_string_literal: true

require_relative 'authentication'
require_relative 'client/configuration'

module Basecamp
  # Public: A client to interact with the Basecamp API. It exposes all the
  # available resources of the Basecamp API in idiomatic Ruby.
  #
  # Examples
  #
  #   # Authentication with a personal access token
  #   Basecamp::Client.new do |client|
  #     client.authentication :access_token, '...'
  #   end
  #
  #   # OAuth2 with a plain bearer token (doesn't support auto-refresh)
  #   Basecamp::Client.new do |client|
  #     client.authentication :oauth2, bearer_token: '...'
  #   end
  #
  #   # OAuth2 with a plain refresh token and client credentials
  #   Basecamp::Client.new do |client|
  #     client.authentication :oauth2,
  #                           refresh_token: '...',
  #                           client_id: '...',
  #                           client_secret: '...',
  #                           redirect_uri: '...'
  #   end
  #
  #   # OAuth2 with an ::OAuth2::AccessToken object
  #   Basecamp::Client.new do |client|
  #     client.authentication :oauth2, my_oauth2_access_token_object
  #   end
  #
  #   # Use a custom Faraday network adapter
  #   Basecamp::Client.new do |client|
  #     client.authentication ...
  #     client.adapter :typhoeus
  #   end
  #
  #   # Use a custom user agent string
  #   Basecamp::Client.new do |client|
  #     client.authentication ...
  #     client.user_agent '...'
  #   end
  #
  #   # Pass in custom configuration to the Faraday connection
  #   Basecamp::Client.new do |client|
  #     client.authentication ...
  #     client.configure_faraday { |conn| conn.use MyMiddleware }
  #   end
  #
  class Client
    # Internal: Proxies Resource classes to implement a fluent API on the Client
    # instances.
    class ResourceProxy
      def initialize(client: required('client'), resource: required('resource'))
        @client = client
        @resource = resource
      end

      def method_missing(m, *args, **kwargs, &block)
        @resource.public_send(m, *([@client] + args), **kwargs, &block)
      end

      def respond_to_missing?(m, *)
        @resource.respond_to?(m)
      end
    end

    # Public: Initializes a new client.
    #
    # Yields a {Basecamp::Client::Configuration} object as a configuration
    # DSL. See {Basecamp::Client} for usage examples.
    def initialize
      config = Configuration.new.tap { |c| yield c }.to_h
      @http_client =
        HttpClient.new(authentication:            config.fetch(:authentication),
                       account_id:                config.fetch(:account_id),
                       application_info:          config[:application_info],
                       adapter:                   config[:faraday_adapter],
                       debug_mode:                config[:debug_mode],
                       default_headers:           config[:default_headers],
          &config[:faraday_configuration])
    end

    # Public: Performs a GET request against an arbitrary Basecamp URL. Allows for
    # the user to interact with the API in ways that haven't been
    # reflected/foreseen in this library.
    def get(url, **args)
      @http_client.get(url, **args)
    end

    # Public: Performs a POST request against an arbitrary Basecamp URL. Allows for
    # the user to interact with the API in ways that haven't been
    # reflected/foreseen in this library.
    def post(url, **args)
      @http_client.post(url, **args)
    end

    # Public: Performs a PUT request against an arbitrary Basecamp URL. Allows for
    # the user to interact with the API in ways that haven't been
    # reflected/foreseen in this library.
    def put(url, **args)
      @http_client.put(url, **args)
    end

    # Public: Performs a DELETE request against an arbitrary Basecamp URL. Allows
    # for the user to interact with the API in ways that haven't been
    # reflected/foreseen in this library.
    def delete(url, **args)
      @http_client.delete(url, **args)
    end

    # Public: Exposes queries for all top-evel endpoints.
    #
    # E.g. #users will query /users and return a
    # Basecamp::Resources::Collection<User>.
    Resources::Registry.resources.each do |resource_class|
      define_method(resource_class.plural_name) do
        ResourceProxy.new(client: @http_client,
          resource: resource_class)
      end
    end
  end
end
