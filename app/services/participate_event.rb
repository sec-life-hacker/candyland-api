# frozen_string_literal: true

module Candyland
  # Self invite to an event
  class ParticipantEvent
    class NotFoundError < StandardError
      def message = 'Event not found'
    end
    # Error for curator cannot be participant
    class CuratorNotParticipantError < StandardError
      def message = 'Curator cannot be participant of event'
    end

    def self.call(auth:, event:)
      raise NotFoundError unless event

      policy = ParticipateRequestPolicy.new(
        event, auth[:account], invitee, auth[:scope]
      )
      raise ForbiddenError unless policy.can_self_invite?

      event.add_participant(auth[:account])
      auth[:account]
    end
  end
end
