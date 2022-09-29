# MIT License
# Copyright (c) 2022 Gauthier FRANCOIS
# frozen_string_literal: true

require 'httparty'
require 'json'

SUN_API_BASE_URL = 'https://api.sunrise-sunset.org/json'

# Helper for sun position
class SunHelper
  def self.details(lng, lat, date)
    sun_response = HTTParty.get("#{SUN_API_BASE_URL}?lat=#{lat}&lng=#{lng}&date=#{date}")
    JSON.parse(sun_response.body)
  end
end
