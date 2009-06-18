module BDBXMLJE
  include Java 
  require 'date'
  require 'pathname'
  require 'lib/db.jar'
  require 'lib/dbxml.jar'

  # Include all the Java and JE classes that we need. 

  include_class 'java.io.File' do |p, c|
    "J#{c}"
  end

  include_class ['com.sleepycat.db.Environment','com.sleepycat.db.EnvironmentConfig'] do |p, c|
    "J#{c}"
  end
  include_class 'com.sleepycat.db.Cursor'
  include_class 'com.sleepycat.db.Database'
  include_class 'com.sleepycat.db.DatabaseConfig'
  include_class 'com.sleepycat.db.DatabaseType'
  include_class 'com.sleepycat.db.DatabaseEntry'
  include_class 'com.sleepycat.db.OperationStatus'
  include_class 'com.sleepycat.db.Transaction'
  
  include_class 'com.sleepycat.bind.tuple.IntegerBinding'
  include_class 'com.sleepycat.bind.tuple.StringBinding'
  
  include_class 'com.sleepycat.dbxml.XmlManager'
  include_class 'com.sleepycat.dbxml.XmlManagerConfig'
  include_class 'com.sleepycat.dbxml.XmlDocument'
  include_class 'com.sleepycat.dbxml.XmlTransaction'
  
  #setup DB_ROOT to point to IABDB location
  unless defined?(DB_ROOT)
    db_path = APP_CONFIG['dbpath']
    db_path = Pathname.new(db_path).cleanpath(true).to_s
    DB_ROOT = db_path
    DB_NAME = APP_CONFIG['dbcontainer']
  end
  
  def setup_env
    #setup UUID state file
    UUID.config(:state_file => "#{DB_ROOT}/uuid.state",
                  :sequence => rand(0x100000000),
                  :mac_addr => '00:19:e3:36:60:f5')

    begin
      envConf = JEnvironmentConfig.new()
      envConf.setAllowCreate(true)
      envConf.setTransactional(true)
      envConf.setInitializeCache(true);      

      f = JFile.new(DB_ROOT)
      $env = JEnvironment.new(f, envConf);
      
      manConf = XmlManagerConfig.new()
      manConf.setAllowExternalAccess(true)
      $man = XmlManager.new($env,manConf)
      
      if (!File.exist?("#{DB_ROOT}/#{DB_NAME}"))
        $con = $man.createContainer(DB_NAME)
      else
        $con = $man.openContainer(DB_NAME)
      end
      
      $base = "."
    rescue NativeException => e
      puts "Native exception's cause: #{e.cause}"
      raise
    end
  end

  def create_key_and_doc(msg)
    key = UUID.new
    create_doc(msg,key)
    key
  end
  
  def read_doc(key)
    $con.getDocument(key).getContentAsString() 
  end
  
  def create_doc(msg,key)
    #removed the transaction bit since causes error when running inside Tomcat under JRuby
    #txn = $man.createTransaction()
    a = $man.createDocument()
    a.setContent(msg)
    a.setName(key)
    $con.putDocument(key,msg)
    #$con.putDocument(txn,key,msg)
    #txn.commit()
  end
  
  def replace_doc(msg,key)
    #removed the transaction bit since causes error when running inside Tomcat under JRuby
    #txn = $man.createTransaction()
    #a = $con.getDocument(txn,key)
    a = $con.getDocument(key)
    a.setContent(msg)
    #$con.updateDocument(txn,a)
    $con.updateDocument(a)
    #txn.commit
  end
  
  def find(query)
    cxt = $man.createQueryContext()
    results = $man.query(query, cxt)
    if (results.size() == 0) then
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
    while results.hasNext()
      if rows[i] == nil
        rows[i] = ""
      end
      r = results.next().asString()
      rows[i] << r.chomp
      if (r.match(']}'))
        i = i + 1
      end 
    end   
    rows
  end
end