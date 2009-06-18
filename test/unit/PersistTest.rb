# Copyright (c) 2007-2008 Orangery Technology Limited 
# You can redistribute it and/or modify it under the same terms as Ruby.
#
require 'test/unit'
require File.join(File.dirname(__FILE__),'..','..','lib','models','persist')

class PersistTest < Test::Unit::TestCase
  TD_ROOT = File.join(File.dirname(__FILE__), 'testdata')
  
  def test_singleton
    persist = Persist.instance
    persist2 = Persist.instance
    assert_equal(persist,persist2)
  end
  
  def test_put_get
    persist = Persist.instance
    
    open("#{TD_ROOT}/shopquote1.xml") {|f| @contents = f.read } if @contents == nil
    msg = @contents.to_s
  
    1.times do
      key = persist.create_key_and_doc(msg)
      msg2 = persist.get(key)
      assert_equal(msg,msg2)
    end
  end
  
  def test_xquery
    persist = Persist.instance
    open("#{TD_ROOT}/shopquery1") {|f| @contents = f.read }
    result = persist.find(@contents)
    puts result
  end
end
