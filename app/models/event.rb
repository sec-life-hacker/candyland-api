# frozen_string_literal: true

require 'json'
require 'base64'
require 'rbnacl'

module Candyland
  STORE_DIR = 'app/db/store'

  # Class for Event entity
  class Event
    def initialize(new_event)
      @id = new_event['id'] || new_id
      @title = new_event['title']
      @description = new_event['description']
      @time = new_event['time']
      @curator = new_event['curator']
      @location = new_event['location']
    end

    attr_reader :id, :title, :description, :time, :curator, :location

    def to_json(options = {})
      JSON({
             type: 'document',
             id:,
             title:,
             description:,
             time:,
             curator:,
             location:
           }, options)
    end

    def self.setup
      FileUtils.mkdir_p(Candyland::STORE_DIR)
    end

    def save
      File.write("#{Candyland::STORE_DIR}/#{id}.txt", to_json)
    end

    def self.find(id)
      event_file = File.read("#{Candyland::STORE_DIR}/#{id}.txt")
      Event.new JSON.parse(event_file)
    end

    def self.all
      Dir.glob("#{Candyland::STORE_DIR}/*.txt").map do |file|
        file.match(%r{#{Regexp.quote(Candyland::STORE_DIR)}/(.*)\.txt})[1]
      end
    end

    private

    def new_id
      timestamp = Time.now.to_f.to_s
      Base64.urlsafe_encode64(RbNaCl::Hash.sha256(timestamp))[0..9]
    end
  end
end
