<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform xmlns:era="http://www.entitymodelling.org/ERmodel"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0">
  <xsl:output method="xml" indent="yes"/>

  <xsl:template match="/">
    <xsl:copy>
      <xsl:apply-templates mode="pass_0"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="@*|node()" mode="pass_0">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="pass_0"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="include[not(*/self::type)]" mode="pass_0">
    <xsl:apply-templates select="document(filename)/algebra/*" mode="pass_0"/>
  </xsl:template>
</xsl:transform>