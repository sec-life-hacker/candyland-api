# forzen_string_literal: true

module Candyland
  # create new event for a location
  class CreateEventForCurator
    def self.call(curator_id:, event_data:)
      event = Account.first(id: curator_id)
             .add_curated_event(event_data)
      Location.first(id: event_data['location_id'])
        .add_event(event)
    end
  end
end
