# frozen_string_literal: true

module Basecamp
  module Resources
    class Project < Resource
      class << self
        # Returns the plural name of the resource.
        def plural_name
          'projects'
        end

        # Returns the compact records for all workspaces visible to the authorized user.
        #
        # per_page - [Integer] the number of records to fetch per page.
        # options - [Hash] the request I/O options.
        def find_all(client, per_page: 20, options: {})
          params = {limit: per_page}.reject { |_, v| v.nil? || Array(v).empty? }
          Collection.new(parse(client.get('/projects', params: params, options: options)), type: self, client: client)
        end
      end
    end
  end
end
