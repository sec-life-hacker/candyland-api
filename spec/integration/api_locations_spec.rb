# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Location Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
    @account_data = DATA[:accounts][1]
    @account = Candyland::Account.create(@account_data)
    @auth = Candyland::AuthenticateAccount.call(
      username: @account_data['username'],
      password: @account_data['password']
    )
  end

  it 'HAPPY: should be able to get list of all locations' do
    Candyland::CreateLocationForFinder.call(finder_id: @account.id, location_data: DATA[:locations][0])
    Candyland::CreateLocationForFinder.call(finder_id: @account.id, location_data: DATA[:locations][1])

    header 'AUTHORIZATION', "Bearer #{@auth[:attributes][:auth_token]}"
    get 'api/v1/locations'
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 2
  end

  it 'HAPPY: should be able to get details of a single locations' do
    existing_location = DATA[:locations][1]
    Candyland::CreateLocationForFinder.call(finder_id: @account.id, location_data: existing_location)
    id = Candyland::Location.first.id

    header 'AUTHORIZATION', "Bearer #{@auth[:attributes][:auth_token]}"
    get "/api/v1/locations/#{id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['id']).must_equal id
    _(result['data']['attributes']['name']).must_equal existing_location['name']
    _(result['data']['attributes']['coordinate']).must_equal existing_location['coordinate']
  end

  it 'SAD: should return error if unknown locations requested' do
    header 'AUTHORIZATION', "Bearer #{@auth[:attributes][:auth_token]}"
    get '/api/v1/locations/foobar'

    _(last_response.status).must_equal 404
  end

  it 'HAPPY: should be able to create new locations' do
    existing_location = DATA[:locations][1]

    req_header = { 'CONTENT_TYPE' => 'application/json' }
    header 'AUTHORIZATION', "Bearer #{@auth[:attributes][:auth_token]}"
    post 'api/v1/locations', existing_location.to_json, req_header
    _(last_response.status).must_equal 201
    _(last_response.headers['Location'].size).must_be :>, 0

    created = JSON.parse(last_response.body)['data']['attributes']
    location = Candyland::Location.first

    _(created['id']).must_equal location.id
    _(created['name']).must_equal existing_location['name']
    _(created['description']).must_equal existing_location['description']
    _(created['coordinate']).must_equal existing_location['coordinate']
  end
end
