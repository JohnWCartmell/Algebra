<xsl:transform version="2.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:gat              ="http://www.entitymodelling.org/theory/generalisedalgebraictheory"
		xpath-default-namespace="http://www.entitymodelling.org/theory/generalisedalgebraictheory"	   
		xmlns="http://www.entitymodelling.org/theory/generalisedalgebraictheory"
		exclude-result-prefixes="xs gat">

	<xsl:strip-space elements="*"/> 

	<xsl:template match = "/" mode="filter_roughcut_diamonds">
		<xsl:apply-templates mode="filter_roughcut_diamonds"/>
	</xsl:template>

	<xsl:template match="diamond" mode="filter_roughcut_diamonds">
		<xsl:copy>
		<xsl:message>Considering roughcut diamond: <xsl:value-of select="identity"/></xsl:message>
			<xsl:copy-of select="namespace::*"/>			
			<xsl:copy-of select="*[not(self::top_of_diamond)][not(self::diamond_context)]"/>   <!-- TEMPORARY FILTER -->
			<xsl:variable name="top_of_diamond" as="element()" select="type_corrected/top_of_diamond"/>
			<xsl:variable name="more_general_tops" as="element(more_general_top)*">	
				<xsl:for-each select="(preceding-sibling::*|following-sibling::*)
						[self::gat:diamond]
						[from/outer/id = current()/from/outer/id]
						[from/inner/id = current()/from/inner/id]
						">
					<xsl:variable name="candidate_identity" select="identity"/>
					<xsl:message>... is <xsl:value-of select="$candidate_identity"/> more general? </xsl:message>
					<xsl:variable name="how_specialises" as="element(substitution)*">
						<xsl:for-each select="type_corrected/top_of_diamond/*">
							<xsl:call-template name="changeTargetVariablesAndSpecialiseTerm">
								<xsl:with-param name="targetTerm" select="$top_of_diamond/*"/>
							</xsl:call-template>
						</xsl:for-each>
					</xsl:variable>
					<xsl:for-each select="$how_specialises">
						<xsl:if test="count(target/substitute)=0">
							<gat:more_general_top>
								<gat:diamond-id><xsl:value-of select="$candidate_identity"/></gat:diamond-id>
								<xsl:copy-of select="."/>
							</gat:more_general_top>
						</xsl:if>
					</xsl:for-each>
				</xsl:for-each>
			</xsl:variable>
			<xsl:message><xsl:copy-of select="$more_general_tops"/></xsl:message>
			<xsl:if test="$more_general_tops">
				<xsl:variable name="most_subs" select="max($more_general_tops/substitution/count(subject/substitute))"/>
				<xsl:message >**** most subs is <xsl:value-of select="$most_subs"/></xsl:message>
				<gat:most_generalising_tops>
					<xsl:for-each select="$more_general_tops[substitution/count(subject/substitute)=$most_subs]">
						<xsl:copy-of select="gat:diamond-id"/>
						<substitution>
							<subject><xsl:apply-templates select="substitution/subject" mode="text"/></subject>
							<target><xsl:apply-templates select="substitution/target" mode="text"/></target>
						</substitution>
					</xsl:for-each>
				</gat:most_generalising_tops>
			</xsl:if>
		</xsl:copy>
	</xsl:template>

	<xsl:template name="changeTargetVariablesAndSpecialiseTerm">
		<xsl:param name="targetTerm" as="element()"/>
		<xsl:variable name="targetTermWithVblsChanged" as="element()">
			<xsl:apply-templates select="$targetTerm" mode="prefix_variable_names"/>
		</xsl:variable>
		<xsl:call-template name="unifyTerms">
			<xsl:with-param name="subjectTerm" select="."/>
			<xsl:with-param name="targetTerm" select="$targetTermWithVblsChanged"/>
		</xsl:call-template>
	</xsl:template>

</xsl:transform>
