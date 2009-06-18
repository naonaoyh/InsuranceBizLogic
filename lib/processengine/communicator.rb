# Copyright (c) 2007-2008 Orangery Technology Limited 
# You can redistribute it and/or modify it under the same terms as Ruby.
#
require 'processengine/engine'

class Communicator
  
  @@instance = Communicator.new
  
  def self.instance
    @@instance
  end
  
  def handle(session,process,params)
    eng = PEngine.new
    eng.push(session,process,params)
  end
end