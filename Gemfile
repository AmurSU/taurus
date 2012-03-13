source "http://rubygems.org"

gem "rails", "~> 2.3.8"

gem "devise", "~> 1.0.8"
gem "erubis"
gem "haml", "~> 3.0.21"
gem "pdfkit"
gem "pg"
gem 'whenever'
gem 'unicode'
gem 'nokogiri'

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
  gem 'ruby-debug'
end
