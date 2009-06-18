# Copyright (c) 2007-2008 Orangery Technology Limited 
# You can redistribute it and/or modify it under the same terms as Ruby.
# 
module ApplyMTA  
    def applyMTA(startDateTime,endDateTime,policyKey,origImage,newImage)     
      appliedDateTime = Time.now.strftime('%Y-%m-%d') #TODO: add time into this
      appliedDateTimeEpoch = Time.now.to_i
      
      xmldiff = determineDiff(origImage,newImage)
    
      doc = REXML::Document.new xmldiff

      #remove the diff records of no interest to us
      doc.elements.delete_all('//xupdate:append')
      doc.elements.delete_all('//xupdate:remove')
      doc.elements.delete_all('//xupdate:insert-after')
      doc.elements.delete_all('//xupdate:insert-before')
      doc.elements.delete_all('//xupdate:rename')

      #the reduced doc
      #puts doc.to_s

      persist = Persist.instance
      #add the MTA diff doc to the data store
      key = persist.put('UUID',doc.to_s)
      #puts "MTA diff doc key is #{key}"

      #get the doc that holds the relationship between the policy and
      #any MTA diff docs
      #if it does not exist then get! will create it
      mtas = persist.get!("#{policyKey}MTAS","<MTAS></MTAS>")
      doc = REXML::Document.new mtas
      mtasNode = REXML::XPath.first(doc, '//MTAS')
      
      #check to see if any MTAs exist that start later than this one
      #if so mark them as rolled back and store them in a
      #reapply->hash
      reapply = []
      
      elems = doc.root.get_elements('//MTAS/MTA[@startDateTime]')
      sorted = elems.map { |s| s.attributes["startDateTime"].to_s}.sort
      #puts "This new MTA starting on #{startDateTime} yields out-of-sequence node(s):"
      count = 0
      sorted.each do |sd|
        if (sd > startDateTime)
          #roll these back
          xpath = '//MTAS/MTA[@startDateTime = '+'"'+sd+'"]'
          node = REXML::XPath.first(doc, xpath)
          #puts node
          #put into reapply-array providing of course not already rolled back
          rb = node.attributes["rolledBack"]
          if (rb != "true") then
            reapply[count] = node.deep_clone
            count = count + 1
            #set current node to rolledBack
            node.attributes["rolledBack"] = true
          end
        end
      end
      #puts "No nodes qualified." unless count > 0
      #puts "\n"

      #get first node and add element with meta data relating to the MTA diff doc added above
      #meta data includes the key of the diff doc
      mtasNode.add_element('MTA',{'key' => key , 'appliedDateTimeEpoch' => appliedDateTimeEpoch, 'appliedDateTime' => appliedDateTime, 'startDateTime' => startDateTime, 'endDateTime' => endDateTime, 'rolledBack' => false})

      #check the reapply->array
      #create new entries for any in the reapply->hash with new appliedDateTime attribute values      appliedDateTime = Time.now.strftime('%Y-%m-%d') #TODO: add time into this
      reapply.each do |n|
        appliedDateTimeEpoch = appliedDateTimeEpoch + 1
        n.attributes["appliedDateTime"] = appliedDateTime
        n.attributes["appliedDateTimeEpoch"] = appliedDateTimeEpoch
        n.attributes["rolledBack"] = false
        mtasNode.add_element(n)
      end
      #puts "Final state of MTA meta data doc:"+doc.to_s

      mtaKey = persist.put("#{policyKey}MTAS",doc.to_s)
      #puts "MTAS key is still:#{mtaKey}"
      doc.to_s
    end
end
