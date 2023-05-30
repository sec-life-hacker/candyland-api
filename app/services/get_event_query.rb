# frozen_string_literal: true

module Candyland
  # get event
  class GetEventQuery
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access that event'
      end
    end

    class NotFoundError < StandardError
      def message
        'Event not found'
      end
    end

    def self.call(requester:, event:)
      raise NotFoundError unless event

      policy = DocumentPolicy.new(requestor, event)
      raise ForbiddenError unless policy.can_view?

      event
    end
  end
end
