require 'test/unit'
require 'rack/test'
$:<< '.'
require 'broker'

ENV['RACK_ENV'] = 'test'

class BrokerTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_it_says_hi
    get '/hi'
    assert last_response.ok?
    assert_equal 'Hello World!', last_response.body
  end

  #def test_it_says_hello_to_a_person
  #  get '/', :name => 'Simon'
  #  assert last_response.body.include?('Simon')
  #end
  
  def test_list_pools
    get '/pools'
    assert last_response.ok?
  end
end
