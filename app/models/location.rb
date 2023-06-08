# frozen_string_literal: true

require 'json'
require 'sequel'

module Candyland
  # Models a Location
  class Location < Sequel::Model
    many_to_one :finder, class: :'Candyland::Account', key_type: :uuid
    one_to_many :events
    plugin :association_dependencies, events: :destroy

    plugin :uuid, field: :id
    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :name, :description, :coordinate

    def coordinate
      SecureDB.decrypt(coordinate_secure)
    end

    def coordinate=(plaintext)
      self.coordinate_secure = SecureDB.encrypt(plaintext)
    end

    def to_h
      {
        type: 'location',
        attributes: {
          id:,
          name:,
          description:,
          coordinate:
        },
      }
    end

    def full_details
      to_h.merge(
        relationships: {
          finder:,
          events:,
        }
      )
    end

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(to_h, options)
    end
    # rubocop:enable Metrics/MethodLength
  end
end
