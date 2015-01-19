require 'rubygems'
require 'rack'
require 'pry-byebug'

def get_id(env)
  env['REQUEST_PATH'].split('/').last.to_i
end

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
  params[:id] = get_id(env)
  params
end

class StoogesController
  @@stooges = [
    'Moe',
    'Larry',
    'Curly'
  ]

  def initialize(params)
    @params = params
  end

  def index
    @@stooges.join(',')
  end

  def show
    @@stooges[@params[:id]]
  end
end

class Router
  # consist of a [http method][path][controller action]
  @@routes = []

  def self.routes
    @@routes
  end

  def self.get(path, cntrl_action_str)
    routes << {method: 'GET', path: path, cntrl_action: cntrl_action_str}
  end

  def self.post(path, cntrl_action_str)
    routes << {method: 'POST', path: path, cntrl_action: cntrl_action_str}
  end

  def self.find(http_method, path)
    route = routes.find do |route|
      route[:method] == http_method && route[:path] == path
    end
    route[:cntrl_action]
  end

  def self.dispatch(env)
    controller_action =  find(env['REQUEST_METHOD'], env['REQUEST_PATH'])
    klass_name, method_name = controller_action.split('#')
    klass = Object.const_get(klass_name.capitalize << "sController")
    controller = klass.new(create_params(env))
    controller.send(method_name)
  end
end

Router.get('/stooge/1', 'stooge#show')
Router.get('/stooges', 'stooge#index')

app =  lambda do |env|
  body = Router.dispatch(env)
  [200, { }, [body] ]
end

# Using the WEBrick HTTP server listening on port 1234
Rack::Handler::WEBrick.run app, Port: 1234

# On the command line
#######################

# Run this rack app.
# ruby rack/query_to_params_done.rb

# Send a HTTP request
# curl -v 'http://localhost:1234/some/path/here?name=tom&age=57&height=74'
