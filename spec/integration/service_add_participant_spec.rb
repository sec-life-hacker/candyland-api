# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test AddParticipantToEvent service' do
  before do
    wipe_database

    DATA[:accounts].each do |account_data|
      Candyland::Account.create(account_data)
    end

    event_data = DATA[:events].first

    @curator = Candyland::Account.all[0]
    @participant = Candyland::Account.all[1]
    @event = Candyland::CreateEventForCurator.call(
      curator_id: @curator.id, event_data:
    )
  end

  it 'HAPPY: should be able to add a participant to a event' do
    Candyland::AddParticipantToEvent.call(
      email: @participant.email,
      event_id: @event.id
    )

    _(@participant.events.count).must_equal 1
    _(@participant.events.first).must_equal @event
  end

  it 'BAD: should not add curator as a participant' do
    _(proc {
      Candyland::AddParticipantToEvent.call(
        email: @curator.email,
        event_id: @event.id
      )
    }).must_raise Candyland::AddParticipantToEvent::CuratorNotParticipantError
  end
end
