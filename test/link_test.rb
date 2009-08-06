require 'rubygems'
require 'test/unit'
require File.dirname(__FILE__) + "/../lib/delicious"

class LinkTest < Test::Unit::TestCase
  
  def setup
    @link = Delicious::Link.new('text', 'url', 'author', 200, ['test','test2'])
  end
  def test_equals
    link2 = Delicious::Link.new('', 'url', '', 0, [])
    assert(@link.equal?(link2), "According to url, this links have to be equals") 
  end
  
  def test_equals_should_notice_different
    link2 = Delicious::Link.new('', 'url2', '', '', [])
    assert(!@link.equal?(link2), "According to url, this links have to be different")
  end
  
  def test_comparator
    link2 = Delicious::Link.new('', 'url2', '', 201, [])
    link3 = Delicious::Link.new('', 'url3', '', 203, [])
    links = [link2, @link, link3].sort
    
    assert(@link == links[0], "#{@link} should be the firs element in this test")
    
    assert(link3 == links[2], "#{link3} should be the firs element in this test")
  end
end

