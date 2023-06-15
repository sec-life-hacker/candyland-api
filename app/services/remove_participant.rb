# frozen_string_literal: true

module Candyland
  # remove a participant from event
  class RemoveParticipant
    # Error for not allow to remove participant
    class ForbiddenError < StandardError
      def message
        'You are not allowed to remove that person'
      end
    end

    def self.call(auth:, participant_email:, event_id:)
      event = Event.first(id: event_id)
      participant = Account.first(email: participant_email)

      policy = ParticipateRequestPolicy.new(
        event, auth[:account], participant, auth[:scope]
      )
      raise ForbiddenError unless policy.can_remove?

      event.remove_participant(participant)
      participant
    end
  end
end
