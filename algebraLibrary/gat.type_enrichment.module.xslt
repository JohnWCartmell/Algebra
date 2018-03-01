<!-- 
Description
 This is module is responsible for generic aspects of type enrichment
 
 -->


<xsl:transform version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:gat              ="http://www.entitymodelling.org/theory/generalisedalgebraictheory"
    xmlns:cc               ="http://www.entitymodelling.org/theory/contextualcategory"
    xpath-default-namespace="http://www.entitymodelling.org/theory/generalisedalgebraictheory"	   
    xmlns="http://www.entitymodelling.org/theory/generalisedalgebraictheory">

  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>


  <!-- call thirdpass before recursive enrichment     -->
  <!--   + thirdpass adds types                       -->
  <!--   + recursive enrichment normalises the types  -->

  <!-- module would begin here -->
  <!-- was 
  <xsl:template name="initial_enrichment">
    <xsl:param name="document"/>
    <xsl:variable name="current_state">
      <xsl:for-each select="$document">
        <xsl:copy>
          <xsl:apply-templates mode="initial_enrichment_third_pass"/>
        </xsl:copy>
      </xsl:for-each>
    </xsl:variable>
    <xsl:call-template name="initial_enrichment_recursive">
      <xsl:with-param name="interim" select="$current_state"/>
    </xsl:call-template>
  </xsl:template>
   now is -->

  <xsl:template match="*" mode="type_enrich">
    <xsl:variable name="current_state">
      <xsl:copy>
        <xsl:apply-templates mode="initial_enrichment_third_pass"/>
      </xsl:copy>
    </xsl:variable>
    <xsl:call-template name="initial_enrichment_recursive">
      <xsl:with-param name="interim" select="$current_state"/>
    </xsl:call-template>
  </xsl:template>




  <!-- NEED call thirdpass before recusrive enrichment -->
  <xsl:template match="*" mode="initial_enrichment_third_pass">
    <xsl:copy copy-namespaces="no">
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="initial_enrichment_third_pass"/>
    </xsl:copy>
  </xsl:template>




  <xsl:template match="*[self::*:var][not(gat:type)]" mode="initial_enrichment_third_pass" priority="100">
    <xsl:copy>  
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="initial_enrichment_third_pass"/>
      <!-- FEb 13 2018
			<xsl:copy-of select="(ancestor::rewriteRule|ancestor::equation|ancestor::example)/context/decl[name=current()/name]/type" />
			-->
      <xsl:copy-of select="(ancestor::rewriteRule|ancestor::equation|ancestor::example)/context/decl[name=current()/name]/type" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*[self::*:seq][not(gat:type)]" mode="initial_enrichment_third_pass" priority="100">
    <xsl:copy>  
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="initial_enrichment_third_pass"/>
      <!--
			<xsl:copy-of select="(ancestor::rewriteRule|ancestor::equation|ancestor::example)/context/sequence[name=current()/name]/type" />
			-->
      <xsl:copy-of select="(ancestor::rewriteRule|ancestor::equation|ancestor::example)/context/sequence[name=current()/name]/type" />
    </xsl:copy>
  </xsl:template>





  <xsl:template name="initial_enrichment_recursive">
    <xsl:param name="interim"/>
    <xsl:variable name ="next">
      <xsl:for-each select="$interim">
        <xsl:copy>
          <xsl:apply-templates mode="initial_enrichment_recursive"/>
        </xsl:copy>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="result">
      <xsl:choose>
        <xsl:when test="not(deep-equal($interim,$next))">
          <!-- CR-18553 -->
          <xsl:message> changed in initial enrichment recursive</xsl:message>
          <xsl:call-template name="initial_enrichment_recursive">
            <xsl:with-param name="interim" select="$next"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message> unchanged fixed point of initial enrichment recursive </xsl:message>
          <xsl:copy-of select="$interim"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>  
    <xsl:copy-of select="$result"/>
  </xsl:template>


  <xsl:template match="*"
      mode="initial_enrichment_recursive"> 
    <xsl:copy copy-namespaces="no">
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="initial_enrichment_recursive"/>
    </xsl:copy>
  </xsl:template>


</xsl:transform>
