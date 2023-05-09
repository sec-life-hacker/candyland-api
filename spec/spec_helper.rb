# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database
  Candyland::Location.map(&:destroy)
  Candyland::Event.map(&:destroy)
  Candyland::Account.map(&:destroy)
end

DATA = {} # rubocop:disable Style/MutableConstant
DATA[:accounts] = YAML.safe_load File.read('app/db/seeds/accounts_seed.yml')
DATA[:locations] = YAML.safe_load File.read('app/db/seeds/locations_seed.yml')
DATA[:events] = YAML.safe_load File.read('app/db/seeds/events_seed.yml')
