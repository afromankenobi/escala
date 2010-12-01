# This file goes in domain.com/config.ru
require 'rubygems'
require 'sinatra'
 
set :views, File.dirname(__FILE__) + "/views"
set :env,  :production
disable :run

require './escala.rb'

run Sinatra::Application
