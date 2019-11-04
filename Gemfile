source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end
gem 'chunky_png'
gem 'mini_magick'
gem 'sidekiq'
gem 'rubysl-securerandom'
gem 'valid_syntax'
gem 'rails'
gem 'mysql2'
gem 'thin'
gem 'sass-rails'
gem 'uglifier'
gem 'execjs'
gem 'therubyracer', platforms: :ruby
gem 'jquery-rails'
gem 'coffee-rails'
gem 'turbolinks'
gem 'jbuilder'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # Adds support for Capybara system testing and selenium driver
  gem 'selenium-webdriver'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
