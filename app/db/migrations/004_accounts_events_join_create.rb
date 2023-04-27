# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_join_table(participant_id: :accounts, event_id: :events)
  end
end
