require 'rubygems'
require 'rack'

def query_str(env)
  http_method = env['REQUEST_METHOD']
  http_method = env['REQUEST_METHOD']
  if http_method == 'GET'
    env['QUERY_STRING']
  elsif http_method == 'POST'
    env['rack.input'].gets
  end
end

# Given a URL query string create a hash of key value pairs
def create_params(env)
  params = {}
  query_str(env).split('&').each do |str_entry|
    key, value = str_entry.split('=')
    params[key.to_sym] = value
  end
  params
end

app =  lambda do |env|
  params = create_params(env)
  body = "#{params[:name]} is #{params[:age]} years old and is #{params[:height]} inches tall"
  [200, {'Content-Type' => 'text/plain'}, [body] ]
end

# Using the WEBrick HTTP server listening on port 1234
Rack::Handler::WEBrick.run app, Port: 1234

# On the command line
#######################

# Run this rack app.
# ruby rack/query_to_params_done.rb

# Send a HTTP request
# curl -v 'http://localhost:1234/some/path/here?name=tom&age=57&height=74'
