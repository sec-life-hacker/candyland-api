# frozen_string_literal: true

require 'json'
require 'sequel'

module Candyland
  # Models a Location
  class Location < Sequel::Model
    on_to_many :events
    plugin :association_dependencies, documents: :destroy

    plugin :timestamps

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'project',
            attributes: {
              id:,
              name:,
              desctiption:,
              coordinate:,
            }
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
