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
DATA[:accounts] = YAML.safe_load File.read('app/db/seeds/account_seeds.yml')
DATA[:locations] = YAML.safe_load File.read('app/db/seeds/location_seeds.yml')
DATA[:events] = YAML.safe_load File.read('app/db/seeds/event_seeds.yml')
