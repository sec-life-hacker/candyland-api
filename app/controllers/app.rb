# frozen_string_literal: true

require 'roda'
require 'json'

module Candyland
  # Web controller for Candyland API
  class Api < Roda
    plugin :halt
    plugin :multi_route

    route do |routing|
      response['Content-Type'] = 'application/json'

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
