# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gem 'ostruct', '~> 0.5.5'
gem 'zlib', '~> 3.0'

group :development, :test do
  gem 'faker', '~> 3.1'
  gem 'rspec', '~> 3.12'
end

group :test do
  gem 'byebug', '~> 11.1'
  gem 'rubocop', '~> 1.41', require: false
  gem 'rubocop-rspec', '~> 2.16', require: false
  gem 'simplecov', require: false
  gem "simplecov-cobertura", "~> 2.1", require: false
end

