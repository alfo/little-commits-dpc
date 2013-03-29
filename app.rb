require 'sinatra'
require 'json'
require 'faraday'

get '/' do
	'Hey'
end

post '/hook' do
	push = JSON.parse(params[:payload])
	repo = push["repository"]["name"]
	commit = push["commits"].last
	message = commit["message"]
	id = commit["id"]
	
	connection = Faraday.new('http://remote.bergcloud.com')
	
	html = "
	<html>
	<head>
		<style type='text/css'>
			* { margin: 0; }
			body {
				font-family:'Latin Modern Mono Prop';
				width: 384px;
				max-width: 384px;
				min-height: 350px;
				box-sizing: border-box;

			}

			h1 { font-size: 28px; text-align: center; font-weight: bold; }
			p { margin: 10px 0; font-size: 20px; }
			.id { font-family: 'Courier New'; font-size: 15px; text-align: center; margin: 0; }
		</style>
	</head>

	<body>
		=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
		<h1>#{repo}</h1>
		=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
		<p class='message'>#{message}</p>
		----------------------------------------------------------------
		<p class='id'>#{id}</p>
		----------------------------------------------------------------
	</body>
</html>"
	
	response = connection.post("playground/direct_print/#{ENV['DIRECT_PRINT_CODE']}", :html => html)
	
	"The message was #{message} with an ID of #{id} with a code of #{ENV['DIRECT_PRINT_CODE']}"
end