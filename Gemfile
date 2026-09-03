source "https://rubygems.org"

gemspec

rails_version = ENV.fetch("RAILS_VERSION", "7.2")

if rails_version == "main"
  rails_constraint = { github: "rails/rails" }
else
  rails_constraint = "~> #{rails_version}"
end

gem "rails", rails_constraint
gem "webrick"

group :development, :test do
  gem "ember-cli-rails", github: "tricknotes/ember-cli-rails"
end

group :test do
  gem "cuprite"

  if rails_version == "main"
    # Until a release carries the fixes for frozen Rails internals,
    # e.g. https://github.com/rspec/rspec-rails/pull/2915
    gem "rspec-rails", github: "rspec/rspec-rails", branch: "main"
  else
    gem "rspec-rails"
  end
end
