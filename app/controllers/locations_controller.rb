# frozen_string_literal: true

require_relative './app'

module Candyland
  # Web controller for Candyland API
  class Api < Roda
    route('locations') do |routing|
      routing.on String do |location_id|
        routing.on 'events' do
          @event_route = "#{@api_root}/locations/#{location_id}/events"

          # GET api/v1/locations/[location_id]/events/[event_id]
          routing.on String do |event_id|
            event = Event.where(location_id:, id: event_id).first
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
            raise 'Could not save event' unless new_event

            response.status = 201
            response['Location'] = "#{@event_route}/#{new_event.id}"
            { message: 'Event saved', data: new_event }.to_json

          rescue Sequel::MassAssignmentRestriction
            Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
            routing.halt 400, { message: 'Illegal Attributes' }.to_json

          rescue StandardError
            routing.halt 500, { message: 'Database error' }.to_json
          end
        end

        # GET api/v1/locations/[location_id]
        routing.get do
          location = Location[location_id]
          location ? location.to_json : raise('Location not found')
        rescue StandardError => e
          routing.halt 404, { message: e.message }.to_json
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

      rescue Sequel::MassAssignmentRestriction
        Api.logger.warn "MASS-ASSIGNMENT: #{new_location.keys}"
        routing.halt 400, { message: 'Illegal Attributes' }.to_json

      rescue StandardError => e
        routing.halt 400, { message: e.message }.to_json
      end
    end
  end
end