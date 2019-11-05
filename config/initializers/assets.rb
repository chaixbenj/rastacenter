# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules')

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css )
Rails.application.config.assets.precompile += %w( app.css )
Rails.application.config.assets.precompile += %w( trix.css )
Rails.application.config.assets.precompile += %w( breakpoints.min.js )
Rails.application.config.assets.precompile += %w( browser.min.js )
Rails.application.config.assets.precompile += %w( jquery.min.js )
Rails.application.config.assets.precompile += %w( util.js )
Rails.application.config.assets.precompile += %w( main.js )
Rails.application.config.assets.precompile += %w( ace.js )
Rails.application.config.assets.precompile += %w( ext-language_tools.js )
Rails.application.config.assets.precompile += %w( mode-gherkin.js )
Rails.application.config.assets.precompile += %w( mode-ruby.js )
Rails.application.config.assets.precompile += %w( mode-python.js )
Rails.application.config.assets.precompile += %w( nicEdit.js )
Rails.application.config.assets.precompile += %w( theme-tomorrow_night.js )
Rails.application.config.assets.precompile += %w( trix.js )
Rails.application.config.assets.precompile += %w( snippets/gherkin.js )
Rails.application.config.assets.precompile += %w( snippets/ruby.js )
Rails.application.config.assets.precompile += %w( snippets/python.js )