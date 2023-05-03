# frozen_string_literal: true

require 'sequel'
require 'json'
require_relative './password'

module Candyland
  # Models a registered account
  class Account < Sequel::Model
    one_to_many :curated_events, class: :'Candyland::Event', key: :curator_id
    many_to_many :participations,
                 class: :'Candyland::Event',
                 join_table: :accounts_events,
                 left_key: :participant_id, right_key: :event_id

    plugin :uuid, field: :id
    plugin :association_dependencies,
           curated_events: :destroy,
           participations: :nullify

    plugin :whitelist_security
    set_allowed_columns :username, :email, :password

    plugin :timestamps, update_on_create: true

    def events
      curated_events + participations
    end

    def password=(new_password)
      self.password_digest = Password.digest(new_password)
    end

    def password?(try_password)
      digest = Candyland::Password.from_digest(password_digest)
      digest.correct?(try_password)
    end

    def to_json(options = {})
      JSON(
        {
          type: 'account',
          attributes: {
            username:,
            email:
          }
        }, options
      )
    end
  end
end
