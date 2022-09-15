# MIT License
# Copyright (c) 2022 Gauthier FRANCOIS
# frozen_string_literal: true

require 'sinatra'
require 'sinatra/base'
require 'slim'
require 'yaml'
require 'puma'
require 'pry'

require_relative '../lib/helpers'

# DomoGeek application
class DomoGeek < Sinatra::Application
  configure :production do
    log_file_path = ENV.fetch('RACK_LOGFILE', '/var/log/sinatra.log')
    FileUtils.touch(log_file_path) unless File.exist? log_file_path
    raise "File #{log_file_path} is not writable" unless File.writable?(log_file_path)

    log_file = File.new(log_file_path, 'a')
    $stdout.reopen(log_file)
    $stderr.reopen(log_file)
    $stdout.sync = true
    $stderr.sync = true
  end

  set :root, "#{File.dirname(__FILE__)}/.."
  set :slim, layout: :_layout
  set :public_folder, 'node_modules'
  get '/' do
    slim :view
  end

  get '/holidayall/:zone/:daterequest' do
    datereq = Time.now
    @result = {}
    redirect '/404' unless %w[A B C Corse].include? params[:zone]

    datereq = Date.parse(params[:daterequest]) unless params[:daterequest] == 'now'

    datereq_d, datereq_m, datereq_y = datereq.strftime('%d-%m-%Y').split('-')
    @result[:weekend] = DateHelpers.weekend?(datereq)
    @result[:holiday] =
      DateHelpers.bank_holidays?(Date.civil(datereq_y.to_i, datereq_m.to_i, datereq_d.to_i))
    ics_calendar = IcsHelpers.load_ics
    @result[:schoolholiday] = 'False' if ics_calendar.nil?
    @result[:schoolholiday] = DateHelpers.school_holiday?(ics_calendar, datereq, params[:zone]) if ics_calendar.any?
    content_type :json
    @result.to_json
  end

  get '/404' do
    slim :not_found
  end

  get '/*' do
    redirect '/404'
  end
end
