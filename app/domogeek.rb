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

  get ['/myip', '/myip/:responsetype'] do
    responsetype = params[:responsetype] == 'json' ? 'json' : 'text'
    @result = { myip: request.ip }
    content_type responsetype
    responsetype == 'json' ? @result.to_json : request.ip
  end

  get '/geolocation/:city' do
    res_city = GeoNames::Search.search({name: params[:city]})
    @result = {latitude: 0, longitude: 0 }
    unless res_city['totalResultsCount'] == 0
      @result[:latitude] = res_city['geonames'].first['lat']
      @result[:longitude] = res_city['geonames'].first['lng']
    end
    content_type :json
    @result.to_json
  end

  get ['/404', '/404/:responsetype'] do
    if params[:responsetype] == 'json'
      content_type :json
      { http_status_code: '404', reason: 'Not implemented yet' }.to_json
    else
      content_type :html
      slim :not_found
    end
  end

  get '/400/json/:err_message' do
    status 400
    content_type :json
    { http_status_code: '400', reason: err_message }.to_json
  end

  get '/*' do
    redirect '/404/json'
  end
end
