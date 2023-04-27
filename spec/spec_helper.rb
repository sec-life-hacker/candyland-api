# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database
  app.DB[:events].delete
  app.DB[:locations].delete
  app.DB[:accounts].delete
end

DATA = {} # rubocop:disable Style/MutableConstant
DATA[:accounts] = YAML.safe_load File.read('app/db/seeds/accounts_seed.yml')
DATA[:locations] = YAML.safe_load File.read('app/db/seeds/locations_seed.yml')
DATA[:events] = YAML.safe_load File.read('app/db/seeds/events_seeds.yml')
