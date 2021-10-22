source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end
gem 'chunky_png', '~> 1.3'
gem 'mini_magick', '~> 4.10'
gem 'sidekiq', '~> 6.2'
gem 'rubysl-securerandom', '~> 2.0'
gem 'valid_syntax', '~> 1.0'
gem 'rails', '~> 6.0'
gem 'mysql2', '~> 0.5.3'
gem 'thin', '~> 1.7'
gem 'sass-rails', '~> 6.0'
gem 'uglifier', '~> 4.2'
gem 'execjs', '~> 2.7'
gem 'therubyracer', platforms: :ruby
gem 'jquery-rails', '~> 4.3'
gem 'coffee-rails', '~> 5.0'
gem 'turbolinks', '~> 5.2'
gem 'jbuilder', '~> 2.9'

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
