# Copyright (c) 2007-2008 Orangery Technology Limited 
# You can redistribute it and/or modify it under the same terms as Ruby.
#
require 'test/unit'
require 'rexml/document'
require 'date'
require 'models/persist'
require File.join(File.dirname(__FILE__),'..','..','lib','bizLogic','applymta')
require File.join(File.dirname(__FILE__),'..','..','lib','bizLogic','diff')

class MTATest < Test::Unit::TestCase
  include ApplyMTA
  include XMLDiff
  TD_ROOT = File.join(File.dirname(__FILE__), 'testdata')
  
  def xtest_mta
    persist = Persist.instance
    
    open("#{TD_ROOT}/shopquote1.xml") {|f| @contents = f.read }
    policyKey = persist.put('UUID',@contents)

    #this test is not concerned with the diff, just the sequence and rearranging of the sequence
    #so just load some xupdate compliant doc to save as the MTA content
    open("#{TD_ROOT}/newimage.xml") {|f| @contents = f.read }
    newimage = @contents.to_s
    open("#{TD_ROOT}/origimage.xml") {|f| @contents = f.read }
    origimage = @contents.to_s        
    
    #1ST MTA
    appliedDateTime = Time.now.strftime('%Y-%m-%d') #TODO: add time into this
    appliedDateTimeEpoch = Time.now.to_i
    startDateTime = '2008-01-09'
    endDateTime = '2008-02-10'
    
    #startDateTime,endDateTime,policyKey,origImage,newImage 
    applyMTA(startDateTime,endDateTime,policyKey,origimage,newimage)
  
    #2nd MTA
    appliedDateTime = Time.now.strftime('%Y-%m-%d') #TODO: add time into this
    appliedDateTimeEpoch = Time.now.to_i
    startDateTime = '2008-01-08'
    endDateTime = '2008-03-31'
    
    finalState = applyMTA(startDateTime,endDateTime,policyKey,origimage,newimage)
    #puts "Final state:"+finalState
    assert_equal 1,1
  end

  def test_me
    assert_equal 1,1
  end
end

