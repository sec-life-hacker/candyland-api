# frozen_string_literal: true

module Candyland
  # get location
  class GetLocationQuery
    # Error when users not allowed to access the location
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access that location'
      end
    end

    # Error when the requested location do not exist
    class NotFoundError < StandardError
      def message
        'Location not found'
      end
    end

    def self.call(auth:, location:)
      raise NotFoundError unless location

      policy = LocationPolicy.new(auth[:account], location, auth[:scope])
      raise ForbiddenError unless policy.can_view?

      location.full_details.merge(policies: policy.summary)
    end
  end
end
