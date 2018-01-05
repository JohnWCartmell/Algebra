<!--
algebratext.module.xslt
**********************

DESCRIPTION

-->

<xsl:transform version="2.0" 
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xs="http://www.w3.org/2001/XMLSchema">




  <xsl:template match="o"  mode="text">
    <xsl:variable name="args" as="xs:string *">
      <xsl:for-each select="*">
        <xsl:variable name="arg">
          <xsl:apply-templates select="." mode="text"/>
        </xsl:variable>
        <xsl:value-of select="$arg"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:text>o(</xsl:text>
    <xsl:value-of select="string-join($args,',')"/>
    <xsl:text>)</xsl:text>
  </xsl:template>


  <xsl:template match="q" mode="text">
    <xsl:text>q(</xsl:text>
    <xsl:apply-templates select="*[1]" mode="text"/>
    <xsl:text>,</xsl:text>
    <xsl:apply-templates select="*[2]" mode="text"/>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="star" mode="text">
    <xsl:choose> 
      <xsl:when test="*[1][self::o|self::star]">
        <xsl:text>(</xsl:text>
        <xsl:apply-templates select="*[1]" mode="text"/>
        <xsl:text>)</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="*[1]" mode="text"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>*</xsl:text>
    <xsl:choose> 
      <xsl:when test="*[2][self::o | self::star]">
        <xsl:text>(</xsl:text>
        <xsl:apply-templates select="*[2]" mode="text"/>
        <xsl:text>)</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="*[2]" mode="text"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="s" mode="text">
    <xsl:text>s(</xsl:text>
    <xsl:apply-templates select="*[1]" mode="text"/>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="p|id|a|b|c|d|e" mode="text">
    <xsl:value-of select="name()"/>
  </xsl:template>

  <xsl:template match="ob" mode="text">
    <xsl:text>ob</xsl:text>
  </xsl:template>  

  <xsl:template match="hom" mode="text">
    <xsl:text>hom(</xsl:text>
    <xsl:apply-templates select="*[1]" mode="text"/>
    <xsl:text>,</xsl:text>
    <xsl:apply-templates select="*[2]" mode="text"/>
    <xsl:text>)</xsl:text>
  </xsl:template>




</xsl:transform>
