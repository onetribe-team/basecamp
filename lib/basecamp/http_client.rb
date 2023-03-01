# frozen_string_literal: true

require 'faraday'

require_relative 'http_client/error_handling'
require_relative 'http_client/environment_info'
require_relative 'http_client/response'

module Basecamp
  # Internal: Wrapper over Faraday that abstracts authentication, request
  # parsing and common options.
  class HttpClient
    # Internal: The API base URI.
    BASE_URI = 'https://3.basecampapi.com'

    # Public: Initializes an HttpClient to make requests to the Basecamp API.
    #
    # authentication - [Basecamp::Authentication] An authentication strategy.
    # account_id     - [Integer] Your Basecamp account ID.
    # adapter        - [Symbol, Proc] A Faraday adapter, eiter a Symbol for
    #                  registered adapters or a Proc taking a builder for a
    #                  custom one. Defaults to Faraday.default_adapter.
    # user_agent     - [String] The user agent. Defaults to "ruby-basecamp vX.Y.Z".
    # config         - [Proc] An optional block that yields the Faraday builder
    #                  object for customization.
    def initialize(authentication: required('authentication'),
      account_id: required('account_id'),
      application_info: nil,
      adapter: nil,
      debug_mode: false,
      default_headers: nil,
      &config)
      @authentication = authentication
      @account_id = account_id
      @adapter = adapter || Faraday.default_adapter
      @environment_info = EnvironmentInfo.new(application_info)
      @debug_mode = debug_mode
      @default_headers = default_headers
      @config = config
    end

    # Public: Performs a GET request against the API.
    #
    # resource_uri - [String] the resource URI relative to the base Basecamp API
    #                URL, e.g "/users/me".
    # params       - [Hash] the request parameters
    # options      - [Hash] the request I/O options
    #
    # Returns an [Basecamp::HttpClient::Response] if everything went well.
    # Raises [Basecamp::Errors::APIError] if anything went wrong.
    def get(resource_uri, params: {}, options: {})
      perform_request(:get, resource_uri, params, options[:headers])
    end

    # Public: Performs a PUT request against the API.
    #
    # resource_uri - [String] the resource URI relative to the base Basecamp API
    #                URL, e.g "/users/me".
    # body         - [Hash] the body to PUT.
    # options      - [Hash] the request I/O options
    #
    # Returns an [Basecamp::HttpClient::Response] if everything went well.
    # Raises [Basecamp::Errors::APIError] if anything went wrong.
    def put(resource_uri, body: {}, options: {})
      params = body.merge(options.empty? ? {} : {options: options})
      perform_request(:put, resource_uri, params, options[:headers])
    end

    # Public: Performs a POST request against the API.
    #
    # resource_uri - [String] the resource URI relative to the base Basecamp API
    #                URL, e.g "/tags".
    # body         - [Hash] the body to POST.
    # upload       - [Faraday::UploadIO] an upload object to post as multipart.
    #                Defaults to nil.
    # options      - [Hash] the request I/O options
    #
    # Returns an [Basecamp::HttpClient::Response] if everything went well.
    # Raises [Basecamp::Errors::APIError] if anything went wrong.
    def post(resource_uri, body: {}, upload: nil, options: {})
      params = body.merge(options.empty? ? {} : {options: options})
      if upload
        perform_request(:post, resource_uri, params.merge(file: upload), options[:headers]) do |c|
          c.request :multipart
        end
      else
        perform_request(:post, resource_uri, params, options[:headers])
      end
    end

    # Public: Performs a DELETE request against the API.
    #
    # resource_uri - [String] the resource URI relative to the base Basecamp API
    #                URL, e.g "/tags".
    # options      - [Hash] the request I/O options
    #
    # Returns an [Basecamp::HttpClient::Response] if everything went well.
    # Raises [Basecamp::Errors::APIError] if anything went wrong.
    def delete(resource_uri, params: {}, options: {})
      perform_request(:delete, resource_uri, params, options[:headers])
    end

    private

    def connection(&request_config)
      Faraday.new do |builder|
        @authentication.configure(builder)
        @environment_info.configure(builder)
        yield builder if request_config
        configure_format(builder)
        add_middleware(builder)
        @config&.call(builder)
        use_adapter(builder, @adapter)
      end
    end

    def perform_request(method, resource_uri, body = {}, headers = {}, &request_config)
      handling_errors do
        url = build_url(resource_uri)
        headers = (@default_headers || {}).merge(headers || {})
        log_request(method, url, body) if @debug_mode
        result = Response.new(connection(&request_config).public_send(method, url, body, headers))
        result
      end
    end

    def configure_format(builder)
      builder.request :json
      builder.response :json
    end

    def add_middleware(builder)
      builder.use Faraday::Response::RaiseError
      # builder.use FaradayMiddleware::FollowRedirects
    end

    def use_adapter(builder, adapter)
      case adapter
      when Symbol
        builder.adapter(adapter)
      when Proc
        adapter.call(builder)
      end
    end

    def handling_errors(&request)
      ErrorHandling.handle(&request)
    end

    def log_request(method, url, body)
      warn format('[%s] %s %s (%s)',
        self.class,
        method.to_s.upcase,
        url,
        body.inspect)
    end

    def build_url(resource_uri)
      URI(base_uri_for_account).tap do |uri|
        uri.path = uri.path + resource_uri + '.json'
      end.to_s
    end

    def base_uri_for_account
      BASE_URI + "/#{@account_id}"
    end
  end
end
