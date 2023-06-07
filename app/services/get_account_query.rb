# frozen_string_literal: true

module Candyland
  # get account
  class GetAccountQuery
    # Error when users not allowed to access the account
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access that account'
      end
    end

    # Error when the requested account do not exist
    class NotFoundError < StandardError
      def message
        'Account not found'
      end
    end

    def self.call(requestor:, account:)
      raise NotFoundError unless account

      policy = EventPolicy.new(requestor, account)
      raise ForbiddenError unless policy.can_view?

      account
    end
  end
end
