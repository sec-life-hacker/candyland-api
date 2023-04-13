# frozen_string_literal: true

require 'roda'
require 'json'

require_relative '../models/event'

module Candyland
  # Web controller for Credence API
  class Api < Roda
    plugin :halt

    route do |routing| # rubocop:disable Metrics/BlockLength
      response['Content-Type'] = 'application/json'

      routing.root do
        { message: 'CandylandAPI up at /api/v1' }.to_json
      end

      @api_root = 'api/v1'
      routing.on @api_root do
        routing.on 'locations' do
          @location_route = "#{@api_root}/locations"

          routing.on String do |location_id|

            routing.on 'events' do
              @event_route = "#{@api_root}/locations/#{location_id}/events"

              # GET api/v1/locations/[location_id]/events/[event_id]
              routing.on String do |event_id|
                event = Event.where(location_id: location_id, id: event_id).first
                event ? event.to_json : raise('Event not found')
                rescue StandardError => e
                routing.halt 404, { message: e.message }.to_json
              end

              # GET api/v1/locations/[location_id]/events
              routing.get do
                output = { data: Location[location_id].events }
                JSON.pretty_generate(output)
                rescue StandardError => e
                routing.halt 404, { message: e.message }.to_json
              end

              # POST api/v1/locations/[location_id]/events
              routing.post do
                new_data = JSON.parse(routing.body.read)
                location = Location[location_id]
                new_event = location.add_event(new_data)

                if new_event
                  response.status = 201
                  response['Location'] = "#{@event_route}/#{new_event.id}"
                  { message: 'Event saved', data: new_event }.to_json
                else
                  routing.halt 400, 'Could not save event'
                end

                rescue StandardError
                routing.halt 500, { message: 'Database error' }.to_json
              end
            end

            # GET api/v1/locations/[location_id]
            routing.get do
              location = Location[location_id]
              location ? location.to_json : raise('Location not found')
            end
          end

          # GET api/v1/locations
          routing.get do
            output = { data: Location.all }
            JSON.pretty_generate(output)
            rescue StandardError
            routing.halt 404, { message: 'Could not find locations' }.to_json
          end

          # POST api/v1/locations
          routing.post do
            new_data = JSON.parse(routing.body.read)
            new_location = Location.new(new_data)
            raise('Could not save location') unless new_location.save

            response.status = 201
            response['Location'] = "#{@location_route}/#{new_location.id}"
            { message: 'Location saved', data: new_location }.to_json
            rescue StandardError => e
            routing.halt 400, { message: e.message }.to_json
          end
        end
      end
    end
  end
end
