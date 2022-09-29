# MIT License
# Copyright (c) 2022 Gauthier FRANCOIS
# frozen_string_literal: true

require 'active_support/all'
require 'sinatra'
require 'sinatra/base'
require 'slim'
require 'yaml'
require 'puma'
require 'pry'

require_relative '../lib/helpers'
require_relative '../lib/date'
require_relative '../lib/sun'

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
    res_city = GeoNames::Search.search({ name: params[:city] })
    @result = { latitude: 0, longitude: 0 }
    unless (res_city['totalResultsCount']).zero?
      @result[:latitude] = res_city['geonames'].first['lat']
      @result[:longitude] = res_city['geonames'].first['lng']
    end
    content_type :json
    @result.to_json
  end

  get ['/sun/:city/:sunrequest/:date', '/sun/:city/:sunrequest/:date/:responsetype'] do
    @result = {}
    datereq = Time.now.strftime('%Y-%m-%d')
    datereq = params[:date] unless params[:date] == 'now'
    responsetype = params[:responsetype] == 'json' ? 'json' : 'text'
    content_type responsetype

    res_city = GeoNames::Search.search({ name: params[:city] })
    return {} if (res_city['totalResultsCount']).zero?

    lat = res_city['geonames'].first['lat']
    lng = res_city['geonames'].first['lng']

    sun_details = SunHelper.details(lng, lat, datereq)
    return {} unless sun_details['status'] == 'OK'

    sun_details_res = sun_details['results']
    Time.zone = 'Paris'
    @result = {
      dayduration: sun_details_res['day_length'].split(':')[0..1].join(':'),
      sunset: Time.parse("#{sun_details_res['sunset']} UTC").in_time_zone.strftime('%R'),
      sunrise: Time.parse("#{sun_details_res['sunrise']} UTC").in_time_zone.strftime('%R'),
      zenith: Time.parse("#{sun_details_res['solar_noon']} UTC").in_time_zone.strftime('%R')
    }
    return @result[params[:sunrequest].to_sym] unless params[:sunrequest] == 'all'

    @result.to_json
  end

  get ['/season', '/season/:responsetype'] do
    responsetype = params[:responsetype] == 'json' ? 'json' : 'text'
    season = Date.today.season
    content_type responsetype
    @result = { 'season' => season }
    responsetype == 'json' ? @result.to_json : season
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
