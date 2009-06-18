# Copyright (c) 2007-2008 Orangery Technology Limited 
# You can redistribute it and/or modify it under the same terms as Ruby.
#

module XMLDiff
  def runCommand(cmd, inp='')
    IO.popen(cmd, 'r+') do |io|
      begin
        io.write inp
        io.close_write
        return io.read
      rescue Exception => e
        e.message
      end
    end
  end
  
  def determineDiff(origImage,newImage)
    before, after, result = nil, nil, nil
    begin      
      before = Tempfile.new('iab')
      before << origImage
      before.close
      after = Tempfile.new('iab')
      after << newImage
      after.close
      result = Tempfile.new('iab')
      cmd = "#{APP_CONFIG['python_xmldiff_path']} -x #{before.path} #{after.path} > #{result.path}"
      runCommand(cmd)
      xmlDiff = result.read
      #identify only the update nodes - we do not need to know about nodes that have moved sequence
      return xmlDiff
    ensure
      before.delete unless before == nil
      after.delete unless after == nil
      result.delete unless result == nil
    end    
  end
end