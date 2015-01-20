require 'rubygems'
require 'rack'
require 'pry-byebug'

# HTML Snippets
@header = <<-END.gsub(/^ {2}/, '')
  <html>
    <head>
    </head>
    <body>
END

@footer = <<-END.gsub(/^ {2}/, '')
    </body>
  </html>

END

@new_user_form_html = <<-END.gsub(/^ {2}/, '')
      <form action="/users" method='POST'>
        Name: <input type="text" name="name"><br>
        Age: <input type="text" age="age"><br>
        <input type="submit" value="Submit">
      </form>
END
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
  body = @header
  status = 500

  params = create_params(env)

  if '/users/new' == env['REQUEST_PATH']
    # show the form to create a new user
    body << @new_user_form_html
    status = 200
  else
    body = "<h1>Unknown route</h1>"
  end
  body << @footer

  [status, {'Content-Type' => 'text/html'}, [body] ]
end

Rack::Handler::WEBrick.run app, Port: 1234
