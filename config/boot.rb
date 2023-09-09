ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup" # Set up gems listed in the Gemfile.
require "bootsnap/setup" if Gem.loaded_specs.has_key?("bootsnap") # Speed up boot time by caching expensive operations.
