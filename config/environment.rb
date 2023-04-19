# frozen_string_literal: true

require 'roda'
require 'figaro'
require 'sequel'
require 'logger'
require './app/lib/secure_db'

module Candyland
  # Configuration for the API
  class Api < Roda
    plugin :environments

    # rubocop:disable Lint/ConstantDefinitionInBlock
    configure do
      # load config secrets into local environment variables (ENV)
      Figaro.application = Figaro::Application.new(
        environment: environment, # rubocop:disable Style/HashSyntax
        path: File.expand_path('config/secrets.yml')
      )
      Figaro.load

      # Make the environment variables accessible to other classes
      def self.config = Figaro.env

      # Connect and make the database accessible to other classes
      db_url = ENV.delete('DATABASE_URL')
      DB = Sequel.connect("#{db_url}?encoding=utf8")
      def self.DB = DB # rubocop:disable Naming/MethodName

      # HTTP Request loggin
      configure :development, :production do
        plugin :common_logger, $stdout
      end

      # Custom events loggin
      LOGGER = Logger.new($stdout)
      def self.logger = LOGGER

      # Load crypto keys
      SecureDB.setup(ENV.delete('DB_KEY'))
    end

    configure :development, :test do
      require 'pry'
      logger.level = Logger::ERROR
    end
  end
end
