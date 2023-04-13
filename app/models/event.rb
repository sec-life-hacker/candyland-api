# frozen_string_literal: true

require 'json'
require 'sequel'

module Candyland
  # MOdels an Event
  class Event < Sequel::Model
    many_to_one :locations
    plugin :association_dependencies, documents: :destroy

    plugin :timestamps
    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON({
             type: 'document',
             id:,
             title:,
             description:,
             time:,
             curator:,
             location:
           }, options)
    end
    # rubocop:enable Metrics/MethodLength
  end
end
