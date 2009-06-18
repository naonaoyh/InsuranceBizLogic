require 'bdbxml'
module BDBXML
  #setup DB_ROOT to point to IABDB location
  unless defined?(DB_ROOT)
    db_path = APP_CONFIG['dbpath']
    require 'pathname'
    db_path = Pathname.new(db_path).cleanpath(true).to_s
    DB_ROOT = db_path
    DB_NAME = APP_CONFIG['dbcontainer']
  end
  
  def setup_env
    puts "VERSION of BDB is #{BDB::VERSION}\n"
    puts "VERSION of BDB::XML is #{BDB::XML::VERSION}\n"
    puts "Database path is #{File.expand_path(DB_ROOT)}\n"
    
    #setup UUID state file
    UUID.config(:state_file => "#{DB_ROOT}/uuid.state",
                  :sequence => rand(0x100000000),
                  :mac_addr => '00:19:e3:36:60:f5')
                
    @flag = BDB::INIT_TRANSACTION
    @flag ||= BDB::INIT_LOMP
    $env = BDB::Env.new(DB_ROOT, BDB::CREATE | @flag)
    $man = $env.manager
    if (!File.exist?("#{DB_ROOT}/#{DB_NAME}"))
      if (@flag & BDB::INIT_TXN) != 0
         $con = $man.create_container(DB_NAME, BDB::XML::TRANSACTIONAL)
      else
         $con = $man.create_container(DB_NAME)
      end
    else
      if (@flag & BDB::INIT_TXN) != 0
         $con = $man.open_container(DB_NAME, BDB::XML::TRANSACTIONAL)
      else
         $con = $man.open_container(DB_NAME)
      end
    end
    $base = "."
  end
  
  def clean_env
    puts "\nVERSION of BDB is #{BDB::VERSION}\n"
    puts "\nVERSION of BDB::XML is #{BDB::XML::VERSION}\n"
    puts "Cleaning #{DB_ROOT}/#{DB_NAME}\n"
    
    Dir.foreach(DB_ROOT) do |x|
      if FileTest.file?(DB_ROOT+"/#{x}")
         File.unlink(DB_ROOT+"/#{x}")
      end
    end
  end
  
  def close_env
    $man.close
    $env.close
  end
  
  def create_key_and_doc(msg)
    key = UUID.new
    create_doc(msg,key)
    key
  end
  
  def read_doc(key)
    $con.get(key).content
  end
  
  def create_doc(msg,key)
    $man.begin($con) do |txn, con|
      a = $man.create_document
      a.content = msg
      con[key] = a
      txn.commit
    end
  end
  
  def replace_doc(msg,key)
    $man.begin($con) do |txn, con|
      a = $con.get(key)
      a.content = msg
      $con.update(a)
      txn.commit
    end
  end
  
  def find(query)
    cxt = $man.create_query_context()
    results = $man.query(query, cxt)
    if (results.size == 0) then
      return nil
    end
    #results is essentially an array of result lines
    #a single result will span a number of output lines, e.g. outer joined
    #MTA info will appear with a CRLF separator
    #the following code makes up single logical result rows based on the lines between
    #successive pairs of {} braces
    #
    #it should be noted that the result set from the xqueries is intended to be
    #a valid ruby block
    #this allows the result to be used to instantiate an active record object
    #with no further manipulation required
    rows = []
    i = 0
    results.each do |r|
      if rows[i] == nil
        rows[i] = ""
      end
      rows[i] << r.chomp
      if (r.match(']}'))
        i = i + 1
      end
    end
    rows
  end
end