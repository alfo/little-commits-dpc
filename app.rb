require 'sinatra'
require 'json'

get '/' do
	'Hey'
end

post '/hook' do
	push = JSON.parse(params[:payload])
	"I got some JSON: #{push.inspect}"
end