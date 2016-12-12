require 'sinatra'
require 'json'

if development?
  require 'pry'
end

Dir["./lib/autoload/*.rb"].each {|file| require file }

set :bind, '0.0.0.0'

before do
  # if settings.production?
  #   redirect request.url.sub('http', 'https') unless request.secure?
  # end
  request.body.rewind
  request_body = request.body.read
  @request_payload = JSON.parse(request_body) unless request_body.empty?
end

get '/' do
  'DigitalOcean API Adapter for Nanobox. ' \
  'source: https://github.com/nanobox-io/nanobox-adapter-digitalocean'
end

get '/meta' do
  Meta.to_json
end

get '/catalog' do
  Catalog.to_json
end

post '/verify' do
  client.verify
  status 200
end

get '/keys' do
  client.keys.to_json
end

get '/keys/:id' do
  client.key(params['id']).to_json
end

post '/keys' do
  status 201
  key_id = client.key_create(@request_payload['id'], @request_payload['key'])
  { id: key_id.to_s }.to_json
end

delete '/keys/:id' do
  client.key_delete(params['id'])
  status 200
end

get '/servers' do
  client.servers.to_json
end

get '/servers/:id' do
  client.server(params['id']).to_json
end

post '/servers' do
  status 201
  server_id = client.server_order(@request_payload)
  { id: server_id.to_s }.to_json
end

delete '/servers/:id' do
  client.server_delete(params['id'])
  status 200
end

patch '/servers/:id/reboot' do
  client.server_reboot(params['id'])
  status 200
end

patch '/servers/:id/rename' do
  client.server_rename(params['id'], @request_payload['name'])
  status 200
end

# e.g. DropletKit::FailedCreate - You specified an invalid region for Droplet creation.
error DropletKit::FailedCreate do
  status 422
  body "DigitalOcean error: #{env['sinatra.error'].message}"
end

error DropletKit::Error do
  message = env['sinatra.error'].message
  status message.split(':').first
  body "DigitalOcean error: #{message}"
end

def client
  Client.new(request.env['HTTP_AUTH_ACCESS_TOKEN'])
end
