# frozen_string_literal: true

Sequel.seed(:development) do
  def run
    puts 'Seeding accounts, locations, events'
    create_accounts
    create_curated_events
    add_participants
  end
end

require 'yaml'
DIR = File.dirname(__FILE__)
ACCOUNTS_INFO = YAML.load_file("#{DIR}/accounts_seed.yml")
CURATOR_INFO = YAML.load_file("#{DIR}/curators_events.yml")
LOCATION_INFO = YAML.load_file("#{DIR}/locations_seed.yml")
EVENT_INFO = YAML.load_file("#{DIR}/events_seed.yml")
PARTICIPATE_INFO = YAML.load_file("#{DIR}/events_participants.yml")

def create_accounts
  ACCOUNTS_INFO.each do |account_info|
    Candyland::Account.create(account_info)
  end
end

def create_curated_events
  CURATOR_INFO.each do |curator|
    account = find_account_for_curator(curator['username'])
    curator['event_title'].each do |event_title|
      event_data = find_event_data_for_title(event_title)
      curator_id = account.id
      create_event_for_curator(curator_id, event_data)
    end
  end
end

def find_account_for_curator(curator_username)
  Candyland::Account.first(username: curator_username)
end

def find_event_data_for_title(event_title)
  EVENT_INFO.find { |event| event['title'] == event_title }
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
