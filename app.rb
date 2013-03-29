require 'sinatra'
require 'json'
require 'faraday'

# Show the index page
get '/' do
	send_file File.join(settings.public_folder, 'index.html')
end

# We're being sent a post request!
post '/hook/:code' do
	push = JSON.parse(params[:payload])
	
	# These bits aren't very nice, but they match what GitHub says at https://help.github.com/articles/post-receive-hooks
	repo = push["repository"]["name"]
	commit = push["commits"].last
	message = commit["message"]
	id = commit["id"]
	name = commit["author"]["name"]
	username = commit["author"]["username"]
	date = Time.parse(commit["timestamp"]).strftime('%l:%m:%S%P %Z %e/%m/%y')
	
	connection = Faraday.new('http://remote.bergcloud.com')
	
	# This is a horrible way to do it, but it works for now
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
	
	# Send the request off to BERGCloud
	response = connection.post("playground/direct_print/#{params[:code]}", :html => html)
	
	# This isn't recieved by anyone but it's useful for debugging
	"The message was #{message} with a commit ID of #{id}"
end