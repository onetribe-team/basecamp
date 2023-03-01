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
        # options - [Hash] the request I/O options.
        def find_all(client, options: {})
          Collection.new(parse(client.get('/projects', options: options)), type: self, client: client)
        end
      end
    end
  end
end
