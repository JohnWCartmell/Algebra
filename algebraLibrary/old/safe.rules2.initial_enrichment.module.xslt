<!-- 
Description
 This is an  initial enrichment that applies to a set of rules.
 
 -->

<xsl:transform version="2.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:trm="http://www.entitymodelling.org/theory/term"
		xmlns:typ="http://www.entitymodelling.org/theory/type"
		xpath-default-namespace="http://www.entitymodelling.org/theory/term" 	   
		xmlns="http://www.entitymodelling.org/theory/term" >

	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

	<xsl:template match="/">
		<xsl:message> at root</xsl:message>
		<xsl:call-template name="initial_enrichment">
			<xsl:with-param name="document" select="."/>
		</xsl:call-template>
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
					<xsl:apply-templates mode="initial_enrichment_first_pass"/>
				</xsl:copy>
			</xsl:for-each>
		</xsl:variable>

		<xsl:for-each select="$current_state">
			<xsl:copy>
				<xsl:apply-templates mode="initial_enrichment_second_pass"/>
			</xsl:copy>
		</xsl:for-each>

		<!--
    <xsl:call-template name="initial_enrichment_recursive">
      <xsl:with-param name="interim" select="$current_state"/>
    </xsl:call-template>
    -->
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
			mode="initial_enrichment_first_pass"> 
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="initial_enrichment_first_pass"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="algebra|name|id" mode="initial_enrichment_first_pass">
		<xsl:copy>
			<xsl:apply-templates mode="initial_enrichment_first_pass"/>
		</xsl:copy>
	</xsl:template>



	<xsl:template match="*[not(self::algebra|self::name|self::id|self::lhs|self::rhs|self::var|self::seq)]" mode="initial_enrichment_first_pass">
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

	<xsl:template match="var" mode="initial_enrichment_first_pass">
		<xsl:copy>
			<xsl:if test="ancestor::lhs">
				<xsl:attribute name="id" select="concat(
					.,'_',
					count(ancestor-or-self::*[ancestor::lhs]/preceding-sibling::*/descendant-or-self::var[.=current()/.])+1
					)"/>
			</xsl:if>
			<xsl:apply-templates mode="initial_enrichment_first_pass"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="seq" mode="initial_enrichment_first_pass">
		<xsl:copy>
			<xsl:if test="ancestor::lhs">
				<xsl:attribute name="id" select="concat(
					.,'_',
					count(ancestor-or-self::*[ancestor::lhs]/preceding-sibling::*/descendant-or-self::seq[.=current()/.])+1
					)"/>
			</xsl:if>
			<xsl:apply-templates mode="initial_enrichment_first_pass"/>
		</xsl:copy>
	</xsl:template>


	<xsl:template match="rewriteRule" mode="initial_enrichment_first_pass">
		<xsl:copy>
			<xsl:attribute name="test" select="'iamhere'"/>
			<xsl:apply-templates mode="initial_enrichment_first_pass"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="lhs" mode="initial_enrichment_first_pass">
		<xsl:copy>
			<xsl:apply-templates mode="initial_enrichment_first_pass"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="rhs" mode="initial_enrichment_first_pass">
		<xsl:copy>
			<xsl:apply-templates mode="initial_enrichment_first_pass"/>
		</xsl:copy>
	</xsl:template>


<!--	<xsl:template match="algebra|name|id" mode="initial_enrichment_second_pass"> -->
<xsl:template match="*" mode="initial_enrichment_second_pass">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="initial_enrichment_second_pass"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*[not(self::algebra|self::name|self::id|self::lhs|self::rhs|self::seq)]" 
			mode="initial_enrichment_second_pass">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:if test="ancestor::lhs">
				<xsl:attribute name="context">
					<xsl:choose>
						<xsl:when test="parent::lhs">
							<!-- outer op of term    -->
							<xsl:text>self::*</xsl:text>
						</xsl:when>
						<xsl:when test="preceding-sibling::*[not(self::seq)]">
							<!-- not the first non seq child -->
							<xsl:text>$</xsl:text>
							<xsl:value-of select="preceding-sibling::*[not(self::seq)]/@id"/>
							<xsl:text>/following-sibling::*[1]</xsl:text>
							<xsl:if test="not(self::var)">
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
							<xsl:if test="not(self::var)">
								<xsl:text>[self::</xsl:text>
								<xsl:value-of select="name()"/>
								<xsl:text>]</xsl:text>
							</xsl:if>
						</xsl:when>
						<xsl:when test="not(preceding-sibling::*[not(self::seq)])">
							<!-- the first non-seq child -->
							<xsl:text>$</xsl:text>
							<xsl:value-of select="parent::*/@id"/>
							<xsl:text>/child::</xsl:text>
							<xsl:value-of select="if (self::var) then '*' else name()"/>
						</xsl:when>
					</xsl:choose>
					<xsl:if test="not(following-sibling::*) and not(parent::lhs)">
						<xsl:text>[not(following-sibling::*)]</xsl:text>
					</xsl:if>
					<xsl:if test="not(child::*) and not(self::var)">
						<xsl:text>[not(child::*)]</xsl:text>
					</xsl:if>
				</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates mode="initial_enrichment_second_pass"/>
		</xsl:copy>
	</xsl:template>


	<xsl:template match="seq" mode="initial_enrichment_second_pass">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:if test="ancestor::lhs">
				<xsl:attribute name="xpath">
					<xsl:text>$</xsl:text>
					<xsl:value-of select="parent::*/@id"/>
					<xsl:text>/child::*</xsl:text>
					<xsl:if test="preceding-sibling::*">
						<!-- not the first  child -->
						<xsl:text>[position() &gt; </xsl:text>
						<xsl:text>$</xsl:text>
						<xsl:value-of select="preceding-sibling::*[1]/@id"/>
						<xsl:text>/count(preceding-sibling::*) + 1</xsl:text>
						<xsl:text>]</xsl:text>
					</xsl:if>
					<xsl:if test="following-sibling::*">
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


	<xsl:template match="rewriteRule" mode="initial_enrichment_second_pass">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="initial_enrichment_second_pass"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="lhs" mode="initial_enrichment_second_pass">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="initial_enrichment_second_pass"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="rhs" mode="initial_enrichment_second_pass">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="initial_enrichment_second_pass"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*" mode="initial_enrichment_third_pass">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="initial_enrichment_third_pass"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*[self::var][not(typ:type)]" mode="initial_enrichment_third_pass">
		<xsl:copy>  
			<xsl:apply-templates mode="initial_enrichment_third_pass"/>
			<typ:type>
				<xsl:value-of select="(ancestor::rewriteRule|ancestor::equation)/context/decl[name=current()/name]/type"/>
			</typ:type>
		</xsl:copy>
	</xsl:template>


	<!-- recursive step -->

	<xsl:template match="*"
			mode="initial_enrichment_recursive"> 
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="initial_enrichment_recursive"/>
		</xsl:copy>
	</xsl:template>


</xsl:transform>
