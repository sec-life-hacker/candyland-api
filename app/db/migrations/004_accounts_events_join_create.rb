# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_join_table(
      participant_id: { type: :uuid, foreign_key: true, table: :accounts },
      event_id: { type: :uuid, foreign_key: true, table: :events }
    )
  end
end
