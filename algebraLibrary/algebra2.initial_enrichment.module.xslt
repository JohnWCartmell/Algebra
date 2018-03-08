<!-- 
Description

 This is an  initial enrichment that applies to a set of rules.
 
 -->

<xsl:transform version="2.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:gat              ="http://www.entitymodelling.org/theory/generalisedalgebraictheory"
		xpath-default-namespace="http://www.entitymodelling.org/theory/generalisedalgebraictheory"	   
		xmlns="http://www.entitymodelling.org/theory/generalisedalgebraictheory">

	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

	<xsl:template match="/">
		<xsl:for-each select="algebra">
			<xsl:copy>
				<xsl:copy-of select="namespace::*"/>
				<xsl:for-each select="*">
					<xsl:call-template name="initial_enrichment">
						<xsl:with-param name="document" select="."/>
					</xsl:call-template>
				</xsl:for-each>
			</xsl:copy>
		</xsl:for-each>
	</xsl:template>


	<!-- module would begin here -->
	<xsl:template name="initial_enrichment">
		<xsl:param name="document"/>
		<!-- The initial enrichment generates id attributes for terms 
	     other than var and seq terms.
		 As at 18 Jan 2018 it is also responsible for generating
		 type information for <var> terms by looking up <decl>
		 elements from context. 
	-->
		<xsl:variable name="current_state">
			<xsl:for-each select="$document">
				<xsl:copy>
					<xsl:apply-templates mode="initial_enrichment_zero_pass"/>
				</xsl:copy>
			</xsl:for-each>
		</xsl:variable>
		<xsl:variable name="current_state">
			<xsl:for-each select="$current_state">
				<xsl:copy>
					<xsl:apply-templates mode="initial_enrichment_first_pass"/>
				</xsl:copy>
			</xsl:for-each>
		</xsl:variable>
		<!--
    <xsl:variable name="current_state">
	-->
		<xsl:for-each select="$current_state">
			<xsl:copy>
				<xsl:apply-templates mode="initial_enrichment_second_pass"/>
			</xsl:copy>
		</xsl:for-each>
		<!--
    </xsl:variable>
 
    <xsl:for-each select="$current_state">
      <xsl:copy>
        <xsl:apply-templates mode="initial_enrichment_third_pass"/>
      </xsl:copy>
    </xsl:for-each>
	-->
	</xsl:template>

	<xsl:template match="*"
			mode="initial_enrichment_zero_pass"> 
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="initial_enrichment_zero_pass"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*[self::*:var|self::*:seq][not(name)]" mode="initial_enrichment_zero_pass">
		<xsl:copy>
			<gat:name><xsl:value-of select="text()"/></gat:name>
			<xsl:apply-templates select="*[not(text())]" mode="initial_enrichment_zero_pass"/>
		</xsl:copy>
	</xsl:template>


	<xsl:template match="gat:*"
			mode="initial_enrichment_first_pass"> 
		<xsl:copy copy-namespaces="no">
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="initial_enrichment_first_pass"/>
		</xsl:copy>
	</xsl:template>

	<!--
  <xsl:template match="algebra|name|id" mode="initial_enrichment_first_pass">
    <xsl:copy>
      <xsl:apply-templates mode="initial_enrichment_first_pass"/>
    </xsl:copy>
  </xsl:template>
  -->

	<!-- Can we change this match condition to *[not(self::gat:*|self::*.var|self::*.seq]  ???-->
	<!--
  the gat:required tag is a tag to instruct that the type of a variable is going to be needed in the rhs of a rule.
  For such types an id attribute needs be generated
  now -->
	<xsl:template match="*[not(self::gat:*|self::*:var|self::*:seq) or self::gat:type[child::gat:required]]" mode="initial_enrichment_first_pass">
		<xsl:copy>
			<xsl:if test="ancestor::lhs">
				<xsl:attribute name="id">
					<xsl:value-of  select="name()"/>
					<xsl:number level="any"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates mode="initial_enrichment_first_pass"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*:var" mode="initial_enrichment_first_pass">
		<xsl:copy>
			<xsl:if test="ancestor::lhs">
				<xsl:attribute name="id" select="concat(
					gat:name,'_',
					count(ancestor-or-self::*[ancestor::lhs]/preceding-sibling::*/descendant-or-self::*:var[name=current()/name])+1
					)"/>
			</xsl:if>
			<xsl:apply-templates mode="initial_enrichment_first_pass"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*:seq" mode="initial_enrichment_first_pass">
		<xsl:copy>
			<xsl:if test="ancestor::lhs">
				<xsl:attribute name="id" select="concat(
					gat:name,'_',
					count(ancestor-or-self::*[ancestor::lhs]/preceding-sibling::*/descendant-or-self::*:seq[name=current()/name])+1
					)"/>
			</xsl:if>
			<xsl:apply-templates mode="initial_enrichment_first_pass"/>
		</xsl:copy>
	</xsl:template>

	<!--
  <xsl:template match="rewriteRule" mode="initial_enrichment_first_pass">
    <xsl:copy>
      <xsl:apply-templates mode="initial_enrichment_first_pass"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="lhs|rhs|term" mode="initial_enrichment_first_pass">
    <xsl:copy>
      <xsl:apply-templates mode="initial_enrichment_first_pass"/>
    </xsl:copy>
  </xsl:template>
  -->

	<!--	<xsl:template match="algebra|name|id" mode="initial_enrichment_second_pass"> -->
	<xsl:template match="gat:*[not(self::gat:type)]" mode="initial_enrichment_second_pass">
		<xsl:copy copy-namespaces="no">
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="initial_enrichment_second_pass"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*[not(self::gat:*|self::*:seq)]" 
			mode="initial_enrichment_second_pass">
		<xsl:copy copy-namespaces="no">
			<xsl:copy-of select="@*"/>
			<xsl:if test="ancestor::lhs">
				<xsl:attribute name="context">
					<xsl:choose>
						<xsl:when test="parent::lhs">
							<!-- outer op of term    -->
							<xsl:text>self::*</xsl:text>
						</xsl:when>
						<xsl:when test="preceding-sibling::*[not(self::*:seq)]">
							<!-- not the first non seq child -->
							<xsl:text>$</xsl:text>
							<xsl:value-of select="preceding-sibling::*[not(self::*:seq)]/@id"/>
							<xsl:text>/following-sibling::*[1]</xsl:text>
							<xsl:if test="not(self::*:var)">
								<xsl:text>[self::</xsl:text>
								<xsl:value-of select="name()"/>
								<xsl:text>]</xsl:text>
							</xsl:if>
						</xsl:when>
						<xsl:when test="not(preceding-sibling::*)">
							<!-- the first  child -->
							<xsl:text>$</xsl:text>
							<xsl:value-of select="parent::*/@id"/>
							<xsl:text>/child::*[1]</xsl:text>
							<xsl:choose>
								<xsl:when test="self::*:var">                         <!-- this leg added 16 Feb 2018 -->
									<xsl:text>[not(self::seq)]</xsl:text>
								</xsl:when>
								<xsl:otherwise>
									<xsl:text>[self::</xsl:text>
									<xsl:value-of select="name()"/>
									<xsl:text>]</xsl:text>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:when test="not(preceding-sibling::*[not(self::*:seq)])">
							<!-- the first non-seq child -->
							<xsl:text>$</xsl:text>
							<xsl:value-of select="parent::*/@id"/>
							<xsl:text>/child::</xsl:text>
							<xsl:value-of select="if (self::*:var) then '*[not(self::seq)]' else name()"/>  <!-- 16 Feb 2018 added [not(self::seq)] -->
						</xsl:when>
					</xsl:choose>
					<xsl:if test="not(following-sibling::*) and not(parent::lhs)">
						<xsl:text>[not(following-sibling::ccseq:*)]</xsl:text>
					</xsl:if>
					<xsl:if test="not(child::*) and not(self::*:var)">
						<xsl:text>[not(child::ccseq:*)]</xsl:text>
					</xsl:if>
				</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates mode="initial_enrichment_second_pass"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*:seq" mode="initial_enrichment_second_pass">
		<!--<xsl:message> second pass of seq </xsl:message>-->
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:if test="ancestor::lhs">
				<!--<xsl:message>Generating xpath </xsl:message>-->
				<xsl:attribute name="xpath">
					<xsl:text>$</xsl:text>
					<xsl:value-of select="parent::*/@id"/>
					<xsl:text>/child::ccseq:*</xsl:text>  <!-- 22:15 13 Feb 2018 -->
					<xsl:if test="preceding-sibling::*">
						<!-- not the first  child -->
						<xsl:text>[position() &gt; </xsl:text>
						<xsl:text>$</xsl:text>
						<xsl:value-of select="preceding-sibling::*[1]/@id"/>
						<xsl:text>/count(preceding-sibling::*) + 1</xsl:text>
						<xsl:text>]</xsl:text>
					</xsl:if>
					<xsl:if test="following-sibling::*[not(self::gat:type)]">
						<!-- not the last  child -->
						<xsl:text>[position() &lt; </xsl:text>
						<xsl:text>$</xsl:text>
						<xsl:value-of select="following-sibling::*[1]/@id"/>
						<xsl:text>/count(preceding-sibling::*) + 1</xsl:text>
						<xsl:text>]</xsl:text>
					</xsl:if>
				</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates mode="initial_enrichment_second_pass"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="gat:type" mode="initial_enrichment_second_pass">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:if test="ancestor::lhs">
				<xsl:attribute name="context">
					<xsl:text>$</xsl:text>
					<xsl:value-of select="parent::*/@id"/>
					<xsl:text>/gat:type</xsl:text>
				</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates mode="initial_enrichment_second_pass"/>
		</xsl:copy>
	</xsl:template>


	<!-- DEBUGGING ON 13 FEB 2018 COMMENT OUT THIS - getting in way of genertion of deep euqal test ???
	<xsl:template match="*[self::*:var][not(gat:type)]" mode="initial_enrichment_third_pass" priority="100">
		<xsl:copy>  
       <xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="initial_enrichment_third_pass"/>
			<xsl:copy-of select="(ancestor::rewriteRule|ancestor::equation|ancestor::example)/context/decl[name=current()/name]/type" />
		</xsl:copy>
	</xsl:template>
	
		<xsl:template match="*[self::*:seq][not(gat:type)]" mode="initial_enrichment_third_pass" priority="100">
		<xsl:copy>  
    	<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="initial_enrichment_third_pass"/>
			<xsl:copy-of select="(ancestor::rewriteRule|ancestor::equation|ancestor::example)/context/sequence[name=current()/name]/type" />
		</xsl:copy>
	</xsl:template>
  
  -->


	<!-- recursive step -->
	<!--
	<xsl:template match="*"
			mode="initial_enrichment_recursive"> 
		<xsl:copy copy-namespaces="no">
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="initial_enrichment_recursive"/>
		</xsl:copy>
	</xsl:template>
  -->


</xsl:transform>
