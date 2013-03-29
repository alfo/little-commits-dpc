require 'sinatra'
require 'json'
require 'faraday'

get '/' do
	'Hey'
end

post '/hook' do
	push = JSON.parse(params[:payload])
	
	message = push["commits"].last["message"]
	
	"The message was #{message}"
end