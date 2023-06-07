# forzen_string_literal: true

module Candyland
  # create new location for an account
  class CreateLocationForFinder
    def self.call(finder_id:, location_data:)
      Account.first(id: finder_id)
             .add_found_location(location_data)
    end
  end
end
