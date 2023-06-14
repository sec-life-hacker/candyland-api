# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test AddParticipantToEvent service' do
  before do
    wipe_database

    DATA[:accounts].each do |account_data|
      Candyland::Account.create(account_data)
    end

    DATA[:locations].each do |location_data|
      Candyland::Location.create(location_data)
    end

    @curator_data = DATA[:accounts][0]
    @curator = Candyland::Account.all[0]
    @participant_data = DATA[:accounts][1]
    @participant = Candyland::Account.all[1]
    @event_data = DATA[:events].first
    @event_data['location_id'] = Candyland::Location.first.id
    @event = Candyland::CreateEventForCurator.call(
      curator_id: @curator.id, event_data: @event_data
    )
    @auth = Candyland::AuthenticateAccount.call(
      username: @curator_data['username'],
      password: @curator_data['password']
    )
  end

  it 'HAPPY: should be able to add a participant to a event' do
    Candyland::AddParticipantToEvent.call(
      auth: @auth,
      participant_email: @participant.email,
      event: @event
    )

    _(@participant.events.count).must_equal 1
    _(@participant.events.first).must_equal @event
  end

  it 'BAD: should not add curator as a participant' do
    _(proc {
      Candyland::AddParticipantToEvent.call(
        auth: @auth,
        participant_email: @curator.email,
        event: @event
      )
    }).must_raise Candyland::AddParticipantToEvent::ForbiddenError
  end
end
