#!/home/realtimemachine/local/ruby/bin/ruby 
$LOAD_PATH.unshift '/home/realtimemachine/local/ruby/lib'
ENV['GEM_HOME'] = '/home/realtimemachine/local/lib/ruby/gem'

load 'start.rb'

set :run, false

Rack::Handler::CGI.run Sinatra::Application