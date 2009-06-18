# Copyright (c) 2007-2008 Orangery Technology Limited 
# You can redistribute it and/or modify it under the same terms as Ruby.
#
require 'test/unit'
require 'net/http'
require 'soap/wsdlDriver'

class VPMSCallTest < Test::Unit::TestCase  
  TD_ROOT = File.join(File.dirname(__FILE__), 'testdata')
  #this test represents a usage of the VPMS interface that will not semantically work
  #and so we will not be following this pattern
  #instead we use the pattern highlighted by the test below
  def xtest_get_test_quote
    wsdl = 'http://20.42.4.126:8080/jvpms/services/ProductRequestProcessor?wsdl'
    factory = SOAP::WSDLDriverFactory.new(wsdl)
    driver = factory.create_rpc_driver
    #driver.wiredump_file_base = "vpmscall-soap-trace"
    actions = [:name => "P_Premium"]
    response = driver.process([:productName => "travel"])
    #response = driver.process([:ProductRequest => [:productName => "travel"]])
    puts "#{response}"
    #

    assert_equal 1,1
  end
  
  def test_get_test_quote
    open("#{TD_ROOT}/commercialproperty3.xml") {|f| @contents = f.read }
    msg = @contents.to_s
    headers = {
              'Content-Type' => 'text/xml',
              'SoapAction' => ""
              }
    if APP_CONFIG['use_rating_engine']
      puts "sending:\n#{msg}"
      Net::HTTP.start(APP_CONFIG['vpms_ip'], 8080) do |http|
          response = http.post('/jvpms/services/ProductRequestProcessor',msg,headers)
          puts response
      end
    end

    assert_equal 1,1
  end
end