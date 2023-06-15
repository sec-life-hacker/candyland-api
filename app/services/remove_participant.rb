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

    def self.call(auth:, participant_id:, event_id:)
      event = Event.first(id: event_id)
      participant = Account.first(id: participant_id)
      collaborator = Account.first(email: collab_email)

      policy = CollaborationRequestPolicy.new(
        project, auth[:account], collaborator, auth[:scope]
      )
      raise ForbiddenError unless policy.can_remove?

      project.remove_collaborator(collaborator)
      collaborator
    end
  end
end
