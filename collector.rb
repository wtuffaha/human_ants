require 'sinatra'
require 'haml'
#require 'debugger'
require 'json'

set :public_folder, 'public'
use Rack::Session::Cookie, :key => 'rack.session',
  :path => '/',
  :expire_after => 2592000, # In seconds
  :secret => 'bla_bla_bla'

$nodes = {}

get '/' do
  session[:uid] = session[:uid] || rand(1000_000_000)
  haml :index
end

post '/loc' do
  info = params.merge(:timestamp => Time.now.utc.to_i)
  $nodes[session[:uid]] = info

  clean_nodes

  (active_nodes - [info]).to_json
end

def active_nodes
  $nodes.select { |k, v| v['active'] == 'true' }.map(&:last)
end

def clean_nodes
  $nodes = $nodes.reject { |k, v| v[:timestamp] < Time.now.utc.to_i - 20 }
end
