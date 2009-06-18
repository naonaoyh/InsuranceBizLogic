<?xml version="1.0" encoding="UTF-8"?>
<!-- XSLT for Allianz Motor Trade XRTE requests -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">
    <!-- Specify the output encoding as UTF-8.  This causes the output
         document to have encoding="UTF-8" in the ?xml? declaration at the
         top, which makes the XRTE *output* in UTF-8 as well. -->
    <xsl:output method="xml" omit-xml-declaration="yes" encoding="UTF-8" />
    
    <!-- FJDTODO there is nowhere in the UI for the discount percentages to
         be input at the moment.  Need to add them into the UI and then set
         them to the values input here -->
    <xsl:variable name="discountMD" select="0"/>
    <xsl:variable name="discountEL" select="0"/>
    <xsl:variable name="discountPL" select="0"/>
    <xsl:variable name="discountBI" select="0"/>
    <xsl:variable name="discountPA" select="0"/>
    <xsl:variable name="discountWC" select="0"/>

    <xsl:key name="personalAccident" match="/MotorTradeQuoteNBRq/PersonalAccidentCover/CoverDetail[GroupDetail/NoOfEmployees > 0]" use="GroupDetail/EmploymentTypeCode/Value"/>
    <xsl:key name="employersLiability" match="/MotorTradeQuoteNBRq/EmployersLiabilityCover/CoverDetail[Employee/Wages > 0]" use="Employee/EmploymentTypeCode/Value"/>

    <xsl:template match="/MotorTradeQuoteNBRq">
                <RiskEvent>
                    <RiskEvent_TransactionType Val="B901 840" />
                    <RiskEvent_SchemeRef Val="50208104009" />
                    <RiskEvent_BrokerGroup Val="2" />
                    <RiskEvent_BrokeragePct Val="0" />
                </RiskEvent>
                <Trade>
                    <Trade_Code Val="B566 J65" />
                </Trade>

                <Cover>
                    <Cover_CommissionStandardForCoverByBroker Val="0"/>
                    <Cover_SiAmt Val="3000000"/>
                    <Cover_Code Val="B205 L14"/>
                </Cover>

                <!-- Apply templates that output Cover elements -->
                <Cover>
                    <Cover_SiAmt Val="5000000"/><!-- TODO take this from "Limit of Indemnity" field when that field is created in IAB UI -->
                    <Cover_Code Val="B205 L20"/>
                    <Cover_CommissionStandardForCoverByBroker Val="{$discountPL}"/>
                    <xsl:apply-templates select="ProductLiabilityCover/CoverDetail/TurnoverBreakdown[TurnoverAmount > 0]" />
                </Cover>
                <xsl:apply-templates select="BusinessInterruptionCover[CoverDetail/SumInsured/Amount > 0]" />

                <!-- Apply template that outputs InsuranceCover elements -->
                <xsl:apply-templates select="RoadRisksCover/VehicleCover/NCDDetail[NCDYears > 0]" />

                <!-- Apply template that outputs Premises elements -->
                <xsl:apply-templates select="Location" />


                <!-- Personal Accident -->
                <!-- PA: Directors Partners and Principles -->
                <xsl:if test="key('personalAccident', 'B515 186')">
                    <Cover>
                        <Cover_CommissionStandardForCoverByBroker Val="{$discountPA}"/>
                        <Cover_Code Val="B205 P03"/>
                        <xsl:if test="key('personalAccident', 'B515 186')/BasisCode/Value = 'B506 100'">
                            <Cover_BasisCode Val="B506 100"/>
                        </xsl:if>
                    </Cover>
                </xsl:if>
                <!-- PA: Clerical and Other -->
                <xsl:if test="key('personalAccident', 'B515 001') or key('personalAccident', 'B515 137')">
                    <Cover>
                        <Cover_CommissionStandardForCoverByBroker Val="{$discountPA}"/>
                        <Cover_Code Val="B205 P03"/>
                    </Cover>
                </xsl:if>

                <!-- WorkingInBusiness elements - derived from Personal Accident and Employers Liability input -->
                <!-- TODO: remove hard-coding of WorkingInBusiness_HeightLimit; it should be set to "Units of Benefit" from BI & PA page -->
                <!-- Clerical -->
                <xsl:variable name="clericalWages" select="number(concat('0', key('employersLiability', 'B515 001')/Employee/Wages))" />
                <WorkingInBusiness>
                    <WorkingInBusiness_EmployeeCode Val="B515 001"/>
                    <xsl:element name="WorkingInBusiness_NoOfIndividuals">
                        <xsl:attribute name="Val">
                            <xsl:value-of select="number(concat('0', key('personalAccident', 'B515 001')/GroupDetail/NoOfEmployees))" />
                        </xsl:attribute>
                    </xsl:element>
                    <xsl:if test="$clericalWages > 0">
                        <xsl:element name="WorkingInBusiness_WagesSalaryAmt">
                            <xsl:attribute name="Val">
                                <xsl:value-of select="$clericalWages" />
                            </xsl:attribute>
                        </xsl:element>
                    </xsl:if>
                    <WorkingInBusiness_HeightLimit Val="4" />
                </WorkingInBusiness>
                
                <!-- Pump Attendants (AKA Shop Assistants in the IAB front end) -->
                <xsl:variable name="pumpWages" select="number(concat('0', key('employersLiability', 'B515 004')/Employee/Wages))" />
                <WorkingInBusiness>
                    <WorkingInBusiness_EmployeeCode Val="B515 004"/>
                    <WorkingInBusiness_NoOfIndividuals Val="0" /><!-- Note: this is also hard coded to 0 in the spreadsheet VBA -->
                    <xsl:if test="$pumpWages > 0">
                        <xsl:element name="WorkingInBusiness_WagesSalaryAmt">
                            <xsl:attribute name="Val">
                                <xsl:value-of select="$pumpWages" />
                            </xsl:attribute>
                        </xsl:element>
                    </xsl:if>
                </WorkingInBusiness>
                
                <!-- Other Employees -->
                <xsl:variable name="otherWages" select="number(concat('0', key('employersLiability', 'B515 183')/Employee/Wages))" />
                <WorkingInBusiness>
                    <WorkingInBusiness_EmployeeCode Val="B515 219"/>
                    <xsl:element name="WorkingInBusiness_NoOfIndividuals">
                        <xsl:attribute name="Val">
                            <xsl:value-of select="number(concat('0', key('personalAccident', 'B515 137')/GroupDetail/NoOfEmployees))" />
                        </xsl:attribute>
                    </xsl:element>
                    <xsl:if test="$otherWages > 0">
                        <xsl:element name="WorkingInBusiness_WagesSalaryAmt">
                            <xsl:attribute name="Val">
                                <xsl:value-of select="$otherWages" />
                            </xsl:attribute>
                        </xsl:element>
                    </xsl:if>
                    <WorkingInBusiness_HeightLimit Val="4" />
                </WorkingInBusiness>

                <!-- PPD -->
                <WorkingInBusiness>
                    <WorkingInBusiness_EmployeeCode Val="B515 186"/>
                    <xsl:element name="WorkingInBusiness_NoOfIndividuals">
                        <xsl:attribute name="Val">
                            <xsl:value-of select="number(concat('0', key('personalAccident', 'B515 186')/GroupDetail/NoOfEmployees))" />
                        </xsl:attribute>
                    </xsl:element>
                    <WorkingInBusiness_HeightLimit Val="8" />
                </WorkingInBusiness>

                <!-- Apply templates that output Vehicle elements -->
                <xsl:apply-templates select="RoadRisksCover/VehicleCover/Code/Value" />
                <xsl:apply-templates select="WrongfulConversionCover/CoverDetail[SumInsured/Amount > 0 and AnnualLimit/Amount > 0]"/>
                <xsl:apply-templates select="VehicleBusinessUseGroup[NoOf]|VehiclePersonalUseGroup[NoOf]"/>

                <Vehicle>
                    <VehicleCover>
                        <VehicleCover_Code Val="B205 A06"/>
                        <VehicleCover_ExcessAmt Val="0"/>
                    </VehicleCover>
                </Vehicle>

                <Vehicle>
                    <Vehicle_Description Val="NamedDriversDiscount"/>
                    <VehicleUsage>
                        <VehicleUsage_Code Val="B549 002"/>
                    </VehicleUsage>
                </Vehicle>
    </xsl:template>

    <!-- **************************************************************** -->

    <!-- cover -->
    <xsl:template match="ProductLiabilityCover/CoverDetail/TurnoverBreakdown[TurnoverAmount > 0]">
        <CoverBreakdown>
            <!-- TODO temporary demo hack to be reconsidered: mapping 2 IAB codes to 1 XRTE code -->
            <xsl:element name="CoverBreakdown_Code">
                <xsl:attribute name="Val">
                    <xsl:choose>
                        <xsl:when test="TurnoverActivityCode/Value='B520 230'">B205 160</xsl:when>
                        <xsl:when test="TurnoverActivityCode/Value='B520 234'">B205 160</xsl:when>
                        <xsl:when test="TurnoverActivityCode/Value='B550 231'">B550 407</xsl:when>
                        <xsl:when test="TurnoverActivityCode/Value='B520 233'">B550 407</xsl:when>
                        <xsl:when test="TurnoverActivityCode/Value='B520 999'">B550 568</xsl:when>
                    </xsl:choose>
                </xsl:attribute>
            </xsl:element>

            <xsl:element name="CoverBreakdown_SiAmt">
                <xsl:attribute name="Val"><xsl:value-of select="TurnoverAmount" /></xsl:attribute>
            </xsl:element>
        </CoverBreakdown>
    </xsl:template>

    <xsl:template match="BusinessInterruptionCover[CoverDetail/SumInsured/Amount > 0]">
        <Cover>
            <xsl:element name="Cover_SiAmt">
                <xsl:attribute name="Val"><xsl:value-of select="CoverDetail/SumInsured/Amount" /></xsl:attribute>
            </xsl:element>
            <Cover_Code Val="B205 038"/>
            <Cover_IndemnityPeriodInMonths Val="12"/>
            <Cover_CommissionStandardForCoverByBroker Val="{$discountBI}"/>
        </Cover>
    </xsl:template>

    <!-- FJDTODO other employee types -->
    <xsl:template match="PersonalAccidentCover/CoverDetail[GroupDetail/EmploymentTypeCode/Value = 'B515 186' and GroupDetail/NoOfEmployees > 0]">
        <Cover>
            <Cover_CommissionStandardForCoverByBroker Val="{$discountPA}"/>
            <Cover_Code Val="B205 P03"/>
            <xsl:if test="BasisCode/Value = 'B506 100'">
                <Cover_BasisCode Val="B506 100"/>
            </xsl:if>
        </Cover>
    </xsl:template>
    <!-- TODO template similar to the above (but with no BasisCode) for Clerical and Other workers -->


    <!-- **************************************************************** -->

    <xsl:template match="RoadRisksCover/VehicleCover/NCDDetail[NCDYears > 0]">
        <InsuranceHistory>
            <NcdClaimed>
                <xsl:element name="NcdClaimed_Years">
                    <xsl:attribute name="Val"><xsl:value-of select="NCDYears"/></xsl:attribute>
                </xsl:element>
            </NcdClaimed>
        </InsuranceHistory>
    </xsl:template>


    <!-- **************************************************************** -->

    <!-- premises -->
    <xsl:template match="Location">
        <Premises>
            <Premises_PostcodeSector Val="P1 CV21 1"/>
            <!-- the following Val will need to increment with each occurence -->
            <Premises_InsuredObjectRef Val="1"/>
            <Premises_NoOfHoseReels Val="{$discountMD}"/>
            <PremisesCover>
                <PremisesCover_Code Val="B205 X37" />
                <xsl:element name="PremisesCover_ExcessAmt">
                    <!-- TODO this is hard-coded to 250 for the demo because
                         the XRTE only accepts values from a predefined list.
                         Need to replace the text box in the input with a
                         dropdown containing the allowed values and then use
                         the next line instead of 250:
                         <xsl:value-of select="number(concat('0',BuildingsCover/CoverDetail[Code/Value='B205 C22']/Excess/Amount))"/> -->
                    <!-- previous line prepends "0" to the Excess/Amount string so that "" gets converted to 0 -->
                    <xsl:attribute name="Val">250</xsl:attribute>
                </xsl:element>
                <xsl:apply-templates select="BuildingsCover/CoverDetail[(Code/Value='B205 C22' or Code/Value='B205 X57') and SumInsured/Amount > 0]" />
                <xsl:apply-templates select="ContentsCover/CoverDetail/Breakdown[(Code/Value='B550 019' or Code/Value='B550 001' or Code/Value='B550 550' or Code/Value='B550 002' or Code/Value='B205 104' or Code/Value='B550 409' or Code/Value='B550 464' or Code/Value='B205 E08' or Code/Value='B550 400') and SumInsured/Amount > 0]" />
                <xsl:apply-templates select="EngineeringCover/HiredInPlant[RatingData > 0]" />

                <xsl:variable name="totalVehicleSumInsuredForLocation" select="sum(VehicleCover/SumInsured/Amount)" />
                <xsl:for-each select="VehicleCover[SumInsured/Amount > 0]">
                    <PremisesCoverBreakdown>
                        <xsl:element name="PremisesCoverBreakdown_SiAmt">
                            <xsl:attribute name="Val"><xsl:value-of select="$totalVehicleSumInsuredForLocation" /></xsl:attribute>
                        </xsl:element>
                        <xsl:element name="PremisesCoverBreakdown_SiPercentage">
                            <xsl:attribute name="Val"><xsl:value-of select="100 * (SumInsured/Amount div $totalVehicleSumInsuredForLocation)" /></xsl:attribute>
                        </xsl:element>
                        <!-- TODO this template is a temporary hack for the demo and the mapping that it does doesn't really make sense -->
                        <xsl:element name="PremisesCoverBreakdown_Code">
                            <xsl:attribute name="Val">
                                <xsl:choose>
                                    <xsl:when test="Code/Value='B550 555' or Code/Value='B550 552'">B550 555</xsl:when>
                                    <xsl:otherwise>B550 557</xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
                        </xsl:element>
                    </PremisesCoverBreakdown>
                </xsl:for-each>
            </PremisesCover>

            <PremisesCover>
                <PremisesCover_Code Val="B205 G06" />
                <xsl:apply-templates select="ContentsCover/CoverDetail/Breakdown[Code/Value='B205 P07' and SumInsured/Amount > 0]" />
            </PremisesCover>

            <xsl:if test="count(EngineeringCover/HiredInPlant/TypeCode/Value) > 0">
                <PremisesCover>
                    <PremisesCover_Code Val="B205 162" />
                </PremisesCover>
            </xsl:if>

            <!-- TODO only output this PremisesCover if the apply-templates inside it will produce some output -->
            <PremisesCover>
                <PremisesCover_Code Val="B205 M11" />
                <xsl:apply-templates select="MoneyCover/CoverDetail/CoverBreakdown[SumInsured/Amount > 0]"/>
            </PremisesCover>
        </Premises>
    </xsl:template>

    <xsl:template match="BuildingsCover/CoverDetail[(Code/Value='B205 C22' or Code/Value='B205 X57') and SumInsured/Amount > 0]">
        <PremisesCoverBreakdown>
            <xsl:element name="PremisesCoverBreakdown_SiAmt">
                <xsl:attribute name="Val"><xsl:value-of select="SumInsured/Amount" /></xsl:attribute>
            </xsl:element>
            <xsl:element name="PremisesCoverBreakdown_Code">
                <xsl:attribute name="Val">
                    <xsl:choose>
                        <!-- Existing Buildings -->
                        <xsl:when test="Code/Value='B205 C22'">B205 B01</xsl:when>
                        <!-- Tenant's Improvements -->
                        <xsl:when test="Code/Value='B205 X57'">B550 395</xsl:when>
                    </xsl:choose>
                </xsl:attribute>
            </xsl:element>
        </PremisesCoverBreakdown>
    </xsl:template>

    <xsl:template match="ContentsCover/CoverDetail/Breakdown[(Code/Value='B550 019' or Code/Value='B550 001' or Code/Value='B550 550' or Code/Value='B550 002' or Code/Value='B205 104' or Code/Value='B550 409' or Code/Value='B550 464' or Code/Value='B205 E08' or Code/Value='B550 400') and SumInsured/Amount > 0]">
        <PremisesCoverBreakdown>
            <xsl:element name="PremisesCoverBreakdown_SiAmt">
                <xsl:attribute name="Val"><xsl:value-of select="SumInsured/Amount" /></xsl:attribute>
            </xsl:element>
            <xsl:element name="PremisesCoverBreakdown_Code">
                <xsl:attribute name="Val">
                    <!-- TODO remove demo hack that maps "AudioVisual Media"
                         (B550 550), "Wines Fortified Wines And Spirits"
                         (B550 002) and "Clothing And Personal Effects" (B205
                         104) to "Cigarettes Cigars and Tobacco" (B550 001)
                         -->
                    <xsl:choose>
                        <xsl:when test="Code/Value='B550 550'">B550 001</xsl:when>
                        <xsl:when test="Code/Value='B550 002'">B550 001</xsl:when>
                        <xsl:when test="Code/Value='B205 104'">B550 001</xsl:when>
                        <xsl:otherwise><xsl:value-of select="Code/Value" /></xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
            </xsl:element>
        </PremisesCoverBreakdown>
    </xsl:template>

    <!-- Goods in Transit -->
    <xsl:template match="ContentsCover/CoverDetail/Breakdown[Code/Value='B205 P07' and SumInsured/Amount > 0]">
        <PremisesCoverBreakdown>
            <xsl:element name="PremisesCoverBreakdown_SiAmt">
                <xsl:attribute name="Val"><xsl:value-of select="SumInsured/Amount" /></xsl:attribute>
            </xsl:element>
            <PremisesCoverBreakdown_Code Val="B550 464" />
        </PremisesCoverBreakdown>
    </xsl:template>


    <xsl:template match="EngineeringCover/HiredInPlant[RatingData > 0]">
        <PremisesCoverBreakdown>
            <xsl:element name="PremisesCoverBreakdown_SiAmt">
                <xsl:attribute name="Val"><xsl:value-of select="RatingData" /></xsl:attribute>
            </xsl:element>
            <PremisesCoverBreakdown_Code Val="B205 O05" />
        </PremisesCoverBreakdown>
    </xsl:template>

    <!-- TODO currently both "Money In Transit" (B205 240) and "Money In Bank Night Safe" (B205 M01) IAB are mapped to B205 240.  This is a hack for the demo because the spreadsheet only has one field, "In Transit or In A Bank Night Safe" that corresponds to both these IAB fields. -->
    <xsl:template match="MoneyCover/CoverDetail/CoverBreakdown[SumInsured/Amount > 0]">
        <PremisesCoverBreakdown>
            <xsl:element name="PremisesCoverBreakdown_SiAmt">
                <xsl:attribute name="Val"><xsl:value-of select="SumInsured/Amount" /></xsl:attribute>
            </xsl:element>
            <xsl:element name="PremisesCoverBreakdown_Code">
                <xsl:attribute name="Val">
                    <xsl:choose>
                        <xsl:when test="Code/Value='B205 M06'">B205 M12</xsl:when>
                        <xsl:when test="Code/Value='B205 M01'">B205 240</xsl:when>
                        <xsl:otherwise><xsl:value-of select="Code/Value" /></xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
            </xsl:element>
        </PremisesCoverBreakdown>

    </xsl:template>

    <!-- **************************************************************** -->

    <!-- workinginbusiness -->
    <!-- FJDTODO
    <xsl:template match="PersonalAccidentCover/CoverDetail/GroupDetail/[NoOfEmployees > 0]">
        <WorkingInBusiness>
            <WorkingInBusiness_EmployeeCode Val="B515 001"/>
            <xsl:element name="WorkingInBusiness_NoOfIndividuals">
                <xsl:attribute name="Val"><xsl:value-of select="NoOfEmployees" /></xsl:attribute>
            </xsl:element>
            <WorkingInBusiness_WagesSalaryAmt Val="10000"/>
            <WorkingInBusiness_HeightLimit Val="4" />
        </WorkingInBusiness>
    </xsl:template>
    -->

    <!-- **************************************************************** -->

    <!-- vehicle -->
    <xsl:template match="RoadRisksCover/VehicleCover/Code/Value">
        <Vehicle>
            <VehicleCover>
                <xsl:element name="VehicleCover_Code">
                    <xsl:attribute name="Val"><xsl:value-of select="."/></xsl:attribute>
                </xsl:element>
            </VehicleCover>
        </Vehicle>
    </xsl:template>

    <xsl:template match="WrongfulConversionCover/CoverDetail[SumInsured/Amount > 0 and AnnualLimit/Amount > 0]">
      <Vehicle>
        <VehicleCover>
          <VehicleCover_Code Val="B205 X73"/>
          <VehicleCover_CommissionStandardForCoverByBroker Val="0"/>
          <VehicleCoverBreakdown>
            <VehicleCoverBreakdown_Code Val="B205 U03"/>
            <xsl:element name="VehicleCoverBreakdown_SiAmt">
              <xsl:attribute name="Val"><xsl:value-of select="SumInsured/Amount" /></xsl:attribute>
            </xsl:element>
            <xsl:element name="VehicleCoverBreakdown_ExcessAmt">
              <xsl:attribute name="Val"><xsl:value-of select="AnnualLimit/Amount" /></xsl:attribute>
            </xsl:element>
          </VehicleCoverBreakdown>
        </VehicleCover>
        <VehicleUsage>
          <VehicleUsage_Code Val="B549 002"/>
        </VehicleUsage>
        <!-- TODO: use an XSL key here? -->
        <xsl:if test="/MotorTradeQuoteNBRq/VehicleBusinessUseGroup[Description='8']/NoOf > 0">
            <xsl:element name="Vehicle_NoOfDrivers">
                <xsl:attribute name="Val"><xsl:value-of select="/MotorTradeQuoteNBRq/VehicleBusinessUseGroup[Description='8']/NoOf" /></xsl:attribute>
            </xsl:element>
        </xsl:if>
      </Vehicle>
    </xsl:template>


    <!-- Business Drivers - suppress output as this input node is handled by the WrongfulConversion template -->
    <xsl:template match="VehicleBusinessUseGroup[Description='8']">
    </xsl:template>

    <!-- Business Use Vehicles -->
    <xsl:template match="VehicleBusinessUseGroup[Description != '8']">
        <Vehicle>
            <xsl:element name="Vehicle_NoOfVehicles">
                <xsl:attribute name="Val"><xsl:value-of select="NoOf" /></xsl:attribute>
            </xsl:element>
            <VehicleUsage>
                <VehicleUsage_Code Val="B549 002"/>
            </VehicleUsage>
            <xsl:choose>
                <xsl:when test="Description='0'">
                    <!-- Trade Plates -->
                    <Vehicle_TypeCode Val="B900 008"/>
                </xsl:when>

                <xsl:when test="Description='1'">
                    <!-- Recovery Vehicles - 1 vehicle capacity -->
                    <Vehicle_CategoryTypeCode Val="B10 30"/>
                    <Vehicle_CarryingCapacity Val="1"/>
                </xsl:when>

                <xsl:when test="Description='2'">
                    <!-- Recovery Vehicles - 2 vehicle capacity -->
                    <Vehicle_CategoryTypeCode Val="B10 30"/>
                    <Vehicle_CarryingCapacity Val="2"/>
                </xsl:when>

                <xsl:when test="Description='4'">
                    <!-- Passenger Carriers up to 8 people -->
                    <Vehicle_CategoryTypeCode Val="B10 60"/>
                    <Vehicle_CarryingCapacity Val="8"/>
                </xsl:when>

                <xsl:when test="Description='5'">
                    <!-- All Other Vehicles -->
                    <Vehicle_TypeCode Val="B900 010"/>
                </xsl:when>

                <xsl:when test="Description='6'">
                    <!-- Courtesy Vehicles -->
                    <Vehicle_TypeCode Val="B900 101"/>
                </xsl:when>
            </xsl:choose>
        </Vehicle>
    </xsl:template>

    <!-- Personal Use Vehicles -->
    <xsl:template match="VehiclePersonalUseGroup[Description != '5' and Description != '6']">
        <Vehicle>
            <VehicleUsage>
                <VehicleUsage_Code Val="B549 011"/>
            </VehicleUsage>
            <xsl:element name="Vehicle_NoOfVehicles">
                <xsl:attribute name="Val"><xsl:value-of select="NoOf" /></xsl:attribute>
            </xsl:element>
            <xsl:choose>
                <xsl:when test="Description = '0'">
                    <!-- Personal Use: Cars.  TODO: this doesn't appear in the input XML even when a value is entered into the form. -->
                    <Vehicle_TypeCode Val="B900 028"/>
                </xsl:when>

                <xsl:when test="Description = '1'">
                    <Vehicle_TypeCode Val="B900 049"/>
                    <Vehicle_GrossVehicleWeight Val="2"/>
                </xsl:when>

                <xsl:when test="Description = '2'">
                    <Vehicle_TypeCode Val="B900 049"/>
                    <Vehicle_GrossVehicleWeight Val="7"/>
                </xsl:when>

                <xsl:when test="Description = '3'">
                    <Vehicle_TypeCode Val="B900 060"/>
                    <Vehicle_EngineCubicCapacity Val="500"/>
                </xsl:when>

                <xsl:when test="Description = '4'">
                    <Vehicle_TypeCode Val="B900 060"/>
                    <Vehicle_EngineCubicCapacity Val="1000"/>
                </xsl:when>

                <xsl:when test="Description>=7 and Description&lt;=13">
                    <!-- Group 14 - 20 vehicles -->
                    <xsl:element name="Vehicle_CategoryTypeCode">
                        <xsl:attribute name="Val">
                            <xsl:choose>
                                <xsl:when test="Description=7">B10 24</xsl:when>
                                <xsl:when test="Description=8">B10 25</xsl:when>
                                <xsl:when test="Description=9">B10 T6</xsl:when>
                                <xsl:when test="Description=10">B10 AK</xsl:when>
                                <xsl:when test="Description=11">B10 26</xsl:when>
                                <xsl:when test="Description=12">B10 27</xsl:when>
                                <xsl:when test="Description=13">B10 28</xsl:when>
                            </xsl:choose>
                        </xsl:attribute>
                    </xsl:element>
                </xsl:when>
            </xsl:choose>
        </Vehicle>
    </xsl:template>

    <xsl:template match="VehiclePersonalUseGroup[Description='5']">
        <Vehicle>
            <VehicleUsage>
                <VehicleUsage_Code Val="B549 011"/>
            </VehicleUsage>
            <Vehicle_PermittedDriverCode Val="B134 H"/>
            <xsl:element name="Vehicle_NoOfDrivers">
                <xsl:attribute name="Val"><xsl:value-of select="NoOf" /></xsl:attribute>
            </xsl:element>
        </Vehicle>
    </xsl:template>

    <xsl:template match="VehiclePersonalUseGroup[Description='6']">
        <Vehicle>
            <VehicleUsage>
                <VehicleUsage_Code Val="B549 011"/>
            </VehicleUsage>
            <Vehicle_PermittedDriverCode Val="B134 I"/>
            <xsl:element name="Vehicle_NoOfDrivers">
                <xsl:attribute name="Val"><xsl:value-of select="NoOf" /></xsl:attribute>
            </xsl:element>
        </Vehicle>
    </xsl:template>

    <!-- **************************************************************** -->

    <!-- Suppress default template that copies text to the output -->
    <!-- TODO: make this unneccessary by making sure that everything in the
         input is matched by another rule in this file -->
    <!--
    <xsl:template match="text()"/>
    -->
</xsl:stylesheet>
