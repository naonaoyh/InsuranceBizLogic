# Copyright (c) 2007-2008 Orangery Technology Limited 
# You can redistribute it and/or modify it under the same terms as Ruby.
#
require 'test/unit'
require 'net/http' 
require 'lib/servicebroker/broker'

class RequestRatingServiceTest < Test::Unit::TestCase  
  TD_ROOT = File.join(File.dirname(__FILE__), 'testdata')
  
  def xtest_get_full_quote_from_rte
    open("#{TD_ROOT}/ShopRequest.xml") {|f| @contents = f.read }
    msg = @contents.to_s   
    cmd = SBroker.RequestRatingService("NB","ShopPackage",true,false,false)
    quote = cmd.call(msg)
    
    assert_equal 1,1
  end
  
  def xtest_get_section_quote_from_rte
    open("#{TD_ROOT}/sectionquoteMTinput.xml") {|f| @contents = f.read }
    msg = @contents.to_s   
    cmd = SBroker.RequestRatingService("NB","MotorTrade",false,true,false)
    premium = cmd.call(msg)
    assert_equal "28.8886",premium 
  end
  
  def xtest_mockedup_quote_engine
    open("#{TD_ROOT}/PLRoadRiskQuoteInput.xml") {|f| @contents = f.read }
    msg = @contents.to_s   
    cmd = SBroker.RequestRatingService("NB","RoadRisks",false,true,false)
    quote = cmd.call(msg)
    
    assert_equal 1,1
  end

  def test_dummy
    assert_equal 1,1
  end
end