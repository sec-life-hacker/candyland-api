# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Event handing' do
  include Rack::Test::Methods

  before do
    wipe_database

    DATA[:locations].each do |location_data|
      Candyland::Location.create(location_data)
    end
  end

  describe 'Getting events' do
    describe 'Getting list of events' do
      before do
        @account_data = DATA[:accounts][0]
        account = Candyland::Account.create(@account_data)
        location = Candyland::Location.first
        DATA[:events].each do |event|
          event = location.add_event(event)
          Candyland::AddParticipantToEvent.call(
            email: account.email,
            event_id: event.id
          )
        end
      end

      it 'HAPPY: should get list for authorized account' do
        auth = Candyland::AuthenticateAccount.call(
          username: @account_data['username'],
          password: @account_data['password']
        )

        header 'AUTHORIZATION', "Bearer #{auth[:attributes][:auth_token]}"

        get "api/v1/locations/#{location.id}/events"
        _(last_response.status).must_equal 200

        result = JSON.parse last_response.body
        _(result['data'].count).must_equal 3
      end
    end

    it 'HAPPY: should be able to get details of a single event' do
      event_data = DATA[:events][1]
      location = Candyland::Location.first
      event = location.add_event(event_data)

      get "/api/v1/locations/#{location.id}/events/#{event.id}"
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['attributes']['id']).must_equal event.id
      _(result['attributes']['title']).must_equal event_data['title']
      _(result['attributes']['description']).must_equal event_data['description']
    end

    it 'SAD: should return error if unknown event requested' do
      get '/api/v1/events/foobar'

      _(last_response.status).must_equal 404
    end
  end

  describe 'Create Events' do
    before do
      @location = Candyland::Location.first
      @event_data = DATA[:events][1]
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
    end

    it 'HAPPY: should be able to create new events' do
      post "api/v1/locations/#{@location.id}/events",
           @event_data.to_json,
           @req_header
      _(last_response.status).must_equal 201
      _(last_response.headers['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['attributes']
      event = Candyland::Event.first

      _(created['id']).must_equal event.id
      _(created['title']).must_equal @event_data['title']
      _(created['description']).must_equal @event_data['description']
    end

    it 'SECURITY: should not create events with mass assignment' do
      bad_data = @event_data.clone
      bad_data['created_at'] = '1900-01-01'
      post "api/v1/locations/#{@location.id}/events",
           bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.headers['Location']).must_be_nil
    end
  end
end
