# frozen_string_literal: true

require 'json'
require 'sequel'

module Candyland
  # MOdels an Event
  class Event < Sequel::Model
    many_to_one :location

    plugin :timestamps
    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'event',
            attributes: {
              id:,
              title:,
              description:,
              time:,
              curator:
            }
          },
          included: {
            location:
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
