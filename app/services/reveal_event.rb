# forzen_string_literal: true

module Candyland
  # reveals an event
  class RevealEvent
    class NotFoundError < StandardError
      def message = 'Event not found'
    end

    # Error when event is already revealed
    class AlreadyRevealedError < StandardError
      def message = 'Event is already revealed'
    end
    
    class ForbiddenError < StandardError
      def message = 'You are not allowed to reveal this event'
    end

    def self.call(auth:, event:)
      raise(NotFoundError) unless event
      raise(AlreadyRevealedError) if event.revealed?

      policy = EventPolicy.new(auth[:account], event, auth[:scope])
      raise(ForbiddenError) unless policy.can_reveal?
      event.update(revealed: true)
    end
  end
end
