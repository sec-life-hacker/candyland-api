# frozen_string_literal: true

require 'json'
require 'sequel'

module Candyland
  # MOdels an Event
  class Event < Sequel::Model
    many_to_one :curator, class: :'Candyland::Account', key_type: :uuid
    many_to_one :location, class: :'Candyland::Location'
    many_to_many :participants,
                 class: :'Candyland::Account',
                 join_table: :accounts_events,
                 left_key: :event_id, right_key: :participant_id

    plugin :uuid, field: :id
    plugin :association_dependencies,
           participants: :nullify
    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :title, :description, :time

    def time
      SecureDB.decrypt(time_secure)
    end

    def time=(plaintext)
      self.time_secure = SecureDB.encrypt(plaintext)
    end
    
    def to_h
      {
        type: 'event',
        attributes: {
          id:,
          title:,
          description:,
        }
      }
    end

    def hidden_infos
      {
        time:
      }
    end

    def full_details
      to_h.merge(
        hidden_infos:,
        relationships: {
          curator:,
          location:,
          participants:
        }
      )
    end

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(to_h)
    end
    # rubocop:enable Metrics/MethodLength
  end
end
