# MIT License
# Copyright (c) 2022 Gauthier FRANCOIS
# frozen_string_literal: true

require 'bundler/setup'
require './app/app'
require 'logger'

Bundler.require :default, :development
run DomoGeek
