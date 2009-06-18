<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    
    <xsl:param name="code"/>
    
    <xsl:key match="WorkArea" name="workAreaDescriptions" use="WorkArea_Description/@Val"/>
    
    <xsl:template match="/">
        <xsl:variable name="codeDescription">
            <xsl:choose>
                <xsl:when test="$code='B205 X57'">Tenants Rate</xsl:when>
                <xsl:when test="$code='B205 C22'">Buildings Rate</xsl:when>
                <xsl:when test="$code='B550 019'">Stock Rate</xsl:when>
                <xsl:when test="$code='B550 001'">Cigs Rate</xsl:when>
                <xsl:when test="$code='B550 550'">Cigs Rate</xsl:when>
                <xsl:when test="$code='B550 002'">Cigs Rate</xsl:when>
                <xsl:when test="$code='B205 104'">Cigs Rate</xsl:when>
                <xsl:when test="$code='B550 409'">In Vehicle Ent Rate</xsl:when>
                <xsl:when test="$code='B550 464'">Property Damage Rate</xsl:when>
                <xsl:when test="$code='B205 E08'">Vehicle Conts Rate</xsl:when>
                <xsl:when test="$code='B550 400'">Frozen Food</xsl:when>
                <xsl:when test="$code='B205 P07'">GIT Stock</xsl:when>
                <xsl:when test="$code='B205 M05'">Bus Hours</xsl:when>
                <xsl:when test="$code='B205 M06'">Outside Bus Hours</xsl:when>
                <xsl:when test="$code='B205 M02'">Personal Custody</xsl:when>
                <xsl:when test="$code='B205 240'">Outside Bus Hours</xsl:when>
                <xsl:when test="$code='B205 M01'">Transit</xsl:when>
                <xsl:when test="$code='B205 M03'">Outside Bus Hours No Safe</xsl:when>
                <xsl:when test="$code='B550 555'">Motor Rate Building</xsl:when>
                <xsl:when test="$code='B550 552'">Motor Rate Building</xsl:when>
                <xsl:when test="$code='B550 557'">Motor Rate Building</xsl:when>
                <xsl:when test="$code='B550 554'">Motor Rate Building</xsl:when>
                <xsl:when test="$code='0'">Trade Plates (Road Risks Bus. Use)</xsl:when>
                <xsl:when test="$code='1'">Recovery Vehicles (1) (Road Risks Bus. Use)</xsl:when>
                <xsl:when test="$code='2'">Recovery Vehicles (2) (Road Risks Bus. Use)</xsl:when>
                <xsl:when test="$code='3'">Trailers (Road Risks Bus. Use)</xsl:when>
                <xsl:when test="$code='4'">Passenger Carriers (Road Risks Bus. Use)</xsl:when>
                <xsl:when test="$code='5'">Other (Road Risks Bus. Use)</xsl:when>
                <xsl:when test="$code='6'">Courtesy Cars (Road Risks Bus. Use)</xsl:when>
                <xsl:when test="$code='7'">Wedding/Funerals (Road Risks Bus. Use)</xsl:when>
                <xsl:when test="$code='8'">Business Drivers (Road Risks Bus. Use)</xsl:when>
            </xsl:choose>
        </xsl:variable>

        <xsl:apply-templates select="key('workAreaDescriptions',$codeDescription)" />
    </xsl:template>

    <xsl:template match="WorkArea">
        <xsl:value-of select="WorkArea_Amt/@Val"/>
    </xsl:template>   
    
</xsl:stylesheet>