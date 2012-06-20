require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'haml'
require 'sass'
require 'coffee_script'

configure do
  set :haml, { :format => :html5, :layout_engine => :erb }
end

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
end

not_found do
  File.read(File.join('public', '404.html'))
end

get '/css/:name.css' do
  content_type 'text/css', :charset => 'utf-8'
  scss :"stylesheets/#{params[:name]}"
end

get '/js/script.js' do
  coffee :"javascripts/script"
end

get '/' do
  haml :index
end
