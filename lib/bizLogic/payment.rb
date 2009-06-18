# Copyright (c) 2007-2008 Orangery Technology Limited 
# You can redistribute it and/or modify it under the same terms as Ruby.
#
# See doc/paypal_developer_info.txt
# See www.codyfauser.com

require 'active_merchant'

module Payment
    
  include ActiveMerchant::Billing
  
  # returns a url
  def setup_payment(params)
    amount = params[:payment_amount].to_i
    if amount < 1
      return params[:cancel_return_url]
    else
      setup_response = payment_gateway.setup_purchase(amount, :ip => params[:ip], :return_url => params[:return_url], :cancel_return_url => params[:cancel_return_url])
      return payment_gateway.redirect_url_for(setup_response.token)
    end
  end
  
  # returns a PaymentDetails
  def get_gateway_payment_details(params)
    details_response = payment_gateway.details_for(params[:token])
    return PaymentDetails.new(details_response.success?, details_response.message, details_response.address)
  end
  
  class PaymentDetails
    attr_reader :error_message, :address
    def initialize(success, error_message, address)
      @success = success
      @error_message = error_message
      @address = address
    end
    def success?
      @success
    end
  end
  
  # returns a PurchaseDetails
  def complete_payment(params)
    amount = params[:payment_amount].to_i
    if amount < 1
      #TODO localise error message
      return PurchaseDetails.new(false, "Amount to pay must be greater than 0")
    else
      purchase = payment_gateway.purchase(amount, :ip => params[:ip], :payer_id => params[:payer_id], :token => params[:token])
      return PurchaseDetails.new(purchase.success?, purchase.message)
    end
  end
  
  class PurchaseDetails
    attr_reader :error_message
    def initialize(success, error_message)
      @success = success
      @error_message = error_message
    end
    def success?
      @success
    end
  end
  
  #  private
  # TODO this is the test paypal account, needs to come from configuration
  def payment_gateway
    @payment_gateway ||= @@gateway_creator.call
  end
  
  def self.gateway_creator=(creator)
    @@gateway_creator = creator
  end

end


#TODO THIS BELONGS IN A CONFIGURATION INCLUDE SOMEWHERE (which is why it looks funny here)

# Put ActiveMerchant in test mode
ActiveMerchant::Billing::Base.mode = :test

# Use the ActiveMerchant Paypal Express gateway with these sandbox account details
Payment.gateway_creator = lambda { ActiveMerchant::Billing::PaypalExpressGateway.new(
    :login => 'kuboid_1208170947_biz_api1.gmail.com',
    :password => '1208170953',
    :signature => 'AMVR2Do.R-utyMm2sFyqPkqVzWDzAn4yKS9xT07kyzoyj5DFPG-wh53q'
  ) }
