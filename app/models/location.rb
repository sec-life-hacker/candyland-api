# frozen_string_literal: true

require 'json'
require 'sequel'

module Candyland
  # Models a Location
  class Location < Sequel::Model
    one_to_many :events
    plugin :association_dependencies, events: :destroy

    plugin :timestamps

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'location',
            attributes: {
              id:,
              name:,
              description:,
              coordinate:
            }
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
