# frozen_string_literal: true

require_relative 'response_helper'

module Basecamp
  module Resources
    # Public: Represents a paginated collection of Basecamp resources.
    class Collection
      include Enumerable
      include ResponseHelper

      attr_reader :elements

      # Public: Initializes a collection representing a page of resources of a
      # given type.
      #
      # (elements, extra) - [Array] an (String, Hash) tuple coming from the
      #                     response parser.
      # type              - [Class] the type of resource that the collection
      #                     contains. Defaults to the generic Resource.
      # client            - [Asana::Client] the client to perform requests.
      def initialize((elements, extra),
        type: Resource,
        client: required('client'))
        @elements = elements.map { |elem| type.new(elem, client: client) }
        @type = type
        @next_page_data = extra[:next_page_data]
        @total_count = extra[:total_count]
        @client = client
      end

      # Public: Iterates over the elements of the collection.
      def each(&block)
        if block
          @elements.each(&block)
          (next_page || []).each(&block)
        else
          to_enum
        end
      end

      # Public: Returns the last item in the collection.
      def last
        @elements.last
      end

      # Public: Returns the size of the collection.
      def size
        to_a.size
      end
      alias_method :length, :size

      # Public: Returns the total number of items in the collection based in Basecamp X-Total-Count header.
      attr_reader :total_count

      # Public: Returns a String representation of the collection.
      def to_s
        "#<Basecamp::Collection<#{@type}> " +
          (@total_count ? "(#{@total_count} total) " : '') +
          "[#{@elements.map(&:inspect).join(", ")}" +
          (@next_page_data ? ', ...' : '') + ']>'
      end
      alias_method :inspect, :to_s

      # Public: Returns a new Basecamp::Resources::Collection with the next page
      # or nil if there are no more pages. Caches the result.
      def next_page
        if defined?(@next_page)
          @next_page
        else
          @next_page =
            if @next_page_data
              response = parse(@client.get(@next_page_data['path']))
              self.class.new(response, type: @type, client: @client)
            end
        end
      end
    end
  end
end
