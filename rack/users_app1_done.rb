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

app =  lambda do |env|
  body = @header
  status = 500

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
