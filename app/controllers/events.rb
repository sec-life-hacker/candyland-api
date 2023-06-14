# frozen_string_literal: true

require_relative './app'

module Candyland
  # Web controller for Candyland API
  class Api < Roda
    route('events') do |routing|
      unless @auth_account
        routing.halt 403, { message: 'Not authorized' }.to_json
      end

      @events_route = "#{@api_root}/events"

      routing.on String do |event_id|
        @event_route = "#{@events_route}/#{event_id}"
        @req_event = Event.first(id: event_id)

        routing.on 'reveal' do
          # PATCH api/v1/events/[event_id]/reveal
          routing.patch do
            revealed_event = RevealEvent.call(auth: @auth, event: @req_event)
            response.status = 200
            response['Location'] = "#{@event_route}"
          rescue RevealEvent::NotFoundError => e
            routing.halt 404, { message: e.message }.to_json
          rescue RevealEvent::AlreadyRevealedError
            routing.halt 400, { message: e.message }.to_json
          rescue RevealEvent::ForbiddenError
            routing.halt 403, { message: e.message }.to_json
          end
        end

        routing.on 'participate' do
          # PUT api/v1/events/[event_id]/participate
          routing.put do
            ParticipantEvent.call(@auth, event: @req_event)
            response.status = 200
            response['Location'] = "#{@event_route}"
          rescue ParticipantEvent::NotFoundError => e
            routing.halt 404, { message: e.message }.to_json
          rescue ParticipantEvent::CuratorNotParticipantError => e
            routing.halt 400, { message: e.message }.to_json
          rescue StandardError
            routing.halt 500, { message: 'API server error' }.to_json
          end
        end

        routing.on 'participants' do
          # PUT api/v1/events/[event_id]/participants
          routing.put do
            req_data = JSON.parse(routing.body.read)
            AddParticipantToEvent.call(@auth, req_data['email'], event: @req_event)
            response.status = 200
            response['Location'] = "#{@event_route}"
          rescue AddParticipantToEvent::NotFoundError => e
            routing.halt 404, { message: e.message }.to_json
          rescue AddParticipantToEvent::CuratorNotParticipantError => e
            routing.halt 400, { message: e.message }.to_json
          rescue StandardError
            routing.halt 500, { message: 'API server error' }.to_json
          end
        end

        # GET api/v1/events/[event_id]
        routing.get do
          event = GetEventQuery.call(auth: @auth, event: @req_event)
          { data: event }.to_json
        rescue GetEventQuery::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue GetEventQuery::NotFoundError => e
          routing.halt 404, { message: e.message }.to_json
        rescue StandardError => e
          puts "FIND EVENT ERROR: #{e.backtrace}"
          routing.halt 500, { message: 'API server error' }.to_json
        end
      end

      # POST api/v1/events
      routing.post do
        event_data = JSON.parse(routing.body.read)
        new_event = CreateEventForCurator.call(curator_id: @auth_account.id, event_data:)
        raise 'Could not save event' unless new_event
        response.status = 201
        response['Location'] = "#{@events_route}/#{new_event.id}"
        { message: 'Event saved', data: new_event }.to_json
      end

      # GET api/v1/events
      routing.get do
        events_list = Event.all
        viewable_events = events_list.each do |event|
          GetEventQuery.call(auth: @auth, event:)
        end
        output = { data: viewable_events }
        JSON.pretty_generate(output)
      rescue StandardError
        routing.halt 404, { message: 'Could not find events' }.to_json
      end
    end
  end
end
