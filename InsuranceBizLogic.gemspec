# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{InsuranceBizLogic}
  s.version = "0.1.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Gary Mawdsley"]
  s.date = %q{2009-03-31}
  s.description = %q{InsuranceBizLogic contains biz logic for stand four insurance processes of NB, MTA, Cancellations, Renewals}
  s.email = %q{garymawdsley@gmail.com}
  s.files = ["lib/bizLogic", "lib/bizLogic/search.rb", "lib/bizLogic/continualQNB.rb", "lib/bizLogic/VPMSHelper.rb", "lib/bizLogic/xquery1","lib/bizLogic/xquery2", "lib/bizLogic/applymta.rb", "lib/bizLogic/payment.rb", "lib/bizLogic/diff.rb", "lib/servicebroker", "lib/servicebroker/mocks", "lib/servicebroker/mocks/RoadRisksQuoteNBRs.xml", "lib/servicebroker/mocks/CommercialCombinedQuoteNBRs.xml", "lib/servicebroker/broker.rb", "lib/servicebroker/xsl", "lib/servicebroker/xsl/in_MotorTrade.xsl", "lib/servicebroker/xsl/extractPremium.xsl", "lib/servicebroker/xsl/extractDescription.xsl", "lib/servicebroker/xsl/extractCode.xsl", "lib/processengine", "lib/processengine/HashEnhancement.rb", "lib/processengine/engine.rb", "lib/processengine/communicator.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/iab/InsuranceBizLogic}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{InsuranceBizLogic}
  s.rubygems_version = %q{1.3.4}
  s.summary = %q{InsuranceBizLogic contains biz logic for stand four insurance processes of NB, MTA, Cancellations, Renewals}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<mime-types>, [">= 1.15"])
      s.add_runtime_dependency(%q<diff-lcs>, [">= 1.1.2"])
    else
      s.add_dependency(%q<mime-types>, [">= 1.15"])
      s.add_dependency(%q<diff-lcs>, [">= 1.1.2"])
    end
  else
    s.add_dependency(%q<mime-types>, [">= 1.15"])
    s.add_dependency(%q<diff-lcs>, [">= 1.1.2"])
  end
end
