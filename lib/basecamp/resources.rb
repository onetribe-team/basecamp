# frozen_string_literal: true

require_relative 'resource_includes/resource'
require_relative 'resource_includes/collection'

# Dir[File.join(File.dirname(__FILE__), 'resource_includes', '*.rb')]
#   .each { |resource| require resource }

# Dir[File.join(File.dirname(__FILE__), 'resources', '*.rb')]
#   .each { |resource| require resource }

module Basecamp
  # Public: Contains all the resources that the Basecamp API can return.
  module Resources
  end
end
