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
				<xsl:variable name="innerRuleWithVblsChanged" as="element(tt-rule)">
					<xsl:apply-templates select="$innerRuleCleansed" mode="postfix_variable_names"/>
				</xsl:variable>
				<xsl:variable name="innerTerm" as="element()" select="$innerRuleWithVblsChanged/tt-conclusion/lhs/*"/> 
				<xsl:variable name="innerTerm_rhs" as="element()" select="$innerRuleWithVblsChanged/tt-conclusion/rhs/*"/> 				
				<xsl:variable name="innerTermPurified" as="element()">
					<xsl:apply-templates select="$innerTerm" mode="remove_gat_annotations"/>
				</xsl:variable>
				<xsl:variable name="innerContext" as="element(context)" select="$innerRuleWithVblsChanged/context"/>

				<xsl:for-each select="//rewriteRule/tt-rule">  <!-- consider each possible outer rewrite rule -->
					<xsl:variable name="outerRuleCleansed" as="element(tt-rule)">
						<xsl:apply-templates select="." mode="cleanse_of_attributes"/> 
						<!-- added so as deep-equal in rewrite rules not fouled up -->
					</xsl:variable>
					<xsl:variable name="outerRule_lhs" as="element(lhs)" select="$outerRuleCleansed/tt-conclusion/lhs"/>
					<xsl:variable name="outerRule_rhs" as="element(rhs)" select="$outerRuleCleansed/tt-conclusion/rhs"/>
					<xsl:variable name="outerContext" as="element(context)" select="$outerRuleCleansed/context"/>
					<xsl:variable name="outer_rule_id" select="../id"/>

					<xsl:variable name="outerTerm" as="element()" select="$outerRule_lhs/*"/>

					<xsl:variable name="outerTermPurified" as="element()">
						<xsl:apply-templates select="$outerTerm" mode="remove_gat_annotations"/>
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
							<xsl:apply-templates select="$innerTerm" mode="substitution">  
								<xsl:with-param name="substitutions" select="substitution"/> 
							</xsl:apply-templates>
						</xsl:variable>
						<xsl:variable name="innerTermSpecialisedText">
							<xsl:apply-templates select="$innerTermSpecialised" mode="text"/>
						</xsl:variable>
						<xsl:variable name="innerTerm_lhs_in_context" as="element(term)">
							<xsl:apply-templates select="stub"  mode="fill_in_stub">
								<xsl:with-param name="subterm" select="$innerTerm"/>
							</xsl:apply-templates>
						</xsl:variable>
						<xsl:variable name="innerTerm_lhs_in_context_specialised" as="element(term)">
							<xsl:apply-templates select="$innerTerm_lhs_in_context" mode="substitution">
								<xsl:with-param name="substitutions" select="substitution"/>
							</xsl:apply-templates>
						</xsl:variable>

						<xsl:variable name="innerTerm_lhs_in_context_specialised_text" >  <!-- how to type this ?-->
							<xsl:apply-templates select="$innerTerm_lhs_in_context_specialised" mode="text"/>
						</xsl:variable>
						<xsl:variable name="outerTermSpecialised" as="element()">
							<xsl:apply-templates select="$outerTermPurified" mode="substitution"> <!-- changed to purified because need to annotate with types after substitution -->
								<xsl:with-param name="substitutions" select="substitution"/> 
							</xsl:apply-templates>
						</xsl:variable>
						<xsl:variable name="outerTermSpecialisedText">
							<xsl:apply-templates select="$outerTermSpecialised" mode="text"/>
						</xsl:variable>
						<xsl:variable name="firstCutDiamondContextInitial" as="element(context)">
							<gat:context>
								<!-- before 3rd April 2018 was 
								<xsl:call-template name="merge_declarations">
									<xsl:with-param name="result_declarations_so_far" select="()"/>
									<xsl:with-param name="lhs_declarations" 
									                select="$outerContextSubstituted/*
													 [(some $var_or_seq 
										               in $outerTermSpecialised/descendant::*[self::*:var|self::*:seq]
										               satisfies $var_or_seq/name = ./name)]"/>
									<xsl:with-param name="rhs_declarations" 
									                select="$innerContextSubstituted/*
													        [(some $var_or_seq 
										                      in $outerTermSpecialised/descendant::*[self::*:var|self::*:seq] 
										                      satisfies $var_or_seq/name = ./name)]"/>
								</xsl:call-template>
								but now is -->
								<xsl:call-template name="merge_declarations">
									<xsl:with-param name="result_declarations_so_far" select="()"/>
									<xsl:with-param name="lhs_declarations" 
											select="$outerContextSubstituted/*"/>
									<xsl:with-param name="rhs_declarations" 
											select="$innerContextSubstituted/*"/>
								</xsl:call-template>
							</gat:context>
						</xsl:variable>
						<!--
						<xsl:variable name="firstCutDiamondContext" as="element(context)">    
							<xsl:call-template name="recursive_rewrite">
								<xsl:with-param name="document" select="$firstCutDiamondContextInitial"/>
							</xsl:call-template>
						</xsl:variable>
						<xsl:variable name="firstCutTopOfDiamondRule" as="element(tT-rule)">
							<tT-rule>
								<xsl:copy-of select="$firstCutDiamondContext"/>
								<tT-conclusion>
									<term>
										<xsl:copy-of select="$outerTermSpecialised"/>
									</term>
								</tT-conclusion>							
							</tT-rule>
						</xsl:variable>
						-->
						<!-- OUTPUT -->
						<gat:diamond xmlns="http://www.entitymodelling.org/theory/contextualcategory/sequence">
							<gat:from>
								<gat:outer>
									<gat:id><xsl:value-of select="$outer_rule_id"/></gat:id>
									<gat:term>
										<!--<xsl:copy-of select="$outerTerm" />-->
										<xsl:apply-templates select="$outerTerm" mode="text"/>
									</gat:term>
									<gat:context>
										<!-- <xsl:copy-of select="$outerContext"/> -->
										<xsl:apply-templates select="$outerContext" mode="text"/>
									</gat:context>
									<gat:substitution_text> 
										<xsl:apply-templates  select="substitution/subject/substitute" mode="text"/>
									</gat:substitution_text>
									<!--
									<gat:substitution> 
										<xsl:copy-of  select="substitution/subject/substitute"/>
									</gat:substitution>
									-->
									
									<gat:contextsubstituted>
										<!--<xsl:copy-of select="$outerContextSubstituted"/>-->  <!-- MAKE INTO FIRST PASS XML. SECOND PASS TEXT OR EVEN tex -->
										<xsl:apply-templates select="$outerContextSubstituted" mode="text"/>  
									</gat:contextsubstituted>
									<gat:term_specialised>
										<!--<xsl:copy-of select="$outerTermSpecialised"/>-->
										<xsl:apply-templates select="$outerTermSpecialised" mode="text"/>
									</gat:term_specialised>
								</gat:outer>
								<gat:inner>
									<gat:id><xsl:value-of select="$inner_rule_id"/></gat:id>
									<gat:term><xsl:apply-templates select="$innerTerm" mode="text"/></gat:term>                   
									<gat:context>
										<!-- <xsl:copy-of select="$innerContext"/> -->
										<xsl:apply-templates select="$innerContext" mode="text"/>
									</gat:context>
									<gat:substitution>
										<xsl:apply-templates  select="substitution/target/substitute" mode="text"/>
									</gat:substitution>
									<gat:contextsubstituted>
										<!--<xsl:copy-of select="$innerContextSubstituted"/>-->
										<xsl:apply-templates select="$innerContextSubstituted" mode="text"/>
									</gat:contextsubstituted>
									<gat:term_specialised>
										<!--<xsl:copy-of select="$innerTermSpecialised"/>-->
										<xsl:apply-templates select="$innerTermSpecialised" mode="text"/>
									</gat:term_specialised>
									<gat:term_in_context_specialised>
										<xsl:apply-templates select="$innerTerm_lhs_in_context_specialised" mode="text"/>
									</gat:term_in_context_specialised>
								</gat:inner>
							</gat:from>
							<gat:diamond_context_text>
								<xsl:apply-templates select="$firstCutDiamondContextInitial" mode="text"/> 
							</gat:diamond_context_text> 
							<gat:top_of_diamond_text>
								<xsl:comment>a.k.a.outerTermSpecialised</xsl:comment>
								<xsl:apply-templates select="$outerTermSpecialised" mode="text"/>
							</gat:top_of_diamond_text>
							<gat:diamond_context>
								<xsl:copy-of select="$firstCutDiamondContextInitial"/> 
							</gat:diamond_context> 
							<gat:top_of_diamond>
								<xsl:copy-of select="$outerTermSpecialised"/>
							</gat:top_of_diamond>
						</gat:diamond>
					</xsl:for-each> <!-- end outer term -->
				</xsl:for-each> <!-- end inner term -->
			</xsl:for-each>
		</xsl:copy>
	</xsl:template>


</xsl:transform>
