# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'delicious'

class DeliciousTest < Test::Unit::TestCase
  def test_foo
    assert(false, 'Assertion was false.')
    flunk "TODO: Write test"
    # assert_equal("foo", bar)
  end
end