require 'test/unit'

require 'rubygems'
require 'openwfe/engine/engine'
require 'openwfe/expressions/raw'

class QNBFlow < OpenWFE::ProcessDefinition
  def make
    process_definition :name => "quote_lookup", :revision => "0.1" do
      sequence do
            participant :quote
      end
    end
  end
end

class RuoteTest < Test::Unit::TestCase
  def test_engine_run
    launchitem = OpenWFE::LaunchItem.new(QNBFlow)
    engine = OpenWFE::Engine.new(:definition_in_launchitem_allowed => true)
    engine.register_participant(:quote) do
            puts "this is where my ruby block would go"
    end
    engine.launch(launchitem)
    assert_equal 1,1
  end  
end
