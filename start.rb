#!/home/realtimemachine/local/ruby/bin/ruby 
$LOAD_PATH.unshift '/home/realtimemachine/local/ruby/lib'
ENV['GEM_HOME'] = '/home/realtimemachine/local/lib/ruby/gem'

require 'rubygems'
require 'sinatra'
require 'cgi'
require 'uri'
require 'erb'
require 'nokogiri'
require 'open-uri'

set :run, false # HTTPサーバを立ち上げないならfalse
set :environment, :cgi

get '' do
  doc = Nokogiri::HTML(open('http://cookpad.com/'))
  @keywords = doc.css('div#trend-keyword table.hourly tr td[3] a')
  @wadai_recipe = doc.css('div#wadai-recipe-inner ul li span.recipe-title a')
  @title = "iCookpad"
  erb :index
end

get '/search/:word/:page' do
  doc = Nokogiri::HTML(open("http://cookpad.com/%E3%83%AC%E3%82%B7%E3%83%94/#{URI.escape(params[:word])}?order=date&page=#{params[:page]}&quick=1"))
  @recipes = doc.css('div.recipe-preview')
  @next = doc.css('div.paging-top a[@rel="next"]')[0]
  erb :search_partial, :layout => false
end

get '/search/:word' do
  doc = Nokogiri::HTML(open("http://cookpad.com/%E3%83%AC%E3%82%B7%E3%83%94/#{URI.escape(params[:word])}"))
  @recipes = doc.css('div.recipe-preview')
  @next = doc.css('div.paging-top a[@rel="next"]')[0]
  @result_count = doc.css('span.result-count')[0].content
  @title = "レシピ検索"
  @leftnav = '<a href="/icookpad/"><img alt="home" src="/icookpad/images/home.png" /></a>'
  erb :search
end

get '/search' do
  redirect "/icookpad/search/#{URI.escape(params[:word])}" if params[:word]
  recirect '/icookpad/'
end

get '/recipe/hot' do
  doc = Nokogiri::HTML(open("http://cookpad.com/recipe/hot"))
  @date = doc.css('div.top-10-header div')[0].content
  @recipes = doc.css('div.top-10-body ul li a')
  @title = "話題のレシピバックナンバー"
  @next = doc.css('div.top-10-footer div div[1] a')[0]
  @leftnav = '<a href="/icookpad/"><img alt="home" src="/icookpad/images/home.png" /></a>'
  @body_class = "list"
  erb :hot
end

get '/recipe/hot/:date' do
  doc = Nokogiri::HTML(open("http://cookpad.com/recipe/hot?date=#{params[:date]}"))
  @date = doc.css('div.top-10-header div')[0].content
  @recipes = doc.css('div.top-10-body ul li a')
  @next = doc.css('div.top-10-footer div div[1] a')[0]
  erb :hot_partial, :layout => false
end

get '/recipe/:id' do
  @url = "http://cookpad.com/recipe/#{params[:id]}"
  doc = Nokogiri::HTML(open(@url))
  @main_photo = doc.css('div#main-photo img')[0]['src']
  @description = doc.css('div#description')[0].content
  @materials = doc.css('table#ingredients-list tr')
  @steps = doc.css('div#steps div dl dd')
  @title = doc.css('h1.recipe-title')[0].content
  @leftnav = '<a href="/icookpad/"><img alt="home" src="/icookpad/images/home.png" /></a>'
  erb :recipe
end

Rack::Handler::CGI.run Sinatra::Application
