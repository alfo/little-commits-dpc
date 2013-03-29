require 'sinatra'
require 'json'
require 'faraday'

get '/' do
	'Hey'
end

post '/hook/:code' do
	push = JSON.parse(params[:payload])
	
	repo = push["repository"]["name"]
	
	commit = push["commits"].last
	message = commit["message"]
	id = commit["id"]
	name = commit["author"]["name"]
	username = commit["author"]["username"]
	date = Time.parse(commit["timestamp"]).strftime('%l:%m:%S%P %Z %e/%m/%y')
	
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
			p { margin: 10px 0; font-size: 24px; }
			.id { font-family: 'Courier New'; font-size: 15px; text-align: center; margin: 0; }
			.author { text-align: center; }
			img { display: block; margin: 10px auto; }
		</style>
	</head>

	<body>
		<img src='http://little-commits.herokuapp.com/github.png'>
		=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
		<h1>#{repo}</h1>
		=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
		<p class='message'>#{message}</p>
		----------------------------------------------------------------
		<p class='id'>#{id}</p>
		----------------------------------------------------------------
		<p class='author'>#{date} <br> #{name} (#{username})</p>
	</body>
</html>"
	
	response = connection.post("playground/direct_print/#{params[:code]}", :html => html)
	
	"The message was #{message} with an ID of #{id} with a code of #{params[:code]}"
end