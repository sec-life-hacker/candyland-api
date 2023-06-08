# frozen_string_literal: true

module Candyland
  # Policy to determine if account can view an event
  class EventPolicy
    def initialize(account, event, auth_scope = nil)
      @account = account
      @event = event
      @auth_scope = auth_scope
    end

    def can_view?
      can_read?
    end

    def can_view_detail?
      can_read? && (account_curates_event? || account_participates_event?)
    end

    def can_edit?
      can_write? && account_curates_event?
    end

    def can_delete?
      can_write? && account_curates_event?
    end

    def summary
      {
        can_view: can_view?,
        can_view_detail: can_view_detail?,
        can_edit: can_edit?,
        can_delete: can_delete?
      }
    end

    private

    def can_read?
      @auth_scope ? @auth_scope.can_read?('events') : false
    end

    def can_write?
      @auth_scope ? @auth_scope.can_write?('events') : false
    end

    def account_curates_event?
      @event.curator == @account
    end

    def account_participates_event?
      @event.participants.include?(@account)
    end
  end
end
