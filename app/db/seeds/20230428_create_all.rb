# frozen_string_literal: true

Sequel.seed(:development) do
  def run
    puts 'Seeding accounts, locations, events'
    create_accounts
    #create_curated_events
    #add_participants
  end
end

require 'yaml'
DIR = File.dirname(__FILE__)
ACCOUNTS_INFO = YAML.load_file("#{DIR}/accounts_seed.yml")
CURATOR_INFO = YAML.load_file("#{DIR}/curators_events.yml")
LOCATION_INFO = YAML.load_file("#{DIR}/locations_seed.yml")
EVENT_INFO = YAML.load_file("#{DIR}/events_seeds.yml")
PARTICIPATE_INFO = YAML.load_file("#{DIR}/events_participants.yml")

def create_accounts
  ACCOUNTS_INFO.each do |account_info|
    Candyland::Account.create(account_info)
  end
end

def create_curated_events
  CURATOR_INFO.each do |curator|
    account = Candyland::Account.first(username: curator['username'])
    curator['event_title'].each do |event_title|
      event_data = EVENT_INFO.find { |event| event['title'] == event_title }
      Candyland::CreateEventForCurator.call(
        curator_id: account.id, event_data:
      )
    end
  end
end

def add_participants
  participate_info = PARTICIPATE_INFO
  participate_info.each do |participantion|
    event = Candyland::Event.first(name: participantion['event_title'])
    participantion['participant_email'].each do |email|
      Candyland::AddParticipantToEvent.call(
        email:, event_id: event.id
      )
    end
  end
end
