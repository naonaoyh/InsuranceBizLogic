# Copyright (c) 2007-2008 Orangery Technology Limited 
# You can redistribute it and/or modify it under the same terms as Ruby.
# 
module VPMSHelper
  include REXML

  def mergeIntoXMLDoc(xml,premiums)
    doc = Document.new(xml)
    #premiums is a named value pair array
    premiums.each do |singleResult|
      value = singleResult.pop
      path = Array.new
      insertionNode = nil
      found_where_to_insert = false
      singleResult.each do |a|
          path.push("/#{a}")
          nodes = XPath.match(doc,"/#{path}")
          if (a != singleResult.last)
            if nodes.length <= 0
              path.pop
              insertionNode = XPath.first(doc,"/#{path}")
              insertionNode.insert_after insertionNode,Element.new(a)
              path.push("/#{a}")
              insertionNode = XPath.first(doc,"/#{path}")
            elsif (nodes.length == 1)
              insertionNode = nodes[0]
            end
          else
            if nodes.length > 0
              #leaf node already there and maybe with an old value from previous page
            else
              path.pop
              e = Element.new(a)
              e.text = value
              insertionNode.insert_after insertionNode,e
            end
          end
        end
      end
    doc.to_s
  end

  def parseVPMSresponse(response,product)
    @premiums = Array.new
    doc = Document.new(response)
    nodes = XPath.match(doc,"//multiRef[returnCode=0]")
    nodes.each do |node|
      extractPremiums(node,product)
    end
    #display any VPMS issues
    #probably won't result in runtime issue since IAB currently asks for more than VPMS will understand
    #because VPMS schema built on product view of library and VPMS message is built from full library def of coverage
    #at the mo
    nodes = XPath.match(doc,"//multiRef[returnCode!=0]")
    nodes.each do |node|
      viewPremiumComputeErrors(node,product)
    end
  end
  
  def viewPremiumComputeErrors(node,product) #:nodoc
    value = ""
    node.each_child do |child|
      case child.node_type
      when :element
        key, value = child.expanded_name, extractPremiums(child,product)
        #put out 'error' message text
        puts "#{value}" if key == "message"
      when :text
        key, value = '$', unescape(child.to_s).strip
      end
    end
    value
 end  
  
  def extractPremiums(node,product) #:nodoc
    #vpms will return the following nodes of interest
    #message, name, reffield, returncode, value
    #like this
    #key=message,value=
    #key=name,value=F_CommercialProperty_#{product}_ContentsCover_CoverDetail_PremiumQuoteBreakdown_GrossAmount
    #key=refField,value=
    #key=returnCode,value=0
    #key=value,value=125.55
    value = ""
    node.each_child do |child|
      case child.node_type
      when :element
        key, value = child.expanded_name, extractPremiums(child,product)
        @premiums.push(value.gsub("F_CommercialProperty_","").gsub('CommercialProperty',product).split("_")) if (key == "name") 
        if (key == "value")
           name = @premiums.pop
           name.push(value)
           @premiums.push(name)
        end
      when :text
        key, value = '$', unescape(child.to_s).strip
      end
    end
    value
 end  
  
  def callVPMS(nvpxml)
      headers = {
              'Content-Type' => 'text/xml',
              'SoapAction' => ""
              }
      Net::HTTP.start(APP_CONFIG['vpms_ip'], 8080) do |http|
          response = http.post('/jvpms/services/ProductRequestProcessor',nvpxml,headers)
          response.body
      end
  end
  
  def buildVPMSMessage(product,package,brand,params)
      @instructionBlock = ""
      
nvpxml = '<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/"
    xmlns:tns="http://com/csc/dip/webservice/core/"
    xmlns:types="http://com/csc/dip/webservice/core/encodedTypes"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:q1="http://core.webservice.dip.csc.com">
    <soap:Body soap:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
        <tns:process>
            <in0 href="#id1"/>
        </tns:process>
        <soapenc:Array id="id1" soapenc:arrayType="q1:ProductRequest[1]">
            <Item href="#id3"/>
        </soapenc:Array>
        <q1:ProductRequest id="id3" xsi:type="q1:ProductRequest">
            <productName xsi:type="xsd:string">CommercialPropertyProduct</productName>
            <store xsi:type="xsd:boolean">false</store>
            <traceMode xsi:type="xsd:boolean">false</traceMode>
            <useUI xsi:type="xsd:boolean">false</useUI>
            <actions href="#id5"/>
        </q1:ProductRequest>'

      @id=7
      @instructionBlock << "<Item href=\"#id#{@id += 1}\"/>"        
      nvpxml  << "<q1:SetAction id=\"id#{@id}\" xsi:type=\"q1:SetAction\">
            <useUI xsi:type=\"xsd:boolean\">false</useUI>
            <name xsi:type=\"xsd:string\">A_CommercialProperty_#{package}_Brand</name>
            <value xsi:type=\"xsd:string\">#{brand}</value>
        </q1:SetAction>"
      @instructionBlock << "<Item href=\"#id#{@id += 1}\"/>"        
      nvpxml  << "<q1:SetAction id=\"id#{@id}\" xsi:type=\"q1:SetAction\">
            <useUI xsi:type=\"xsd:boolean\">false</useUI>
            <name xsi:type=\"xsd:string\">A_CommercialProperty_#{package}_Package</name>
            <value xsi:type=\"xsd:string\">#{product}</value>
        </q1:SetAction>"   
    
    
      nvpxml << createXMLMessage(product,params,true) do |k,v|
        
        @instructionBlock << "<Item href=\"#id#{@id += 1}\"/>"

         "<q1:SetAction id=\"id#{@id}\" xsi:type=\"q1:SetAction\">
            <useUI xsi:type=\"xsd:boolean\">false</useUI>
            <name xsi:type=\"xsd:string\">A_CommercialProperty_#{package}_#{k}</name>
            <value xsi:type=\"xsd:string\">#{v}</value>
        </q1:SetAction>"
      end

      nvpxml << deriveComputes(package)
      @instructionBlock << "<Item href=\"#id#{@id}\"/>"

      nvpxml << "<soapenc:Array id=\"id5\" soapenc:arrayType=\"q1:VpmsAction[1]\">
              #{@instructionBlock}
             </soapenc:Array>"

      nvpxml << "</soap:Body></soap:Envelope>"
      nvpxml
  end
  
  def deriveComputes(package)
    nvpxml = ""
    @pqbNodes.each do |n|
      nvpxml << "<q1:ComputeAction id=\"id#{@id += 1}\" xsi:type=\"q1:ComputeAction\">
            <useUI xsi:type=\"xsd:boolean\">false</useUI>
            <name xsi:type=\"xsd:string\">F_CommercialProperty_#{package}_#{n}</name>
        </q1:ComputeAction>"
      @instructionBlock << "<Item href=\"#id#{@id}\"/>"
    end
    nvpxml
  end
end