# Copyright (c) 2007-2008 Orangery Technology Limited 
# You can redistribute it and/or modify it under the same terms as Ruby.
#
require 'models/persist'
require 'cgi'
require 'net/http' 

require 'servicebroker/broker'
require 'Marshaller'

require 'bizLogic/applymta'
require 'bizLogic/search'
require 'bizLogic/payment'
require 'bizLogic/diff'
require 'bizLogic/continualQNB'
require 'bizLogic/VPMSHelper'

require 'processengine/HashEnhancement'

require 'rexml/document'

require 'kerrylondon'

class PEngine
  include XMLDiff
  include Marshaller
  
  include ApplyMTA
  include Search
  include Payment
  include RefineQuote
  include VPMSHelper
  include REXML

  PRODUCTMODELS = Hash.new
  
  def deriveActiveRecordDefinitionOfProduct(product)
      if (PRODUCTMODELS.has_key?(product))
        return PRODUCTMODELS[product.to_sym]
      else
        return getRAILSClassRequiresForProductModelFromOilDef(product)
      end
  end

  def addDefaults(p1)
    #adds default values where no value currently exists
    #these values should be extracted from the data model!!
    p2 = {"ContentsCoverCoverDetailOtherContentsSumInsured" => {"Amount" => "1000000"},
        "ContentsCoverCoverDetailOtherStockSumInsured" => {"Amount" => "1000000"},
        "ContentsCoverCoverDetailTargetStockSumInsured" => {"Amount" => "1000000"},
        "BuildingsCoverCoverDetailShopFrontCoverDetailSumInsured" => {"Amount" => "1000000"},
        "BuildingsCoverCoverDetailTenantsImprovementsCoverDetailSumInsured" => {"Amount" => "1000000"},
        "BookDebtsCoverCoverDetailSumInsured" => {"Amount" => "1000000"},
        "BusinessInterruptionCoverCoverDetailSumInsured" => {"Amount" => "1000000"},
        "EmployersLiabilityCoverCoverDetailSumInsured" => {"Amount" => "1000000"},
        "GlassCoverCoverDetailSumInsured" => {"Amount" => "1000000"},
        "LossOfLicenceCoverCoverDetailSumInsured" => {"Amount" => "1000000"},
        "MoneyCoverCoverDetailSumInsured" => {"Amount" => "1000000"},
        "ProductLiabilityCoverCoverDetailSumInsured" => {"Amount" => "1000000"},
        "PublicLiabilityCoverCoverDetailSumInsured" => {"Amount" => "1000000"}}
      
    p2.each do |k,v|
      if p1.has_key?(k)
          v.each do |ik,iv|
            if (!p1[k].has_key?(ik) or p1[k][ik].length == 0)
              #puts "replacing value for:#{k},#{ik}"
              p1[k][ik] = iv
            end
          end
      else
        #puts "replacing value for:#{k}"
        p1[k] = v
      end
    end
    return p1
  end

  def drill(params,tweak)
    params.each do |p,v|
      if (v.class.to_s == "HashWithIndifferentAccess")
        drill(v,tweak)
      elsif Kerrylondon.mapping.has_key?(p)
        newkey = Kerrylondon.mapping[p]
        tweak[newkey] = v
      end
    end
  end

  def push(session,process,params)
    package = 'CommercialProperty'

    case process
    when "ProcessDefinition"
      require 'RailsProcessInterpreter'
      open("#{PRODUCT_ROOT.gsub(/%product/,session[:product])}/DSL/processes.oil") {|f| @contents = f.read }
      dsl = @contents.to_s
      action_methods = RailsProcessInterpreter.execute(dsl)
      action_methods

    when "GetNBQuote"
      eval(deriveActiveRecordDefinitionOfProduct(session[:product]))
      xml = createXMLMessage(session[:product],params,false) { |k,v| "<#{k}>#{v}</#{k}>" }
      persist = Persist.instance
      key = persist.put("UUID",xml)
      session[:policyKey] = key

      if APP_CONFIG['use_rating_engine']
        nvpxml = buildVPMSMessage(session[:product],package,session[:brand],params)
        response = callVPMS(nvpxml)
        parseVPMSresponse(response,session[:product])
        xml = mergeIntoXMLDoc(xml,@premiums)
      end
      prepareModels(session[:product],xml)
      #cmd = SBroker.RequestRatingService("NB",session[:product],true,false,false)
      #quote = cmd.call(xml)

    when "GetBrokerQuotes"
      eval(deriveActiveRecordDefinitionOfProduct(session[:product]))      
      dataTweak = Hash.new
      drill(params,dataTweak)
      #dataTweaks contains values that override the kerry london adapter defaults
      result = Kerrylondon.makeQuote("Tony Lorriman","liability1","CSP",false,Kerrylondon.keyfacts(dataTweak))
      premiums = "<ContractorPlant><Quotes>#{result}#{result}</Quotes></ContractorPlant>"
      prepareModels(session[:product],premiums)

    when "RefineNBQuote"
      eval(deriveActiveRecordDefinitionOfProduct(session[:product]))
      persist = Persist.instance
      origxml = persist.get(session[:policyKey])
      h = prepareModels(session[:product],origxml)
      params = h.deep_merge(params)
      combinedxml = createXMLMessage(session[:product],params,false) { |k,v| "<#{k}>#{v}</#{k}>" }
      key = persist.put(session[:policyKey],combinedxml)
     
      if APP_CONFIG['use_rating_engine']
        nvpxml = buildVPMSMessage(session[:product],package,session[:brand],params)
        response = callVPMS(nvpxml)
        parseVPMSresponse(response,session[:product])
        combinedxml = mergeIntoXMLDoc(combinedxml,@premiums)
      end
      
      prepareModels(session[:product],combinedxml)

    when "Search"
      executeSearch(session[:product],params)      

    when "FindPolicyOrQuote"
      persist = Persist.instance
      xml = persist.get(params[:choosen][:one])
      prepareModels(session[:product],xml)

    when "Authenticate"
      begin
        if params[:User] and params[:User][:User] and params[:User][:User].length > 0
          session[:user_email] = params[:User][:User]
        elsif params[:ProfilePersonalDetailsClientContact] and params[:ProfilePersonalDetailsClientContact][:Email]
          session[:user_email] = params[:ProfilePersonalDetailsClientContact][:Email]
        end

        eval(deriveActiveRecordDefinitionOfProduct(session[:product]))
        open("#{File.dirname(__FILE__)}/../bizLogic/xquery2") {|f| @query = f.read }
        persist = Persist.instance
        results = persist.find(@query.gsub('EMAIL',session[:user_email]))
        key = results[0]
        xml = persist.get(key)
        doc = Document.new(xml)
        node = doc.elements['Telenexus/Profile/PersonalDetails/Client']
        node.parent.delete(node) if node and session[:user_email].index("telenexus.com")
        prepareModels(session[:product],doc.to_s)
      rescue
        if !session[:user_email]
          raise "Credentials missing - you have not logged in"
        end
        raise "An error occurred during the authentication process"
      end

    when "SaveProfile"
      begin
        session[:user_email] = params[:ProfilePersonalDetailsClientContact][:Email]
        eval(deriveActiveRecordDefinitionOfProduct(session[:product]))
        xml = createXMLMessage(session[:product],params,false) { |k,v| "<#{k}>#{v}</#{k}>" }
        open("#{File.dirname(__FILE__)}/../bizLogic/xquery2") {|f| @query = f.read }
        persist = Persist.instance
        results = persist.find(@query.gsub('EMAIL',session[:user_email]))
        key = nil
        if !results
          key = persist.create_key_and_doc(xml)
        else
          key = results[0]
          persist.put(key,xml)
        end
        xml = persist.get(key)
        prepareModels(session[:product],xml)
      rescue
        if !session[:user_email]
          raise "Credentials missing for new customer"
        end
        raise "An error occurred whilst saving a new profile"
      end


    when "SectionRating"
      "1553.25"

    when "MTAReason"
      persist = Persist.instance
      xml = persist.get(session[:policyKey])
      prepareModels(session[:product],xml)      

    when "GetMTAQuote"
      persist = Persist.instance
      origImage = persist.get(session[:policyKey])
      #TODO: the origImage will need any MTAs layering on there
      xml = createXMLMessage(session[:product],params,false) { |k,v| "<#{k}>#{v}</#{k}>" }      
      applyMTA(session[:mtaStartDate],session[:mtaEndDate],session[:policyKey],origImage,xml)
      prepareModels(session[:product],xml)

    when "PolicyDocumentation"
       #get XML quote/policy document
      persist = Persist.instance
      xml = persist.get(session[:policyKey])
      #call the rating engine (again!) until we've preserved the quote
      cmd = SBroker.RequestRatingService("NB",session[:product],true,false,false)
      quote = cmd.call(xml)
      prepareModels(session[:product],xml)

    when "Checkout"
      next_url = setup_payment(params)
      next_url

    when "ConfirmPayment"
      get_gateway_payment_details(params)

    when "CompletedPayment"
      complete_payment(params)

    when "CaptureInputXML"
      eval(deriveActiveRecordDefinitionOfProduct(session[:product]))
      xml = createXMLMessage(session[:product],params,false) { |k,v| "<#{k}>#{v}</#{k}>" }
      File.open("dump.xml", 'w') {|f| f.write(xml) }


    else
      puts "**********> #{process} logic performed once it has been written <**********"
    end
  end
end
