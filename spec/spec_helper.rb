# frozen_string_literal: true
require 'simplecov'
SimpleCov.start

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database
  Candyland::Event.map(&:destroy)
  Candyland::Location.map(&:destroy)
  Candyland::Account.map(&:destroy)
end

def authenticate(account_data)
  Candyland::AuthenticateAccount.call(
    username: account_data['username'],
    password: account_data['password']
  )
end

def auth_header(account_data)
  auth = authenticate(account_data)

  "Bearer #{auth[:attributes][:auth_token]}"
end

def authorization(account_data)
  auth = authenticate(account_data)

  token = AuthToken.new(auth[:attributes][:auth_token])
  account = token.payload['attributes']
  { account: Credence::Account.first(username: account['username']),
    scope: AuthScope.new(token.scope) }
end

DATA = {} # rubocop:disable Style/MutableConstant
DATA[:accounts] = YAML.safe_load File.read('app/db/seeds/accounts_seed.yml')
DATA[:locations] = YAML.safe_load File.read('app/db/seeds/locations_seed.yml')
DATA[:events] = YAML.safe_load File.read('app/db/seeds/events_seed.yml')
