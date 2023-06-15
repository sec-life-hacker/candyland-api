# frozen_string_literal: true

module Candyland
  # Policy to determine if account can view an location
  class LocationPolicy
    def initialize(account, location, auth_scope = nil)
      @account = account
      @location = location
      @auth_scope = auth_scope
    end

    def can_view?
      can_read?
    end

    def can_edit?
      can_write? && account_is_finder?
    end

    def can_delete?
      can_write? && account_is_finder?
    end

    def summary
      {
        can_view: can_view?,
        can_edit: can_edit?,
        can_delete: can_delete?
      }
    end

    private

    def can_read?
      @auth_scope ? @auth_scope.can_read?('locations') : false
    end

    def can_write?
      @auth_scope ? @auth_scope.can_write?('locations') : false
    end

    def account_is_finder?
      @location.finder == @account
    end
  end
end
