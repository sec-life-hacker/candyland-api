# frozen_string_literal: true

# forzen_string_literal: true

module Candyland
  # create new event for a location
  class CreateEventForCurator
    def self.call(curator_id, event_data)
      Account.first(uuid: curator_id)
             .add_event(event_data)
    end
  end
end
