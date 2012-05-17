source "http://rubygems.org"

gem "rails", "~> 3.2.0"

gem 'jquery-rails'
gem 'jquery-ui-themes'

gem "active_scaffold"
gem "recordselect"
gem "russian"
gem "devise", "~> 1.5.0"
gem "erubis"
gem "haml"
gem "pdfkit"
gem "pg"
gem 'whenever'
gem 'unicode'
gem 'nokogiri'
gem 'validates_timeliness'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', " ~> 3.2.0"
  gem 'coffee-rails', " ~> 3.2.0"
  gem 'uglifier'
  gem 'therubyracer'
end

group :production do
  gem 'unicorn'

  # Backup automated system
  gem 'backup'
  gem 'net-ssh', "~> 2.1.4"
  gem 'net-scp', "~> 1.0.4"
  gem 'mail'
end

group :development do
  gem "capistrano"
  gem "rvm-capistrano"
  gem 'ruby-debug'
end
