# frozen_string_literal: true

module Candyland
  # get event
  class GetEventQuery
    # Error when users not allowed to access the event
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access that event'
      end
    end

    # Error when the requested event do not exist
    class NotFoundError < StandardError
      def message
        'Event not found'
      end
    end

    def self.call(auth:, event:)
      raise NotFoundError unless event

      policy = EventPolicy.new(auth[:account], event, auth[:scope])
      raise ForbiddenError unless policy.can_view?

      if policy.can_view_detail?
        event.full_details.merge(policies: policy.summary)
      else
        event.to_h
      end
    end
  end
end
