# Copyright (c) 2007-2008 Orangery Technology Limited 
# You can redistribute it and/or modify it under the same terms as Ruby.
#
module Search
  def executeSearch(product,params)
    
    mypredicate = ""
    params.each do |k,v|
      if (v.class.name == 'HashWithIndifferentAccess')
        mypredicate << explodeHash(v)
      end
    end

    open("#{File.dirname(__FILE__)}/xquery1") {|f| @query = f.read }
    @query = @query.gsub("PRODUCT","#{product}").gsub("PREDICATE",mypredicate[0..-5])
    
    persist = Persist.instance
    result = persist.find(@query)
  end
  
  def explodeHash(h)
    predicate = ""
    h.each do |k,v|
      if (v.class.name == 'HashWithIndifferentAccess')
        predicate << explodeHash(v)
      elsif (v.class.name == "String")
        if (v.length > 0)
          predicate << "$result//#{k} =\"#{v}\" and "
        end
      end
    end
    predicate
  end
end