# frozen_string_literal: true

# Policy to determine if account can view an event
class EventPolicy
  def initialize(account, event)
    @account = account
    @event = event
  end

  def can_view?
    account_curates_event? || account_participates_event?
  end

  def can_edit?
    account_curates_event? || account_participates_event?
  end

  def can_delete?
    account_curates_event? || account_participates_event?
  end

  def summary
    {
      can_view: can_view?,
      can_edit: can_edit?,
      can_delete: can_delete?
    }
  end

  private

  def account_ocurates_event?
    @event.curator == @account
  end

  def account_participates_event?
    @document.participants.include?(@account)
  end
end
