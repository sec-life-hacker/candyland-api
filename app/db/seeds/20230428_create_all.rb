# frozen_string_literal: true

Sequel.seed(:development) do
  def run
    puts 'Seeding accounts, locations, events'
  end
end

require 'yaml'
DIR = File.dirname(__FILE__)
ACCOUNTS_INFO = YAML.load_file("#{DIR}/accounts_seed.yml")
CURATOR_INFO = YAML.load_file("#{DIR}/curators_events.yml")
LOCATION_INFO = YAML.load_file("#{DIR}/locations_seed.yml")
EVENT_INFO = YAML.load_file("#{DIR}/events_seeds.yml")
PARTICIPATE_INFO = YAML.load_file("#{DIR}/events_participants.yml")
