source "https://rubygems.org"

gemspec

gem "rails", ENV['RAILS_VERSION']

group :development, :test do
  gem "pry"
  gem "ember-cli-rails", github: "thoughtbot/ember-cli-rails"
end

group :test do
  gem "poltergeist", "~> 1.8.0"
  gem "rspec-rails"
end
