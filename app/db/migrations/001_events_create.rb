# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:events) do
      primary_key :id
      foreign_key :location_id, table: :locations

      String :title, unique: true, null: false
      String :description, null: false
      String :time, null: false
      String :curator, null: false

      DateTime :created_at
      DateTime :updated_at

      unique %i[location_id title]
    end
  end
end
