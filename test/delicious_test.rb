require 'rubygems'
require 'test/unit'
require File.dirname(__FILE__) + "/../lib/delicious"

class DeliciousTest < Test::Unit::TestCase
  
  def setup
    @delicious = Delicious::Collector.new  
  end

  def test_popular
    assert(@delicious.popular.size > 0, "All query should return at least one occurence")    
  end
end
