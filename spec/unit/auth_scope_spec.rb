# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test AuthScope' do
  include Rack::Test::Methods

  it 'AUTH SCOPE: should validate default full scope' do
    scope = AuthScope.new
    _(scope.can_read?('*')).must_equal true
    _(scope.can_write?('*')).must_equal true
    _(scope.can_read?('event')).must_equal true
    _(scope.can_write?('event')).must_equal true
  end

  it 'AUTH SCOPE: should evalutate read-only scope' do
    scope = AuthScope.new(AuthScope::READ_ONLY)
    _(scope.can_read?('events')).must_equal true
    _(scope.can_read?('locations')).must_equal true
    _(scope.can_write?('events')).must_equal false
    _(scope.can_write?('locations')).must_equal false
  end

  it 'AUTH SCOPE: should validate single limited scope' do
    scope = AuthScope.new('events:read')
    _(scope.can_read?('*')).must_equal false
    _(scope.can_write?('*')).must_equal false
    _(scope.can_read?('events')).must_equal true
    _(scope.can_write?('events')).must_equal false
  end

  it 'AUTH SCOPE: should validate list of limited scopes' do
    scope = AuthScope.new('locations:read events:write')
    _(scope.can_read?('*')).must_equal false
    _(scope.can_write?('*')).must_equal false
    _(scope.can_read?('locations')).must_equal true
    _(scope.can_write?('locations')).must_equal false
    _(scope.can_read?('events')).must_equal true
    _(scope.can_write?('events')).must_equal true
  end
end
