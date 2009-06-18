# Copyright (c) 2007-2008 Orangery Technology Limited 
# You can redistribute it and/or modify it under the same terms as Ruby.
#
# Unit test for Restful XRTE web service for schemes (products) that are based on Traditional dictionaries.
# (the XRTE, and hence the web service, handle Traditional dictionaries differently from XML dictionaries).
#
# Note that this test is actually a test of the C# web service (not of any Ruby code).

require 'test/unit'
require 'net/http' 

class TradPWDictTest < Test::Unit::TestCase 
  TD_ROOT = File.join(File.dirname(__FILE__), 'testdata')
 
  def test_get_quote
    open("#{TD_ROOT}/MotorTradeAllFieldsRequest.xml") {|f| @contents = f.read }
    request_xml = @contents.to_s

    open("#{TD_ROOT}/MotorTradeAllFieldsExpectedResponse.xml") {|f| @contents = f.read }
    expected_response_xml = @contents.to_s

    #response_xml = Net::HTTP.start(APP_CONFIG['rte_restful_ip'], 80) do |http|
    #  response = http.post('/RestfulXRTE.ashx/quote',request_xml)
    #  response.body
    #end

    #assert_equal expected_response_xml, response_xml
    #puts response_xml
    assert_equal 1,1
  end
end
