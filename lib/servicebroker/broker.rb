# Copyright (c) 2007-2008 Orangery Technology Limited
# You can redistribute it and/or modify it under the same terms as Ruby.
#
require 'net/http'
require 'RatingEngineResolver'

class SBroker
  SERVICE_BROKER_ROOT = File.dirname(__FILE__)
  XSL_ROOT = File.join(SERVICE_BROKER_ROOT, 'xsl')
  MOCK_ROOT = File.join(SERVICE_BROKER_ROOT, 'mocks')
  
  def self.RequestRatingService(process,product,full,partial,knockout)
    open("#{PRODUCTS_ROOT}/#{product}/dsl.rb") {|f| @contents = f.read }
    script = @contents.to_s
    mycmd = RatingEngineResolver.execute(script)
    cmd = eval(mycmd)
    cmd
  end
  
  def self.InvokeRTE(msg)
      Net::HTTP.start(APP_CONFIG['rte_restful_ip'], 80) do |http|
        response = http.post('/RestfulXRTE.ashx/quote',msg)
        response.body
      end    
  end
  
  def self.ApplyTransform(xml,transform,code)
      require 'xml/xslt'
      
      xslt = XML::XSLT.new()
      xslt.xml = xml
      xslt.xsl = File.join(XSL_ROOT, transform)
      if (code != nil) then
        xslt.parameters = { "code" => "#{code}" }
      end
      transformed_xml = xslt.serve()
      transformed_xml
  end
  
  def self.ExtractSectionPremium(xml,response_xml)
    begin
      #expects a standard format message with a code value in
      #will be ok since all the schemas are derived from the
      #formal polaris library
      transformed_xml = SBroker.ApplyTransform(xml,"extractCode.xsl",nil)
      if (transformed_xml == nil)
          transformed_xml = SBroker.ApplyTransform(xml,"extractDescription.xsl",nil)
      end
      msg = transformed_xml.strip
      vals = msg.split('>')
      #get some odd initial character here...quick hack to remove it
      #need to figure out what it is
      code = vals[1][1,vals[1].length]

      #now extract the premium from the response
      #this approach is taken so that the xslt can hide the nasties of a none XML dictionary
      #TODO: provide a XSLT conversation on the way back from thre RTE
      transformed_xml = SBroker.ApplyTransform(response_xml,"extractPremium.xsl",code)
      msg = transformed_xml.strip

      vals = msg.split('>')
      #get some odd initial character here...quick hack to remove it
      #need to figure out what it is
      premium = vals[1][1,vals[1].length]
    rescue Exception => e
      puts "THE SECTION PREMIUM ERROR'ED WITH:#{e.message}"
    end      
  end
  
  def self.GetMockRatingResponse(mockFile)
    quote = open("#{MOCK_ROOT}/" + mockFile) {|f| f.read }
    quote.to_s  
  end
end
