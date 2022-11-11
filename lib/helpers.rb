# MIT License
# Copyright (c) 2022 Gauthier FRANCOIS
# frozen_string_literal: true

require 'holidays'
require 'icalendar'

# Helper to know all about dates
class DateHelpers
  def self.bank_holidays?(datereq)
    holidays = Holidays.on(datereq, :fr).map { |a| a[:name] }
    holidays.empty? ? 'False' : holidays.first
  end

  def self.weekend?(datereq)
    if datereq.sunday? || datereq.saturday?
      'True'
    else
      'False'
    end
  end

  def self.school_holiday?(calendar, datereq, zone)
    school_cal_current = calendar[0].parent.events.select { |a| a.dtstart.to_date > Date.parse('2022-09-01') }
    all_current_holidays =
      school_cal_current.select { |a| a.dtstart.to_date <= datereq.to_date && datereq.to_date < a.dtend.to_date }
    if all_current_holidays.empty?
      'False'
    else
      all_current_holidays.first.location.match?(/#{zone}/) ? all_current_holidays.first.description : 'False'
    end
  end
end

# Helper for ISC calender loading
class IcsHelpers
  def self.load_ics
    school_file = File.open('tests/Zone-A-B-C-Corse.ics')
    Icalendar::Calendar.parse(school_file).first.events
  rescue StandardError
    nil
  end
end
