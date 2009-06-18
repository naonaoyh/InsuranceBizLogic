# Copyright (c) 2007-2008 Orangery Technology Limited 
# You can redistribute it and/or modify it under the same terms as Ruby.
#
$:.unshift(File.dirname(__FILE__))
require 'rubygems'
require 'uuid'
require 'rexml/document'
require 'singleton'
require 'modbdbxml' unless defined?(JRUBY_VERSION)
require 'modbdbxmlje' if defined?(JRUBY_VERSION)

class Persist
  include BDBXML unless defined?(JRUBY_VERSION)
  include BDBXMLJE if defined?(JRUBY_VERSION)

  include Singleton
  
  def initialize
    setup_env
  end
  
  def put(key,request)
    begin
      if (key == 'UUID') then
        key = UUID.new
        create_doc(request,key)
      else
        replace_doc(request,key)
      end
      key
    end
  end
  
  def get(key)
    read_doc(key)
  end
  
  #get with the insistence the document will be there
  #if not then create it
  def get!(key,request)
    result=""
    begin
      result = read_doc(key)
    rescue Exception => e #document not found
      create_doc(request,key)
      result = read_doc(key)
    end
    return result
  end
end
