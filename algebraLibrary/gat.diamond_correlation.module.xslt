<xsl:transform version="2.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:gat              ="http://www.entitymodelling.org/theory/generalisedalgebraictheory"
		xpath-default-namespace="http://www.entitymodelling.org/theory/generalisedalgebraictheory"	   
		xmlns="http://www.entitymodelling.org/theory/generalisedalgebraictheory"
		exclude-result-prefixes="xs gat">

	<xsl:strip-space elements="*"/> 

	<xsl:template match = "*" mode="correlate_diamonds">
		<xsl:copy>
			<xsl:apply-templates mode="correlate_diamonds"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="diamond[type_corrected/ABANDONED]" mode="correlate_diamonds">
	</xsl:template>

	<xsl:template match="diamond[not(type_corrected/ABANDONED)]" mode="correlate_diamonds">
		<xsl:copy>
			<xsl:message>Considering roughcut diamond: <xsl:value-of select="identity"/></xsl:message>
			<xsl:copy-of select="namespace::*"/>			
			<xsl:copy-of select="*[not(self::top_of_diamond)][not(self::diamond_context)]"/>   <!-- TEMPORARY FILTER -->
			<xsl:variable name="top_of_diamond" as="element(term)" select="type_corrected/top_of_diamond/tT-rule/tT-conclusion/term"/>
			<xsl:variable name="subject_right_reduction_text">
				<xsl:apply-templates select="type_corrected/right_reduction" mode="text"/>
			</xsl:variable>
			<xsl:variable name="subject_left_reduction_text">
				<xsl:apply-templates select="type_corrected/left_reduction" mode="text"/>
			</xsl:variable>
			<xsl:variable name="more_general_tops" as="element(more_general_top)*">	
				<xsl:for-each select="(preceding-sibling::*|following-sibling::*)
						[self::gat:diamond]
						[not(type_corrected/ABANDONED)]
						[from_outer_id = current()/from_outer_id]
						[from_inner_id = current()/from_inner_id]
						">
					<xsl:variable name="candidate_identity" select="identity"/>
					<xsl:message>... is <xsl:value-of select="$candidate_identity"/> more general? </xsl:message>
					<xsl:variable name="how_specialises" as="element(gat:substitution)*">
						<xsl:for-each select="type_corrected/top_of_diamond/tT-rule/tT-conclusion/term/*">
							<xsl:call-template name="changeTargetVariablesAndSpecialiseTerm">
								<xsl:with-param name="targetTerm" select="$top_of_diamond/*"/>
							</xsl:call-template>
						</xsl:for-each>
					</xsl:variable>
					<xsl:variable name="candidate_more_general_right_reduction" as="element(right_reduction)" select="type_corrected/right_reduction"/>
					<xsl:variable name="candidate_more_general_left_reduction" as="element(left_reduction)" select="type_corrected/left_reduction"/>
					<xsl:for-each select="$how_specialises">
						<xsl:if test="not(count(target/substitute)=0)">
							<xsl:message terminate="yes"> Number of target substuitutions is <xsl:value-of select="count(target/substitute)"/> </xsl:message>
						</xsl:if>
						<gat:more_general_top>
							<gat:diamond-id><xsl:value-of select="$candidate_identity"/></gat:diamond-id>
							<xsl:copy-of select="."/>
							<xsl:apply-templates select="$candidate_more_general_right_reduction" mode="substitution">
								<xsl:with-param name="substitutions" select="."/>
							</xsl:apply-templates>
							<xsl:apply-templates select="$candidate_more_general_left_reduction" mode="substitution">
								<xsl:with-param name="substitutions" select="."/>
							</xsl:apply-templates>
						</gat:more_general_top>
					</xsl:for-each>
				</xsl:for-each>
			</xsl:variable>

			<xsl:message>More general tops right reduction:<xsl:copy-of select="$more_general_tops/right_reduction"/></xsl:message>
			<xsl:if test="$more_general_tops">
				<xsl:variable name="most_subs" select="max($more_general_tops/substitution/count(subject/substitute))"/>
				<xsl:message >**** most subs is <xsl:value-of select="$most_subs"/></xsl:message>

				<gat:most_generalising_tops>
					<xsl:for-each select="$more_general_tops[substitution/count(subject/substitute)=$most_subs]">
						<gat:most_generalising_top>
							<xsl:variable name="candidate_more_general_right_reduction_text">
								<xsl:apply-templates select="gat:right_reduction" mode="text"/>
							</xsl:variable>
							<xsl:variable name="candidate_more_general_left_reduction_text">
								<xsl:apply-templates select="gat:left_reduction" mode="text"/>
							</xsl:variable>
							<xsl:copy-of select="gat:diamond-id"/>
							<xsl:copy-of select="gat:substitution"/>
							<xsl:copy-of select="gat:left_reduction"/>
							<xsl:copy-of select="gat:right_reduction"/>
							<xsl:if test="$candidate_more_general_right_reduction_text=$subject_right_reduction_text">
								<gat:right_reduction_more_general/>
							</xsl:if>
							<xsl:if test="$candidate_more_general_left_reduction_text=$subject_left_reduction_text">
								<gat:left_reduction_more_general/>
							</xsl:if>
						</gat:most_generalising_top>
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
		<xsl:variable name="how_specialises" as="element(gat:substitution)*">
			<xsl:call-template name="unifyTerms">
				<xsl:with-param name="subjectTerm" select="."/>
				<xsl:with-param name="targetTerm" select="$targetTermWithVblsChanged"/>
				<xsl:with-param name="specialise" select="true()"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:apply-templates select="$how_specialises" mode="unprefix_variable_names"/>
	</xsl:template>

</xsl:transform>
