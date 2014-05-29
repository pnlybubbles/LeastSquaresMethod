# encoding: utf-8

require 'sinatra'

class Sample < Sinatra::Base
  get "/" do
    "Hello Heroku"
  end
end
