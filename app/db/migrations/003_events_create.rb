# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:events) do
      uuid :id, primary_key: true
      foreign_key :location_id, table: :locations

      String :title, unique: true, null: false, default: ''
      String :description, null: false, default: ''
      String :time_secure, null: false, default: ''
      String :curator, null: false

      DateTime :created_at
      DateTime :updated_at

      unique %i[location_id title]
    end
  end
end
