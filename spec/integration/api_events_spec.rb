# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Event handing' do
  include Rack::Test::Methods

  before do
    wipe_database
    @req_header = { 'CONTENT_TYPE' => 'application/json' }
    @curator_data = DATA[:accounts][0]
    @curator_account = Candyland::Account.create(@curator_data)
    @host_data = DATA[:accounts][1]
    @host_account = Candyland::Account.create(@host_data)
    @participant_data = DATA[:accounts][2]
    @participant_account = Candyland::Account.create(@participant_data)
    @nobody_data = DATA[:accounts][3]
    @nobody_account = Candyland::Account.create(@nobody_data)
    @auth = Candyland::AuthenticateAccount.call(
      username: @curator_data['username'],
      password: @curator_data['password']
    )

    DATA[:locations].each do |location_data|
      Candyland::CreateLocationForFinder.call(finder_id: @host_account.id, location_data:)
    end
    @location = Candyland::Location.first
  end

  describe 'Curator should be able to create an event' do
    before do
      @event_data = DATA[:events][1]
      @event_data['location_id'] = @location.id
    end

    it 'HAPPY: should create an event for curator' do
      header 'AUTHORIZATION', "Bearer #{@auth[:attributes][:auth_token]}"
      post 'api/v1/events', @event_data.to_json, @req_header

      _(last_response.status).must_equal 201
      _(last_response.headers['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['attributes']
      event = Candyland::Event.first

      _(created['id']).must_equal event.id
      _(created['title']).must_equal @event_data['title']
      _(created['description']).must_equal @event_data['description']
      _(created['revealed']).must_equal false
    end
  end

  describe 'Curator should be able to reveal a curated event' do
    before do
      @event_data = DATA[:events][1]
      @event_data['location_id'] = @location.id
      Candyland::CreateEventForCurator.call(curator_id: @curator_account.id, event_data: @event_data)
    end

    it 'HAPPY: should reveal a curated event' do
      curated_event = Candyland::Event.first
      event_id = curated_event.id
      header 'AUTHORIZATION', "Bearer #{@auth[:attributes][:auth_token]}"
      patch "api/v1/events/#{event_id}/reveal"

      _(last_response.status).must_equal 200
      _(last_response.headers['Location'].size).must_be :>, 0

      revealed_event = Candyland::Event.first(id: event_id)

      _(revealed_event.revealed).must_equal true
    end
  end

  describe 'Getting events' do
    before do
      DATA[:events].each do |event_data|
        event_data['location_id'] = @location.id
        Candyland::CreateEventForCurator.call(curator_id: @curator_account.id, event_data:)
      end
    end

    it 'HAPPY: should be able to get list of all curated events' do
      header 'AUTHORIZATION', "Bearer #{@auth[:attributes][:auth_token]}"
      get 'api/v1/events'

      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['data'].count).must_equal 3
    end

    describe 'Access control' do
      before do
        @curator_auth = Candyland::AuthenticateAccount.call(
          username: @curator_data['username'],
          password: @curator_data['password']
        )
        @host_auth = Candyland::AuthenticateAccount.call(
          username: @host_data['username'],
          password: @host_data['password']
        )
        @participant_auth = Candyland::AuthenticateAccount.call(
          username: @participant_data['username'],
          password: @participant_data['password']
        )
        @nobody_auth = Candyland::AuthenticateAccount.call(
          username: @nobody_data['username'],
          password: @nobody_data['password']
        )
      end

      it 'HAPPY: curator should be able to get details of a curated event' do
        curated_event = DATA[:events][0]
        event_id = Candyland::Event.first.id
        header 'AUTHORIZATION', "Bearer #{@curator_auth[:attributes][:auth_token]}"
        get "api/v1/events/#{event_id}"
        _(last_response.status).must_equal 200

        result = JSON.parse last_response.body
        _(result['data']['attributes']['id']).must_equal event_id
        _(result['data']['attributes']['title']).must_equal curated_event['title']
        _(result['data']['attributes']['description']).must_equal curated_event['description']
        _(result['data']['hidden_infos']['time']).must_equal curated_event['time']
      end

      it 'HAPPY: host should be able to get details of a hosted event' do
        hosted_event = DATA[:events][0]
        event_id = Candyland::Event.first.id
        header 'AUTHORIZATION', "Bearer #{@host_auth[:attributes][:auth_token]}"
        get "api/v1/events/#{event_id}"
        _(last_response.status).must_equal 200

        result = JSON.parse last_response.body
        _(result['data']['attributes']['id']).must_equal event_id
        _(result['data']['attributes']['title']).must_equal hosted_event['title']
        _(result['data']['attributes']['description']).must_equal hosted_event['description']
        _(result['data']['hidden_infos']['time']).must_equal hosted_event['time']
      end
      
      it 'HAPPY: participant should not be able to get details of a participated event before revealed' do
        participated_event = DATA[:events][0]
        event_id = Candyland::Event.first.id
        Candyland::AddParticipantToEvent.call(
          email: @participant_data['email'],
          event_id:
        )

        header 'AUTHORIZATION', "Bearer #{@participant_auth[:attributes][:auth_token]}"
        get "api/v1/events/#{event_id}"
        _(last_response.status).must_equal 200

        result = JSON.parse last_response.body
        _(result['data']['attributes']['id']).must_equal event_id
        _(result['data']['attributes']['title']).must_equal participated_event['title']
        _(result['data']['attributes']['description']).must_equal participated_event['description']
        assert_nil(result['data']['hidden_infos'])
      end

      it 'HAPPY: participant should be able to get details of a participated event after revealed' do
        participated_event = DATA[:events][0]
        event = Candyland::Event.first
        event_id = event.id
        Candyland::AddParticipantToEvent.call(
          email: @participant_data['email'],
          event_id:
        )
        event.update(revealed: true)

        header 'AUTHORIZATION', "Bearer #{@participant_auth[:attributes][:auth_token]}"
        get "api/v1/events/#{event_id}"
        _(last_response.status).must_equal 200

        result = JSON.parse last_response.body
        _(result['data']['attributes']['id']).must_equal event_id
        _(result['data']['attributes']['title']).must_equal participated_event['title']
        _(result['data']['attributes']['description']).must_equal participated_event['description']
        _(result['data']['hidden_infos']['time']).must_equal participated_event['time']
        _(result['data']['hidden_infos']['location']['attributes']['id']).must_equal @location.id
      end

      it 'HAPPY: user should be able to get infos of a non-participated event but not hidden infos' do
        event = DATA[:events][0]
        event_id = Candyland::Event.first.id
        header 'AUTHORIZATION', "Bearer #{@nobody_auth[:attributes][:auth_token]}"
        get "api/v1/events/#{event_id}"
        _(last_response.status).must_equal 200

        result = JSON.parse last_response.body
        _(result['data']['attributes']['id']).must_equal event_id
        _(result['data']['attributes']['title']).must_equal event['title']
        _(result['data']['attributes']['description']).must_equal event['description']
        assert_nil(result['data']['hidden_infos'])
      end
    end
  end
end
