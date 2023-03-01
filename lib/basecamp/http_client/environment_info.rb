# frozen_string_literal: true

require_relative '../version'
require 'openssl'

module Basecamp
  class HttpClient
    # Internal: Adds environment information to a Faraday request.
    class EnvironmentInfo
      def initialize(application_info = nil)
        @application_info = application_info

        if @application_info.nil?
          Warning.warn('Basecamp requires to identify your application in User-Agent header to be able to contact you in case of problems (https://github.com/basecamp/bc3-api/blob/master/README.md#identifying-your-application). Please provide application_infol to Basecamp::HttpClient.new')
        end
      end

      # Public: Augments a Faraday connection with information about the
      # environment.
      def configure(builder)
        builder.headers[:user_agent] = application_identification
      end

      private

      def application_identification
        "ruby-basecamp v#{Basecamp::VERSION} #{@application_info})"
      end
    end
  end
end
