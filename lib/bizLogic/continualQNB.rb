module RefineQuote
  def integrateData(session,origData,newData)
    #this piece of logica takes two xml documents that need to be merge, there will be new nodes
    #and overlapping nodes as question answers for the quote are made available
    result = origData.gsub("</#{session[:product]}>","")+newData.gsub("<#{session[:product]}>","")
    result
  end
end