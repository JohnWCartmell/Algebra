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


	<!-- call fourthpass before recursive enrichment     -->
	<!--   + fourthpass adds types                       -->
	<!--   + recursive enrichment normalises the types  -->

	<!-- module would begin here -->
	<!-- was 
  <xsl:template name="initial_enrichment">
    <xsl:param name="document"/>
    <xsl:variable name="current_state">
      <xsl:for-each select="$document">
        <xsl:copy>
          <xsl:apply-templates mode="initial_enrichment_fourth_pass"/>
        </xsl:copy>
      </xsl:for-each>
    </xsl:variable>
    <xsl:call-template name="initial_enrichment_recursive">
      <xsl:with-param name="interim" select="$current_state"/>
    </xsl:call-template>
  </xsl:template>
   now is -->

	<xsl:template match="*" mode="type_enrich">
		<xsl:message>Type enriching <xsl:value-of select="name()"/></xsl:message>
		<!--
    <xsl:variable name="current_state" as="element()">
      <xsl:copy>
        <xsl:apply-templates mode="initial_enrichment_fourth_pass"/>
      </xsl:copy>
    </xsl:variable>
	-->
		<xsl:call-template name="initial_enrichment_recursive">
			<xsl:with-param name="interim" select="."/>
		</xsl:call-template>
	</xsl:template>


	<!--
  <xsl:template match="*" mode="initial_enrichment_fourth_pass">
    <xsl:copy copy-namespaces="no">
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="initial_enrichment_fourth_pass"/>
    </xsl:copy>
  </xsl:template>
  
  -->


	<xsl:template match="*[self::*:var][not(gat:type)]" mode="initial_enrichment_recursive" priority="100">
		<xsl:copy>  
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="initial_enrichment_recursive"/>
			<!--<xsl:copy-of select="(ancestor::T-rule|ancestor::tT-rule|ancestor::tt-rule|ancestor::TT-rule)/context/decl[name=current()/name]/type" /> -->
			<xsl:choose>
				<xsl:when test="ancestor::decl|ancestor::sequence">
					<xsl:apply-templates mode="normalise" 
							select="(ancestor::decl|ancestor::sequence)/preceding-sibling::decl[name=current()/name]/type"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates mode="normalise" 
							select="(ancestor::T-rule|ancestor::tT-rule|ancestor::tt-rule|ancestor::TT-rule)/context/decl[name=current()/name]/type"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*[self::*:seq][not(gat:type)]" mode="initial_enrichment_recursive" priority="100">
		<xsl:copy>  
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="initial_enrichment_recursive"/>
			<xsl:choose>
				<xsl:when test="ancestor::decl|ancestor::sequence">

					<xsl:apply-templates mode="normalise" 
							select="(ancestor::decl|ancestor::sequence)/preceding-sibling::sequence[name=current()/name]/type"/>
				</xsl:when>
				<xsl:otherwise>
					<!--<xsl:copy-of select="(ancestor::T-rule|ancestor::tT-rule|ancestor::tt-rule|ancestor::TT-rule)/context/sequence[name=current()/name]/type" />-->
					<xsl:apply-templates mode="normalise" 
							select="(ancestor::T-rule|ancestor::tT-rule|ancestor::tt-rule|ancestor::TT-rule)/context/sequence[name=current()/name]/type"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:copy>
	</xsl:template>

	<xsl:template name="initial_enrichment_recursive">
		<xsl:param name="interim" as="element()"/>
		<!--
		<xsl:message>Initial enrichment recursive at type <xsl:value-of select="$interim/name()"/> Complexity <xsl:value-of select="count($interim/descendant::*)"/></xsl:message>
		-->
		<xsl:variable name ="next" as="element()">
			<xsl:for-each select="$interim">
				<xsl:copy>
					<xsl:apply-templates mode="initial_enrichment_recursive"/>
				</xsl:copy>
			</xsl:for-each>
		</xsl:variable>
		<xsl:variable name="result" as="element()">
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
	
	
	<xsl:template match="gat:type_error"
			mode="initial_enrichment_recursive"> 
		<xsl:message>Passing through gat:type_error in initial enrichment recursive</xsl:message>
		<xsl:copy-of select="."/>
	</xsl:template>
	

</xsl:transform>
