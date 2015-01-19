![General Assembly Logo](http://i.imgur.com/ke8USTq.png)

# Rack and HTTP Overview

[Rack](http://rack.github.io/) provides a minimal interface between webservers supporting Ruby and Ruby frameworks. All Ruby web frameworks are built on top of Rack. 

RubyOnRails has the concept of Middleware which is just a small Rack app that processes a HTTP request/response.

## Objectives

By the end of this, students should be able to:

- Understand URL encoding, i.e. using special codes for some characters in a URL.
- Understand how a HTML Form and query string are processed and converted into a params hash.
- Understand how a HTTP Request is routed using it's resource path.
- Introduce Model View Controller.

## Demo  
#### Create the simplest Rack app possible.  
This mimimal app will show the current time. *That's all*

We'll use a lambda that will return an array with three entries, the entries will be:  
1. A HTTP Status Code, 200 is the code for OK.  
2. A Ruby hash that contains the HTTP Response Header fields.  
3. The body of HTTP Request.  
4. It will run the WEBrick server on port 1234 listening for Requests. 

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

Rack puts all the Request Headers, and other info, inside env argument that is passed to the lambda. This env argument is a Ruby Hash. 

Now we can implement all kinds of business logic that can depend on the HTTP Request's path, the URL parameters, etc.

In this case we're just going to build a string from some of this env info and sent it back to the client.

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

  [200, { }, [response.join("\n")] ]
end

Rack::Handler::WEBrick.run app, Port: 1234

```

```
curl -i http://localhost:1234/this/is/my/path?name=jack&age=33
```

In Chrome.  
http://localhost:1234/this%20is%20it/but/not%20the%20/end?name=jack&age=33

### Query String  
[Query Strings](http://en.wikipedia.org/wiki/Query_string) are a way to send data to the back end server over HTTP. For example:  

http://localhost:1234/this%20is%20it/but/not%20the%20/end?name=jack&age=33   

The query string is 'name=jack&age=33'  

They are key value pairs where:  
* The entire query string is separated, delimited, by the question character, '?'.  
* Each key value pair is seperated by the ampersand character, '&'  
* The key value are seperated by the equals sign, '='.  
* Some characters, such as spaces, are URL Encoded. [URL Encoding](http://en.wikipedia.org/wiki/Query_string#URL_encoding)   

 

##Lab
Create a Rack app that will print out, *yes use puts*, each key value pair in the query string.

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

When using a **GET** request the query string will be appended to the end of the URL. *Careful using this*

```
curl -v 'http://localhost:1234/some/path/here?name=tom&age=57&height=74'
```

When using a **POST** request the query string will typically reflect the contents of an **HTML Form**. And it will be send to the server in the body of the request.

```
curl -v --data 'name=tom&age=57&height=74' 'http://localhost:1234/some/path/here'
```

#### Create a params hash from a query string.  
In Rails we will be dealing **a lot** with something called a **params hash**. This is just a Ruby Hash that reflects the contents of a query string.


Lets create a method that will create a params hash from a **POST** and **GET**.

```
touch rack/query_to_params.rb
```

```
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

Rack::Handler::WEBrick.run app, Port: 1234
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
   

## Lab 

Write a Rack app, like the above, but also create a method named 'get'. 

This method named 'get' will take two arguments. The first argument will be the resource path and the second argument will be a return string to send back in the body of the HTTP Response.

The lambda will call this get method and get will:
* create a Ruby hash named params
* extract the key value pairs in the URL parameters and add each pair into the params hash.
* use this params hash to substitute into the return string given as the second argument to the gets method.

For example:

```get '/stooges/show?location="Boston"&date="1-10-1944"', "<html>...<body><h3>Place: #{params[:location]}</h3><h5>Date: #{date}</body></html>"```

### Lab
Change the get method to have a second argument of the form class#method.

```get '/stooges/3', 'stooge#show' ```

This will:  
1. Create a stooge object, an instance of a Stooge class.   
2. Call the show method on this object passing the 3, lets call 3 the index, from the path as an argument.  
3. Use this index, integer 3, to lookup a stooge in an Array of Stooges!  

```
class Stooge
  STOOGES = %w{ Larry Moe Curly Joe}
  
  def show(params)
  "Hello #{STOOGES[params[:id]]}, yuk, yuk"
  end
end

def path_to_params(path)
  ...
end

def get(path, class_method_str)
 # Get id from resource path.
 params = path_to_params(path)
 # params[:id] = 3
  ...
  
  # May want to determine which kind of object 
  # to create and which method to call 
  # from the class_method_str argument!
  
  stooge = Stooge.new
  stooge.show(params)
end

app = lambda do |env|
  body = get(#{env['REQUEST_PATH'], 'stooge#show')
  [200, { }, [body] ]
end
```


                                                                      


