# frozen_string_literal: true

module Candyland
  # Add a collaborator to another owner's existing project
  class AddParticipantToEvent
    # Error for owner cannot be collaborator
    class CuratorNotParticipantError < StandardError
      def message = 'Curator cannot be participant of event'
    end

    def self.call(email:, event_id:)
      participant = Account.first(email:)
      event = Event.first(id: event_id)
      raise(CuratorNotParticipantError) if event.curator.id == participant.id

      event.add_participant(participant)
    end
  end
end
