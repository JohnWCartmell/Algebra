<xsl:transform version="2.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:gat              ="http://www.entitymodelling.org/theory/generalisedalgebraictheory"
		xpath-default-namespace="http://www.entitymodelling.org/theory/generalisedalgebraictheory"	   
		xmlns="http://www.entitymodelling.org/theory/generalisedalgebraictheory"
		exclude-result-prefixes="xs gat">

	<xsl:strip-space elements="*"/> 


	<xsl:template match = "/" mode="prepare_roughcut_diamonds">
		<xsl:apply-templates mode="prepare_roughcut_diamonds"/>
	</xsl:template>

	<xsl:template match="algebra" mode="prepare_roughcut_diamonds">
		<xsl:copy>
			<xsl:copy-of select="namespace::*"/>
			<xsl:variable name="algebra_name" select="name"/>
			<xsl:for-each select="rewriteRule/tt-rule"> 
				<xsl:variable name="inner_rule_id" select="../id"/>
				<xsl:message>Inner rule <xsl:value-of select="$inner_rule_id"/> </xsl:message> 
				<xsl:variable name="innerRuleCleansed" as="element(tt-rule)">
					<xsl:apply-templates select="." mode="cleanse_of_attributes"/> 
					<!-- added so as deep-equal in rewrite rules not fouled up -->
				</xsl:variable>
				<!--
				<xsl:variable name="innerRuleWithVblsChanged" as="element(tt-rule)">
					<xsl:apply-templates select="$innerRuleCleansed" mode="postfix_variable_names"/>
				</xsl:variable>
				-->
				<xsl:variable name="innerTerm" as="element()" select="$innerRuleCleansed/tt-conclusion/lhs/*"/> 
				<xsl:variable name="innerReduction" as="element()" select="$innerRuleCleansed/tt-conclusion/rhs/*"/> 				
				<xsl:variable name="innerTermPurified" as="element()">
					<xsl:apply-templates select="$innerTerm" mode="remove_gat_annotations"/>
				</xsl:variable>
				<xsl:variable name="innerReduction_purified" as="element()">
					<xsl:apply-templates select="$innerReduction" mode="remove_gat_annotations"/>
				</xsl:variable>
				<xsl:variable name="innerContext" as="element(context)">
					<xsl:apply-templates select="$innerRuleCleansed/context" mode="remove_gat_annotations"/>
				</xsl:variable>

				<xsl:for-each select="../../rewriteRule">  <!-- consider each possible outer rewrite rule -->
					<xsl:variable name="outerRuleCleansed" as="element(tt-rule)">
						<xsl:apply-templates select="tt-rule" mode="cleanse_of_attributes"/> 
						<!-- added so as deep-equal in rewrite rules not fouled up -->
					</xsl:variable>
					<xsl:variable name="outerRuleWithVblsChanged" as="element(tt-rule)">
						<xsl:apply-templates select="$outerRuleCleansed" mode="postfix_variable_names"/>
					</xsl:variable>
					<xsl:variable name="outerTerm" as="element()" select="$outerRuleWithVblsChanged/tt-conclusion/lhs/*"/>
					<xsl:variable name="outerReduction" as="element()" select="$outerRuleWithVblsChanged/tt-conclusion/rhs/*"/>
					<xsl:variable name="outerContext" as="element(context)">
						<xsl:apply-templates select="$outerRuleWithVblsChanged/context" mode="remove_gat_annotations"/>
					</xsl:variable>
					<xsl:variable name="outer_rule_id" select="id"/>
					<xsl:variable name="outerTermPurified" as="element()">
						<xsl:apply-templates select="$outerTerm" mode="remove_gat_annotations"/>
					</xsl:variable>
					<xsl:variable name="outerReduction_purified" as="element()">
						<xsl:apply-templates select="$outerReduction" mode="remove_gat_annotations"/>
					</xsl:variable>
					<xsl:variable name="top_level_stub" as="element()">
						<point/>
					</xsl:variable>
					<xsl:variable name="results" as="element(result)*">
						<xsl:apply-templates select="$outerTermPurified" mode="get_instances_of">
							<xsl:with-param name="targetTerm" select="$innerTermPurified"/>
							<xsl:with-param name="stub" select="$top_level_stub"/>
						</xsl:apply-templates>
					</xsl:variable>
					<xsl:for-each select="$results">
						<xsl:variable name="diamond_identity" select="concat($inner_rule_id,'-',$outer_rule_id,'-',position())"/>
						<xsl:variable name="innerContextSubstituted" as="element(context)">
							<xsl:apply-templates select="$innerContext" mode="substitution">
								<xsl:with-param name="substitutions" select="substitution"/>  
							</xsl:apply-templates>
						</xsl:variable>             
						<xsl:variable name="outerContextSubstituted" as="element(context)">
							<xsl:apply-templates select="$outerContext" mode="substitution">
								<xsl:with-param name="substitutions" select="substitution"/>
							</xsl:apply-templates>
						</xsl:variable>
						<xsl:variable name="innerTermSpecialised" as="element()">
							<xsl:apply-templates select="$innerTermPurified" mode="substitution">  
								<xsl:with-param name="substitutions" select="substitution"/> 
							</xsl:apply-templates>
						</xsl:variable>
						<xsl:variable name="innerTermSpecialisedText">
							<xsl:apply-templates select="$innerTermSpecialised" mode="text"/>
						</xsl:variable>
						<xsl:variable name="innerTerm_in_stub" as="element(term)">
							<xsl:apply-templates select="stub"  mode="fill_in_stub">
								<xsl:with-param name="subterm" select="$innerTermPurified"/>
							</xsl:apply-templates>
						</xsl:variable>
						<xsl:variable name="innerTerm_in_stub_specialised" as="element(term)">
							<xsl:apply-templates select="$innerTerm_in_stub" mode="substitution">
								<xsl:with-param name="substitutions" select="substitution"/>
							</xsl:apply-templates>
						</xsl:variable>
						<xsl:variable name="innerTerm_in_stub_specialised_text" >  <!-- how to type this ?-->
							<xsl:apply-templates select="$innerTerm_in_stub_specialised" mode="text"/>
						</xsl:variable>
						<xsl:variable name="innerReduction_in_stub" as="element(term)">
							<xsl:apply-templates select="stub"  mode="fill_in_stub">
								<xsl:with-param name="subterm" select="$innerReduction_purified"/>
							</xsl:apply-templates>
						</xsl:variable>
						<xsl:variable name="right_reduction" as="element(term)">
							<gat:term>
								<xsl:apply-templates select="$innerReduction_in_stub/*" mode="substitution">
									<xsl:with-param name="substitutions" select="substitution"/>
								</xsl:apply-templates>
							</gat:term>
						</xsl:variable>
						<xsl:variable name="outerTermSpecialised" as="element()">
							<xsl:apply-templates select="$outerTermPurified" mode="substitution"> <!-- changed to purified because need to annotate with types after substitution -->
								<xsl:with-param name="substitutions" select="substitution"/> 
							</xsl:apply-templates>
						</xsl:variable>
						<xsl:variable name="outerTermSpecialised_text">
							<xsl:apply-templates select="$outerTermSpecialised" mode="text"/>
						</xsl:variable>
						<xsl:variable name="firstCutDiamondContextInitial" as="element(context)">
							<gat:context>
								<xsl:call-template name="merge_declarations">
									<xsl:with-param name="result_declarations_so_far" select="()"/>
									<xsl:with-param name="lhs_declarations" 
											select="$outerContextSubstituted/*"/>
									<xsl:with-param name="rhs_declarations" 
											select="$innerContextSubstituted/*"/>
								</xsl:call-template>
							</gat:context>
						</xsl:variable>
						<xsl:variable name="left_reduction" as="element(term)">
							<gat:term>
								<xsl:apply-templates select="$outerReduction_purified" mode="substitution">
									<xsl:with-param name="substitutions" select="substitution"/>  
								</xsl:apply-templates>
							</gat:term>
						</xsl:variable>
						<!-- OUTPUT -->
						<gat:diamond xmlns="http://www.entitymodelling.org/theory/contextualcategory/sequence">
							<gat:identity><xsl:value-of select="$diamond_identity"/></gat:identity>
							<gat:from>
								<gat:outer>
									<gat:id><xsl:value-of select="$outer_rule_id"/></gat:id>
									<gat:term>
										<xsl:apply-templates select="$outerTermPurified" mode="text"/>
									</gat:term>
									<gat:context>
										<xsl:apply-templates select="$outerContext" mode="text"/> 
									</gat:context>
									<gat:substitution> 
										<xsl:apply-templates  select="substitution/subject/substitute" mode="text"/>
									</gat:substitution>
									<gat:contextsubstituted>
										<xsl:apply-templates select="$outerContextSubstituted" mode="text"/>
									</gat:contextsubstituted>
									<gat:term_specialised>
										<xsl:apply-templates select="$outerTermSpecialised" mode="text"/>
									</gat:term_specialised>
									<gat:left_reduction>
										<xsl:copy-of select="$left_reduction"/>
									</gat:left_reduction>
								</gat:outer>
								<gat:inner>
									<gat:id><xsl:value-of select="$inner_rule_id"/></gat:id>
									<gat:term>
										<xsl:apply-templates select="$innerTermPurified" mode="text"/>
									</gat:term>                   
									<gat:context>
										<xsl:apply-templates select="$innerContext" mode="text"/>
									</gat:context>
									<gat:substitution> 
										<xsl:apply-templates  select="substitution/target/substitute" mode="text"/>
									</gat:substitution>
									<gat:stub>
										<xsl:apply-templates  select="stub"  mode="text"/>
									</gat:stub>
									<gat:contextsubstituted>
										<xsl:apply-templates select="$innerContextSubstituted" mode="text"/>
									</gat:contextsubstituted>
									<gat:term_specialised>
										<xsl:apply-templates select="$innerTermSpecialised" mode="text"/>
									</gat:term_specialised>
									<gat:term_in_stub_specialised>
										<xsl:apply-templates select="$innerTerm_in_stub_specialised" mode="text"/>
									</gat:term_in_stub_specialised>
									<gat:right_reduction>
										<xsl:copy-of select="$right_reduction"/>
									</gat:right_reduction>
								</gat:inner>
							</gat:from>
							<xsl:if test="not($outerTermSpecialised_text=$innerTerm_in_stub_specialised_text)">
								<gat:OUT-OF-SPEC/>
							</xsl:if>
							<gat:roughcut>
								<gat:context>
									<xsl:copy-of select="$firstCutDiamondContextInitial/*"/> 
								</gat:context> 
								<gat:top_of_diamond>
									<xsl:copy-of select="$outerTermSpecialised"/>
								</gat:top_of_diamond>
							</gat:roughcut>
						</gat:diamond>
					</xsl:for-each> <!-- end outer term -->
				</xsl:for-each> <!-- end inner term -->
			</xsl:for-each>
		</xsl:copy>
	</xsl:template>


</xsl:transform>
