# forzen_string_literal: true

module Candyland
  # create new event for a location
  class CreateEventForCurator
    def self.call(curator_id:, event_data:)
      Account.first(id: curator_id)
             .add_curated_event(event_data)
    end
  end
end
