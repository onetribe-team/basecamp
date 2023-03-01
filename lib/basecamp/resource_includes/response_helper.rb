# frozen_string_literal: true

module Basecamp
  module Resources
    # Internal: A helper to make response body parsing easier.
    module ResponseHelper
      def parse(response)
        data = response.body
        extra = {}

        [data, extra]
      end
    end
  end
end
