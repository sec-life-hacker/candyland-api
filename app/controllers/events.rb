# frozen_string_literal: true

require_relative './app'

module Candyland
  # Web controller for Candyland API
  class Api < Roda
    route('events') do |routing|
      unless @auth_account
        routing.halt 403, { message: 'Not authorized' }.to_json
      end

      @event_route = "#{@api_root}/events"

      # GET api/v1/events/[event_id]
      routing.on String do |event_id|
        @req_event = Event.first(id: event_id)
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
  end
end
