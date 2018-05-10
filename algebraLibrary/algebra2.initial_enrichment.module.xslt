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
			<!--<xsl:copy> -->
				<!--<xsl:copy-of select="namespace::*"/> -->
				<!-- <xsl:for-each select="*[not(self::hidden)]"> -->
					<xsl:call-template name="initial_enrichment">
						<xsl:with-param name="document" select="."/> <!-- was "." -->
					</xsl:call-template>
				<!-- </xsl:for-each> -->
			<!--</xsl:copy>-->
		</xsl:for-each>
	</xsl:template>


	<!-- module would begin here -->
	<xsl:template name="initial_enrichment">
		<xsl:param name="document"/>
	
		<xsl:variable name="current_state">
			<xsl:for-each select="$document">
				<xsl:copy>
					<xsl:apply-templates mode="pass_0"/>
				</xsl:copy>
			</xsl:for-each>
		</xsl:variable>
				<xsl:variable name="current_state">
			<xsl:for-each select="$current_state">
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
		<xsl:variable name="current_state">
			<xsl:for-each select="$current_state">
				<xsl:copy>
					<xsl:apply-templates mode="initial_enrichment_second_pass"/>
				</xsl:copy>
			</xsl:for-each>
		</xsl:variable>

		<xsl:for-each select="$current_state">
			<xsl:copy>
				<xsl:apply-templates mode="initial_enrichment_third_pass"/>
			</xsl:copy>
		</xsl:for-each>

	</xsl:template>
	
	<!-- pass_0 is a copy of standard include code from ER modfelling generators -->
	
	<!--
	  <xsl:template match="/">
      <xsl:copy>
         <xsl:apply-templates mode="pass_0"/>
      </xsl:copy>
   </xsl:template>
   
   -->
   
   <xsl:template match="@*|node()" mode="pass_0">
  <!-- <xsl:message>in pass zero generic <xsl:value-of select="name()"/></xsl:message>-->
      <xsl:copy>
         <xsl:apply-templates select="@*|node()" mode="pass_0"/>
      </xsl:copy>
   </xsl:template>
   
   <xsl:template match="include[not(*/self::type)]" mode="pass_0">
      <xsl:apply-templates select="document(filename)/*/*" mode="pass_0"/>
   </xsl:template>
   
   <xsl:template match="/*/include[*/self::type]" mode="pass_0">
      <xsl:variable name="temp" select="../name()"/>
      <xsl:apply-templates select="document(filename)/*[name()=$temp]/*[name()=current()/type]"
                           mode="pass_0"/>
   </xsl:template>
   
   <xsl:template match="/*/*/include[*/self::type]" mode="pass_0">
      <xsl:variable name="temp" select="../../name()"/>
      <xsl:variable name="temp2" select="../name()"/>
      <xsl:apply-templates select="document(filename)/*[name()=$temp]/*[name()=$temp2]/*[name()=current()/type]"
                           mode="pass_0"/>
   </xsl:template>
   
   <!-- end of pass_0 -->
   

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
		<xsl:copy > <!-- was copy-namespaces="no" -->
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
	
	<xsl:template match="gat:algebra" mode="initial_enrichment_second_pass" priority="1000">
	<xsl:message> in gat:algebra </xsl:message>
		<xsl:copy>  <!-- copies namespaces -->
		   <!--<xsl:copy-of select="namespace::*"/>-->
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="initial_enrichment_second_pass"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="gat:*[not(self::gat:type)]" mode="initial_enrichment_second_pass">
		<xsl:copy copy-namespaces="no">  
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="initial_enrichment_second_pass"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*[not(self::gat:*|self::*:seq)]" 
			mode="initial_enrichment_second_pass">
		<xsl:copy copy-namespaces="no"> <!-- was copy-namespaces="no" -->
			<xsl:copy-of select="@*"/>
			<xsl:if test="ancestor::lhs">
				<xsl:attribute name="selector">
					<xsl:choose>
						<xsl:when test="parent::lhs">
							<!-- outer op of term    -->
							<xsl:text>self::*</xsl:text>
						</xsl:when>
						<xsl:when test="preceding-sibling::*[not(self::*:seq)]">
							<!-- not the first non seq child -->
							<xsl:text>$</xsl:text>
							<xsl:value-of select="preceding-sibling::*[not(self::*:seq)][1]/@id"/> <!-- 8th March 2018 ***what is this many-valued?? -->
							<!-- need to take the closest non-seq preceeding sibling -->
							<!-- therefore [1] added - not actualy texted currently -->
							<xsl:text>/following-sibling::ccseq:*</xsl:text>
							<xsl:if test="preceding-sibling::*[1][not(self::*:seq)]">  <!-- made conditional 8th March 2018 -->
								<xsl:text>[1]</xsl:text>
							</xsl:if>
							<xsl:if test="not(self::*:var)">
								<xsl:text>[self::</xsl:text>
								<xsl:value-of select="name()"/>
								<xsl:text>]</xsl:text>
							</xsl:if>
							<xsl:if test="self::*:var">
								<xsl:text>[not(self::*:seq)]</xsl:text>  <!-- added 12 March 2018 -->
							</xsl:if>
						</xsl:when>
						<xsl:when test="not(preceding-sibling::*)">
							<!-- the first  child -->
							<xsl:text>$</xsl:text>
							<xsl:value-of select="parent::*/@id"/>
							<xsl:text>/child::ccseq:*[1]</xsl:text>
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
							<xsl:value-of select="if (self::*:var) then 'ccseq:*[not(self::seq)]' else name()"/>  <!-- 16 Feb 2018 added [not(self::seq)] -->
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
				<xsl:if test="following-sibling::*[not(self::gat:type)][1][self::*:seq]">
					<xsl:call-template name="generate_cardinality_attribute"/>
				</xsl:if>
				<xsl:if test="preceding-sibling::*[1][self::*:seq]">
					<xsl:call-template name="generate_startpos_attribute"/>
				</xsl:if>
			</xsl:if>
			<xsl:apply-templates mode="initial_enrichment_second_pass"/>
		</xsl:copy>
	</xsl:template>



	<xsl:template match="*:seq" name="generate_cardinality_attribute">
		<xsl:attribute name="cardinality">
			<xsl:text>(0 to count($</xsl:text>
			<xsl:choose>
				<xsl:when test="preceding-sibling::*[not(self::*:seq)]">
					<xsl:value-of select="preceding-sibling::*[not(self::*:seq)][1]/@id"/>
					<xsl:text>/following-sibling::ccseq:*))</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="../@id"/>
					<xsl:text>/count(child::ccseq:*))</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
	</xsl:template>

	<xsl:template match="*:seq" name="generate_startpos_attribute">
		<xsl:attribute name="startpos">
			<xsl:variable name="prior_anchor_subterm"
					select="preceding-sibling::*[not(self::*:seq)][1]"/>
			<xsl:if test="$prior_anchor_subterm">
				<xsl:text>$</xsl:text>
				<xsl:value-of select="$prior_anchor_subterm/@id"/>
				<xsl:text>/count(preceding-sibling::ccseq:*) + </xsl:text>
			</xsl:if>
			<xsl:text>1 + 1</xsl:text>
			<xsl:for-each select="preceding-sibling::*[not($prior_anchor_subterm)
				or 
				(count(preceding-sibling::*) &gt; count($prior_anchor_subterm/preceding-sibling::*))
				]">
				<xsl:text> + $</xsl:text>
				<xsl:value-of select="@id"/>
				<xsl:text>_cardinality</xsl:text>
			</xsl:for-each>
		</xsl:attribute>
	</xsl:template>


	<xsl:template match="gat:type" mode="initial_enrichment_second_pass">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:if test="ancestor::lhs">
				<xsl:attribute name="selector">
					<xsl:text>$</xsl:text>
					<xsl:value-of select="parent::*/@id"/>
					<xsl:text>/gat:type</xsl:text>
				</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates mode="initial_enrichment_second_pass"/>
		</xsl:copy>
	</xsl:template>


	<!-- third pass - generation of slice attribute for seqs -->
	<xsl:template match="*" mode="initial_enrichment_third_pass" >
		<xsl:copy>  
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="initial_enrichment_third_pass"/>
		</xsl:copy>
	</xsl:template>


	<xsl:template match="*:seq[not(@cardinality)]" mode="initial_enrichment_third_pass" priority="100">
		<xsl:copy>  
			<xsl:copy-of select="@*"/>
			<xsl:attribute name="slice">
				<xsl:text>$</xsl:text>
				<xsl:value-of select="parent::*/@id"/>
				<xsl:text>/child::ccseq:*</xsl:text>  <!-- 22:15 13 Feb 2018 -->
				<!-- uppercut -->
				<xsl:if test="following-sibling::*[not(self::gat:type)]">
					<!-- not the last  child -->
					<xsl:text>[position() &lt; </xsl:text>
					<xsl:text>$</xsl:text>
					<xsl:value-of select="following-sibling::*[1]/@id"/>
					<xsl:text>/count(preceding-sibling::ccseq:*) + 1</xsl:text>
					<xsl:text>]</xsl:text>
				</xsl:if>
				<!-- lowercut -->
				<xsl:apply-templates select="." mode="lowercut"/>
			</xsl:attribute>
			<xsl:apply-templates mode="initial_enrichment_third_pass"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*:seq [@cardinality]" mode="initial_enrichment_third_pass" priority="100">
		<!--<xsl:message>Generating xpath </xsl:message>-->
		<xsl:copy>  
			<xsl:copy-of select="@*"/>
			<xsl:attribute name="slice">
				<xsl:text>$</xsl:text>
				<xsl:value-of select="parent::*/@id"/>
				<xsl:text>/child::ccseq:*</xsl:text>  
				<!-- lowercut -->
				<xsl:apply-templates select="." mode="lowercut"/>
				<xsl:if test="following-sibling::*[not(self::gat:type)]">
					<!-- uppercut -->
					<xsl:text>[position() &lt;= </xsl:text>
					<xsl:text>$</xsl:text>
					<xsl:value-of select="@id"/>
					<xsl:text>_cardinality]</xsl:text>
				</xsl:if>
			</xsl:attribute>
			<xsl:apply-templates mode="initial_enrichment_third_pass"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*:seq[not(@startpos)]" mode="lowercut">
		<xsl:if test="preceding-sibling::*">
			<!-- not the first  child -->
			<xsl:text>[position() &gt; </xsl:text>
			<xsl:text>$</xsl:text>
			<xsl:value-of select="preceding-sibling::*[1]/@id"/>
			<xsl:text>/count(preceding-sibling::ccseq:*) + 1</xsl:text>
			<xsl:text>]</xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*:seq[@startpos]" mode="lowercut">
		<xsl:text>[position() &gt;= </xsl:text>
		<xsl:text>$</xsl:text>
		<xsl:value-of select="@id"/>
		<xsl:text>_startpos]</xsl:text>

	</xsl:template>





</xsl:transform>
