# frozen_string_literal: true

require 'roda'
require_relative './app'

module Candyland
  # Auth controller for Candyland API
  class Api < Roda
    route('auth') do |routing|
      # All requests in this route require signed requests
      begin
        @request_data = SignedRequest.new(Api.config).parse(request.body.read)
      rescue SignedRequest::VerificationError
        routing.halt '403', { message: 'Must sign request' }.to_json
      end

      routing.on 'register' do
        # POST api/v1/auth/register
        routing.post do
          VerifyRegistration.new(@request_data).call

          response.status = 202
          { message: 'Verification email sent' }.to_json
        rescue VerifyRegistration::InvalidRegistration => e
          routing.halt 400, { message: e.message }.to_json
        rescue VerifyRegistration::EmailProviderError
          Api.logger.error "Could not send registration email: #{e.inspect}"
          routing.halt 500, { message: 'Error sending email' }.to_json
        rescue StandardError => e
          Api.logger.error "Could not verify registration: #{e.inspect}"
          routing.halt 500
        end
      end

      # POST /api/v1/auth/sso
      routing.post 'sso' do
        auth_account = AuthorizeSso.new.call(@request_data[:access_token])
        { data: auth_account }.to_json
      rescue AuthorizeSso::NoEmailError
        routing.halt 400
      rescue StandardError => e
        puts "FAILED to validate SSO account: #{e.inspect}"
        puts error.backtrace
        routing.halt 500
      end

      routing.is 'authenticate' do
        # POST /api/v1/auth/authenticate
        routing.post do
          auth_account = AuthenticateAccount.call(@request_data)
          auth_account.to_json
        rescue AuthenticateAccount::UnauthorizedError
          routing.halt '403', { message: 'Credential Error' }.to_json
        end
      end
    end
  end
end
