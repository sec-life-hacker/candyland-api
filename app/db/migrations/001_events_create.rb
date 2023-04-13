# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:events) do
      primary_key :id

      String :title, unique: true, null: false
      String :description, null: false
      DateTime :time, null: false
      String :curator, null: false

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
