# MIT License
# Copyright (c) 2022 Gauthier FRANCOIS
# frozen_string_literal: true

require 'bundler/setup'
require 'geo_names'
require './app/domogeek'

Bundler.require :default, :development

GeoNames.configure do |config|
  config.username = ENV['GEONAMES_USERNAME']
  p config.username
end

run DomoGeek
