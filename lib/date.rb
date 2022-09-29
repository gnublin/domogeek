# MIT License
# Copyright (c) 2022 Gauthier FRANCOIS
# frozen_string_literal: true

require 'date'

# Add method for Date class to retrieve the FR season
class Date
  def season
    spring_start = Date.parse("20-03-#{year}")
    summer_start = Date.parse("21-06-#{year}")
    autumn_start = Date.parse("23-09-#{year}")
    winter_start = Date.parse("21-12-#{year}")
    season = ''

    season = 'autumn' if clone < winter_start
    season = 'summer' if clone < autumn_start
    season = 'spring' if clone < summer_start
    season = 'winter' if clone < spring_start || clone > winter_start
    season
  end
end
