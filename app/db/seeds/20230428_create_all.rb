# frozen_string_literal: true

Sequel.seed(:development) do
  def run
    puts 'Seeding accounts, locations, events'
    create_accounts
    create_founded_locations
    create_curated_events
    add_participants
  end
end

require 'yaml'
DIR = File.dirname(__FILE__)
ACCOUNTS_INFO = YAML.load_file("#{DIR}/accounts_seed.yml")
CURATE_INFO = YAML.load_file("#{DIR}/curators_events_locations.yml")
LOCATION_INFO = YAML.load_file("#{DIR}/locations_seed.yml")
FOUNDER_INFO = YAML.load_file("#{DIR}/founders_locations.yml")
EVENT_INFO = YAML.load_file("#{DIR}/events_seed.yml")
PARTICIPATE_INFO = YAML.load_file("#{DIR}/events_participants.yml")

def create_accounts
  ACCOUNTS_INFO.each do |account_info|
    Candyland::Account.create(account_info)
  end
end

def create_founded_locations
  FOUNDER_INFO.each do |founder|
    account = find_account_for_username(founder['username'])
    founder['locations_name'].each do |location_name|
      location_data = find_location_data_for_name(location_name)
      Candyland::CreateLocationForFinder.call(finder_id: account.id, location_data:)
    end
  end
end

def create_curated_events
  CURATE_INFO.each do |record|
    account = find_account_for_username(record['username'])
    location = find_location_for_location_name(record['location_name'])
    event_data = find_event_data_for_title(record['event_title'])
    event_data['location_id'] = location.id
    Candyland::CreateEventForCurator.call(curator_id: account.id, event_data:)
  end
end

def find_account_for_username(username)
  Candyland::Account.first(username:)
end

def find_location_for_location_name(location_name)
  Candyland::Location.first(name: location_name)
end

def find_event_data_for_title(event_title)
  EVENT_INFO.find { |event| event['title'] == event_title }
end

def find_location_data_for_name(location_name)
  LOCATION_INFO.find { |location| location['name'] == location_name }
end

def create_event_for_curator(curator_id, event_data)
  Candyland::CreateEventForCurator.call(curator_id:, event_data:)
end

def add_participants
  participate_info = PARTICIPATE_INFO
  participate_info.each do |participantion|
    event = Candyland::Event.first(title: participantion['event_title'])
    participantion['participant_email'].each do |email|
      Candyland::AddParticipantToEvent.call(
        email:, event_id: event.id
      )
    end
  end
end
