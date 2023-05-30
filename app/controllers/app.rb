# frozen_string_literal: true

require 'roda'
require 'json'
require_relative './helpers'

module Candyland
  # Web controller for Candyland API
  class Api < Roda
    plugin :halt
    plugin :multi_route

    include SecureRequestHelpers

    route do |routing|
      response['Content-Type'] = 'application/json'

      secure_request?(routing) ||
        routing.halt(403, { message: 'TLS/SSL secured Connection Required' }.to_json)

      begin
        @auth_account = authenticated_account(routing.headers)
      rescue AuthToken::InvalidTokenError
        routing.halt(403, { message: 'Invalid auth token' }.to_json)
      rescue AuthToken::ExpiredTokenError
        routing.halt(403, { message: 'Expired auth token' }.to_json)
      end

      routing.root do
        { message: 'CandylandAPI up at /api/v1' }.to_json
      end

      routing.on 'api' do
        routing.on 'v1' do
          @api_root = 'api/v1'
          routing.multi_route
        end
      end
    end
  end
end
