# frozen_string_literal: true

require_relative 'basecamp/authentication'
require_relative 'basecamp/resources'
require_relative 'basecamp/client'
require_relative 'basecamp/http_client'
require_relative 'basecamp/version'

module Basecamp
  class Error < StandardError; end
  # Your code goes here...
end
