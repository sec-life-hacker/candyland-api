# frozen_string_literal: true

module Candyland
  # Policy about participantion
  class ParticipateRequestPolicy
    def initialize(event, requestor_account, target_account, auth_scope = nil)
      @event = event
      @requestor_account = requestor_account
      @target_account = target_account
      @auth_scope = auth_scope
      @requestor = EventPolicy.new(requestor_account, event, auth_scope)
      @target = EventPolicy.new(target_account, event, auth_scope)
    end

    def can_invite?
      puts can_self_invite?
      can_write? && (
        (@requestor.can_add_participants? && @target.can_participate?) ||
          can_self_invite?
      )
    end

    def can_remove?
      can_write? &&
        (@requestor.can_remote_participants? && target_is_participant?)
    end

    private

    def can_write?
      @auth_scope ? @auth_scope.can_write?('events') : false
    end

    def target_is_participant?
      @event.participants.include?(@target_account)
    end

    def can_self_invite?
      @target.can_participate? && (@requestor_account == @target_account)
    end
  end
end
