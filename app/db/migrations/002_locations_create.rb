# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:locations) do
      uuid :id, primary_key: true

      String :name, unique: true, null: false, default: ''
      String :description, null: false, default: ''
      String :coordinate_secure, unique: true, null: false, default: ''

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
