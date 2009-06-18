# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'rubygems'
require File.join(File.dirname(__FILE__),'..','..','lib','bizLogic','payment')

class PaymentTest < Test::Unit::TestCase
  include Payment
  
# Not sure what to test here: need a full integration test.
# But need to test the validations on amount > 0
  def test_setup_payment
      assert_equal 1,1
  end
  
end
