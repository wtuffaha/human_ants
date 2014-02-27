require 'sinatra'
require 'haml'
#require 'debugger'
require 'json'

set :public_folder, 'public'

$nodes = {}

get '/' do
  haml :index
end

post '/loc' do
  info = params.merge(:timestamp => Time.now.utc.to_i)
  $nodes[request.env['REMOTE_ADDR']] = info

  clean_nodes

  (active_nodes - [info]).to_json
end

def active_nodes
  $nodes.select { |k, v| v['active'] == 'true' }.map(&:last)
end

def clean_nodes
  $nodes = $nodes.reject { |k, v| v[:timestamp] < Time.now.utc.to_i - 20 }
end
