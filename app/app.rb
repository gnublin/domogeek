# frozen_string_literal: true

require 'sinatra'
require 'sinatra/base'
require 'slim'
require 'yaml'
require 'puma'

class DomoGeek < Sinatra::Application
  set :root, File.dirname(__FILE__) + '/..'
  set :slim, layout: :_layout
  set :public_folder, 'node_modules'
  get '/' do
    slim :view
  end

  get "/404" do
    slim :not_found
  end

end