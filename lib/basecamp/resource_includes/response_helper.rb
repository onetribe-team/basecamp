# frozen_string_literal: true

module Basecamp
  module Resources
    # Internal: A helper to make response body parsing easier.
    module ResponseHelper
      def parse(response)
        data = response.body
        extra = {}

        total_count = response.headers['X-Total-Count']
        extra[:total_count] = total_count.to_i if total_count

        [data, extra]
      end
    end
  end
end
