# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Event handing' do
  include Rack::Test::Methods

  before do
    wipe_database

    DATA[:events].each do |event_data|
      Candyland::Event.create(event_data)
    end
  end

  it 'HAPPY: should be able to get list of all documents' do
    location = Candyland::Location.first
    DATA[:events].each do |event|
      location.add_event(event)
    end

    get "api/v1/locations/#{location.id}/events"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 2
  end

  it 'HAPPY: should be able to get details of a single document' do
    event_data = DATA[:events][1]
    location = Candyland::Location.first
    event = location.add_event(event_data)

    get "/api/v1/locations/#{location.id}/events/#{id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['id']).must_equal event.id
    _(result['data']['attributes']['title']).must_equal event_data['name']
    _(result['data']['attributes']['description']).must_equal event_data['description']
    _(result['data']['attributes']['time']).must_equal event_data['time']
    _(result['data']['attributes']['curator']).must_equal event_data['curator']
  end

  it 'SAD: should return error if unknown document requested' do
    get '/api/v1/events/foobar'

    _(last_response.status).must_equal 404
  end

  describe 'Create Events' do
    before do
      @location = Candyland::Location.first
      @event_data = DATA[:events][1]
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
    end

    it 'HAPPY: should be able to create new documents' do
      post "api/v1/locations/#{@location_id}/events",
           @event_data,
           @req_header
      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['data']['attributes']
      event = Candyland::Event.first

      _(created['id']).must_equal event.id
      _(created['title']).must_equal existing_event['title']
      _(created['description']).must_equal existing_event['description']
      _(created['time']).must_equal existing_event['time']
      _(created['curator']).must_equal existing_event['curator']
    end

    it 'SECURITY: should not create documents with mass assignment' do
      bad_data = @event_data.clone
      bad_data['created_at'] = '1900-01-01'
      post "api/v1/locations/#{@location.id}/events",
           bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.headers['Location']).must_be_nil
    end
  end
end
