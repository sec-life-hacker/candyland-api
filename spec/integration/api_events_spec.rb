# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Event handing' do
  include Rack::Test::Methods

  before do
    wipe_database
    @curator_data = DATA[:accounts][0]
    @curator_account = Candyland::Account.create(@curator_data)
    @participant_data = DATA[:accounts][1]
    @participant_account = Candyland::Account.create(@participant_data)
    @auth = Candyland::AuthenticateAccount.call(
      username: @curator_data['username'],
      password: @curator_data['password']
    )

    DATA[:locations].each do |location_data|
      Candyland::CreateLocationForFinder.call(finder_id: @curator_account.id, location_data:)
    end
    @location = Candyland::Location.first
  end

  describe 'Getting events' do
    describe 'Getting list of events' do
      before do
        DATA[:events].each do |event_data|
          event_data['location_id'] = @location.id
          event = Candyland::CreateEventForCurator.call(curator_id: @curator_account.id, event_data:)
          Candyland::AddParticipantToEvent.call(
            email: @participant_account.email,
            event_id: event.id
          )
        end
      end

      it 'HAPPY: should get list for authorized account' do
        header 'AUTHORIZATION', "Bearer #{@auth[:attributes][:auth_token]}"

        get "api/v1/locations/#{@location.id}/events"
        _(last_response.status).must_equal 200

        result = JSON.parse last_response.body
        _(result['data'].count).must_equal 3
      end
    end

    it 'HAPPY: should be able to get details of a single event' do
      event_data = DATA[:events][1]
      event_data['location_id'] = @location.id
      event = Candyland::CreateEventForCurator.call(curator_id: @curator_account.id, event_data:)
      header 'AUTHORIZATION', "Bearer #{@auth[:attributes][:auth_token]}"
      get "/api/v1/locations/#{@location.id}/events/#{event.id}"
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['data']['attributes']['id']).must_equal event.id
      _(result['data']['attributes']['title']).must_equal event_data['title']
      _(result['data']['attributes']['description']).must_equal event_data['description']
    end

    it 'SAD: should return error if unknown event requested' do
      get "/api/v1/locations/#{@location.id}/events/foobar"

      _(last_response.status).must_equal 404
    end
  end

  describe 'Create Events' do
    before do
      @event_data = DATA[:events][1]
      @event_data['location_id'] = @location.id
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
    end

    it 'HAPPY: should be able to create new events' do
      header 'AUTHORIZATION', "Bearer #{@auth[:attributes][:auth_token]}"
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
      header 'AUTHORIZATION', "Bearer #{@auth[:attributes][:auth_token]}"
      post "api/v1/locations/#{@location.id}/events",
           bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.headers['Location']).must_be_nil
    end
  end
end
