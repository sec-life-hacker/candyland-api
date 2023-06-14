# frozen_string_literal: true

module Candyland
  # Add a participant to an existing event
  class AddParticipantToEvent
    class NotFoundError < StandardError
      def message = 'Event not found'
    end

    # Error for curator cannot be participant
    class CuratorNotParticipantError < StandardError
      def message = 'Curator cannot be participant of event'
    end

    # Error when request email doesn't exist in database
    class ParticipantEmailNotFoundError < StandardError
      def message = 'This email does not belong to any user'
    end

    # Error for not allowed to invite
    class ForbiddenError < StandardError
      def message = 'You are not allowed to invite participants'
    end

    def self.call(auth:, participant_email:, event:)
      raise NotFoundError unless event

      invitee = Account.first(email: participant_email)
      raise ParticipantEmailNotFoundError unless invitee

      policy = ParticipateRequestPolicy.new(
        event, auth[:account], invitee, auth[:scope]
      )

      raise ForbiddenError unless policy.can_invite?

      event.add_participant(invitee)
      invitee
    end
  end
end
