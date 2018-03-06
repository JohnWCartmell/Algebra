<!--
algebra2number.module.xslt
**********************

DESCRIPTION

-->

<xsl:transform version="2.0" 
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
	    xmlns:ccseq               ="http://www.entitymodelling.org/theory/contextualcategory/sequence"
		xmlns:gat              ="http://www.entitymodelling.org/theory/generalisedalgebraictheory" 	   
		                  xmlns="http://www.entitymodelling.org/theory/contextualcategory/sequence" 
		xpath-default-namespace="http://www.entitymodelling.org/theory/contextualcategory/sequence" >



		
  <xsl:template match="gat:term" mode="number"> 
  <xsl:message> costing a term </xsl:message>
    <xsl:apply-templates select="ccseq:*[1]" mode="number"/>	   
  </xsl:template>

  <xsl:template match="var" mode="number">
    <xsl:value-of select="1"/>
  </xsl:template>

  <xsl:template match="seq" mode="number">
    <xsl:value-of select="1"/>
  </xsl:template>

  <xsl:template match="gat:point" mode="number">
    <xsl:apply-templates select="*[1]" mode="number"/>
  </xsl:template>


  <xsl:template match="o"  mode="number">
    <xsl:choose>
      <xsl:when test="count(*) &gt; 0">
        <xsl:variable name="arg" as="xs:double *">
          <xsl:apply-templates select="ccseq:*" mode="number"/>
        </xsl:variable>
        <xsl:value-of select="sum($arg)+1"/>
      </xsl:when>
      <xsl:otherwise> 
        <xsl:value-of select="1"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="q" mode="number">
    <xsl:choose>
      <xsl:when test="count(*)=2">
        <xsl:variable name="arg1" as="xs:double">
          <xsl:apply-templates select="*[1]" mode="number"/>
        </xsl:variable>
        <xsl:variable name="arg2" as="xs:double">
          <xsl:apply-templates select="*[2]" mode="number"/>
        </xsl:variable>
        <xsl:value-of select="$arg1 + $arg2"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>**********  q Term has error in number of args <xsl:copy-of select="."/>
        </xsl:message>
        <xsl:value-of select="0"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="star" mode="number">
      <xsl:choose>
      <xsl:when test="count(*)=2">
        <xsl:variable name="arg1" as="xs:double">
          <xsl:apply-templates select="*[1]" mode="number"/>
        </xsl:variable>
        <xsl:variable name="arg2" as="xs:double">
          <xsl:apply-templates select="*[2]" mode="number"/>
        </xsl:variable>
        <xsl:value-of select="$arg1 + $arg2"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>**********  star Term has error in number of args <xsl:copy-of select="."/>
        </xsl:message>
        <xsl:value-of select="0"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="s|id|p" mode="number">
    <xsl:choose>
      <xsl:when test="count(ccseq:*)=1">
        <xsl:variable name="arg" as="xs:double">
          <xsl:apply-templates select="ccseq:*[1]" mode="number"/>
        </xsl:variable>
        <xsl:value-of select="$arg + 1"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>**********  <xsl:value-of select="name()"/> term has error in number of args <xsl:copy-of select="."/>
        </xsl:message>
        <xsl:value-of select="0"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

 
  

</xsl:transform>
