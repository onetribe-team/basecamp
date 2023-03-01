# frozen_string_literal: true

module Basecamp
  module Resources
    class Project < Resource
      class << self
        # Returns the plural name of the resource.
        def plural_name
          'projects'
        end

        # Returns the full project record for a single project.
        #
        # id - [Id] unique identifier for the project or organization.
        #
        # options - [Hash] the request I/O options.
        def find_by_id(client, id, options: {})
          new(parse(client.get("/projects/#{id}", options: options)).first, client: client)
        end

        # Returns the compact records for all projects visible to the authorized user.
        #
        # options - [Hash] the request I/O options.
        def find_all(client, options: {})
          Collection.new(parse(client.get('/projects', options: options)), type: self, client: client)
        end
      end
    end
  end
end
