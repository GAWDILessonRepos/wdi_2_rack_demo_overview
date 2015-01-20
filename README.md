![General Assembly Logo](http://i.imgur.com/ke8USTq.png)

# Rack and HTTP Overview

[Rack](http://rack.github.io/) provides a minimal interface between webservers supporting Ruby and Ruby frameworks. Ruby web frameworks,(Rails, Sinatra, etc.), are built on top of Rack. 

RubyOnRails has the concept of Middleware which is a way of intercepting and processing an HTTP Request/Request. All Middleware are Rack  apps.

## Objectives

By the end of this, students should be able to:

- Understand URL encoding, i.e. using special codes for some characters in a URL.
- Understand how a HTML Form and it's query string are processed and converted into a params hash.
- Understand how a HTTP Request is routed using it's resource path.
- Introduce Model View Controller.

## Demo  
#### Create the simplest Rack app possible.  
This mimimal app will show the current time. *That's all*

To use Rack, provide an "app": an object that responds to the call method, taking the environment hash as a parameter, and returning an Array with three elements:

* The HTTP response code
* A Hash of HTTP Response headers
* The response body, which must respond to each

We'll use a lambda here that will return an array with three entries, the entries will be:    
1. A HTTP Status Code of 200. 200 is the code for OK.  
2. A Ruby hash that contains the HTTP Response Header fields.   
3. The body of HTTP Request.  

This Rack app will run the WEBrick server on port 1234 listening for Requests. 

##### Create a Rack app. 

```touch rack/simplest.rb```  

Add the below code:  

```
require 'rubygems'
require 'rack'
                                                           
app =  lambda{ |env|  [200, {'Content-Type' => 'text/plain'}, ["The time is #{Time.now}"] ] }
                                             
Rack::Handler::WEBrick.run app, Port: 1234
```

##### Run the Rack app.
 
```
ruby rack/simplest.rb
```

##### Send a HTTP Request with curl.  
```
curl -v http://localhost:1234
```

##### Send a HTTP Request with Chrome.  

http://localhost:1234

Open the Chrome Inspector and go to the Network tab. Refresh and look at the HTTP Request/Response.

## Lab 
* Create a rack app that will return HTML with your name and current form of transportation,(auto, MBTA, ...). 
* Use a browser and curl to request this page.

## Demo
### Show the HTTP Request Headers

Rack puts all the Request Headers, and other info, inside the env argument that is passed to the lambda. This env argument is a Ruby Hash. 

Now we can implement all kinds of business logic that can depend on the HTTP Request's path, the Query String, etc.

In this case we're just going to build a string from some of this info found in the env hash. Then we will send it back to the client as a HTTP Repsonse.

```
touch rack/show_http_headers.rb
```

Add this code. 

```
require 'rubygems'
require 'rack'

	# Return the contents of the env passed to this rack app.                                          
app = lambda do |env|
  # HTTP Request Header                                                                            
  response = []
  response << "Method: #{env['REQUEST_METHOD']}"
  response << "Request URI: #{env['REQUEST_URI']}"
  response << "Query String: #{env['QUERY_STRING']}"
  response << "Request Path: #{env['REQUEST_PATH']}"
  response << "Accept: #{env['HTTP_ACCEPT']}"
  response << "Accept Language: #{env['HTTP_ACCEPT_LANGUAGE']}"
  response << "User Agent: #{env['HTTP_USER_AGENT']}"
  response << "URL Scheme: #{env['rack.url_scheme']}\n"

  [200, {'Content-Type' => 'text/plain'}, [response.join("\n")] ]
end

Rack::Handler::WEBrick.run app, Port: 1234

```

```
curl -i http://localhost:1234/this/is/my/path?name=jack&age=33
```

In Chrome.  
http://localhost:1234/this/ia/my/path?name=jack&age=33

### Query String  
[Query Strings](http://en.wikipedia.org/wiki/Query_string) are a way to send data to the back end server over HTTP. For example:  

http://localhost:1234/this/ia/my/path?name=jack&age=33   

The query string is 'name=jack&age=33'  

It's made up of key value pairs where:  
* The entire query string is separated, delimited, by the question character, '?'.  
* Each key value pair is seperated by the ampersand character, '&'  
* The key value are seperated by the equals sign, '='.  
* Some characters, such as spaces, are URL Encoded. [URL Encoding](http://en.wikipedia.org/wiki/Query_string#URL_encoding)   

 

##Lab
Create a Rack app that will print to standard output, *yes use puts*, each key value pair in the query string.

```
name is jack  
age is 33  
```

And it will return an HTML page showing the name and age.

On the command line:  
```
curl -v 'http://localhost:1234?name=jack&age=33'
```


### GET vs POST Query String  
The query string can be used with either a **GET** or **POST** Request. 

When using a **GET** request the query string will be appended to the end of the URL. *Careful using this, there are limits on the length of a URL*

```
curl -v 'http://localhost:1234/some/path/here?name=tom&age=57&height=74'
```

When using a **POST** request the query string will typically reflect the contents of an **HTML Form**. And it will be send to the server in the body of the request.

```
curl -v --data 'name=tom&age=57&height=74' 'http://localhost:1234/some/path/here'
```

## Lab

##### Step 1
Create a rack app that returns a HTML form asking for a *name* and *age* at the URL http://localhost:1234/users/new. 

```
touch rack users_app.rb
```

```
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

```


##### Step 2

When the form is submitted a HTTP POST will be sent to localhost:1234/user. 

The Query String that contains the submitted fields will be in the body of the HTTP Request. So we need a way to get these fields.

We are going to put these submitted fields in a **params hash**

#### Create a params hash from a query string.  
In Rails we will be dealing **a lot** with something called a **params hash**. This is just a Ruby Hash that reflects the contents of a query string.


Lets create a method that will create a params hash from a **POST** and **GET**.

Update the rack/users_app.rb

```

 # get the query string for GET and POST requests
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


```

##### Step 3

Handle the Form POST.  
* Add a condition to handle a POST to /users. **This is a route**  
* Create a User class with a name and age attribute.  
* Create an instance of this class using the form fields.  
* Return HTML that shows this user's name and age.  

```

 # handle the POST Request from the form!
 elsif '/users' == env['REQUEST_PATH'] && 'POST' == env['REQUEST_METHOD']
    # create a new user                                                                            
    user = User.new(params[:name], params[:age])
    body = ...
    status = 200

```

## Lab
Write a simple Rack app, based on the above, that will fill in the blanks in the below text from URL params. The filled in text will be returned by the HTTP Response. The words in __bold__ are going to be replaced by URL params.

"__Who__ arrested __name__ for __crime__ earlier this week, and according to a report by the __source__, the incident stemmed from a dispute over a __object__."

Example:  
"__Police__ arrested __a Main Street resident__ for __illegal possession of a handgun and ammunition__ earlier this week, and according to a report __in the Lowell Sun__, the incident stemmed from a dispute over a __frozen cheese pizza__."

```
curl -v 'http://localhost:1234/?who=The Police&name=a Main Street resident&crime=possesion of a handgun&source=in the Lowell Sun&object=frozen cheess pizza'
```

Use *BOTH* a HTTP **POST** and **GET**.

##### Question what are the %20 in the response?  
   
## Bonus
Look thru the rack/mini_mvc.rb and understand the router and controller code.


