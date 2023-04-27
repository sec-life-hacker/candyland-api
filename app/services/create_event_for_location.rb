# forzen_string_literal: true

module Candyland
  # create new event for a location
  class CreateEventFroLocation
    def self.call(location_id, event_data)
      Location.first(id: location_id)
              .add_event(event_data)
    end
  end
end
