# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:events) do
      uuid :id, primary_key: true
      foreign_key :curator_id, :accounts, type: :uuid
      foreign_key :location_id, :locations, type: :uuid

      String :title, unique: true, null: false, default: ''
      String :description, null: false, default: ''
      String :time_secure, null: false, default: ''

      DateTime :created_at
      DateTime :updated_at

      unique %i[title]
    end
  end
end
