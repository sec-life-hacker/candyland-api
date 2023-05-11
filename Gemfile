# frozen_string_literal: true

source 'https://rubygems.org'
ruby File.read('.ruby-version').strip

# Web API
gem 'json'
gem 'puma', '~>5.6'
gem 'roda', '~>3.54'

# Security
gem 'rbnacl', '~>7.1'

# Testing
gem 'minitest'
gem 'minitest-rg'
gem 'rack-test'

# Debugging
gem 'pry'
gem 'rerun'

# Quality
gem 'rubocop'

# Configuration
gem 'figaro', '~>1.2'
gem 'rake'

# Database
gem 'hirb'
gem 'sequel', '~>5.67'
group :development, :test do
  gem 'sequel-seed'
  gem 'sqlite3', '~>1.6'
end
group :production do
  gem 'pg'
end

# Performance
gem 'rubocop-performance'
