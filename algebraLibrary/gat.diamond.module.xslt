<xsl:transform version="2.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:gat              ="http://www.entitymodelling.org/theory/generalisedalgebraictheory"
		xmlns:ccseqfun            ="http://www.entitymodelling.org/theory/contextualcategory/sequence/fun"
		xpath-default-namespace="http://www.entitymodelling.org/theory/generalisedalgebraictheory"	   
		xmlns="http://www.entitymodelling.org/theory/generalisedalgebraictheory"
		exclude-result-prefixes="xs gat">

	<xsl:strip-space elements="*"/> 

	<!-- gat.diamond.module.xslt -->
	<!-- Contains templates with the following modes:
            prepare_roughcut_diamonds
            type_correction
            correlate_diamonds
            diamond_filter
            grow_diamonds
			correlate_rewrites
			rewrite_filter
    -->			



    <!-- prepare_roughcut_diamonds also normalises rhsides of existing rewriteRules -->
	<xsl:template match = "/" mode="prepare_roughcut_diamonds">
		<xsl:apply-templates mode="prepare_roughcut_diamonds"/>
	</xsl:template>

	<xsl:template match="algebra" mode="prepare_roughcut_diamonds">
		<xsl:copy>
			<xsl:copy-of select="namespace::*"/>
			<xsl:copy-of select="gat:name|gat:namespace"/>
			<xsl:variable name="algebra_name" select="name"/>
            <xsl:apply-templates select="rewriteRule" mode="normalise_rhs"/>
			<xsl:for-each select="rewriteRule/tt-rule"> 
				<xsl:variable name="inner_rule_id" select="../id"/>
				<xsl:message>Inner rule <xsl:value-of select="$inner_rule_id"/> </xsl:message> 
				<xsl:variable name="innerRuleCleansed" as="element(tt-rule)">
					<xsl:apply-templates select="." mode="cleanse_of_attributes"/> 
					<!-- added so as deep-equal in rewrite rules not fouled up -->
				</xsl:variable>
				<xsl:variable name="innerRuleExpanded" as="element(tt-rule)">
					<xsl:apply-templates select="$innerRuleCleansed" mode="expand_metavariables"/>
				</xsl:variable>
				<xsl:variable name="innerTerm" as="element()" select="$innerRuleExpanded/tt-conclusion/lhs/*"/> 
				<xsl:variable name="innerReduction" as="element()" select="$innerRuleExpanded/tt-conclusion/rhs/*"/> 
				<xsl:variable name="innerContext" as="element(context)">
					<xsl:copy-of select="$innerRuleExpanded/context"/>
				</xsl:variable>

				<xsl:for-each select="../../rewriteRule">  <!-- consider each possible outer rewrite rule -->
					<xsl:variable name="outerRuleCleansed" as="element(tt-rule)">
						<xsl:apply-templates select="tt-rule" mode="cleanse_of_attributes"/> 
						<!-- added so as deep-equal in rewrite rules not fouled up -->
					</xsl:variable>
					<xsl:variable name="outerRuleExpanded" as="element(tt-rule)">
						<xsl:apply-templates select="$outerRuleCleansed" mode="expand_metavariables"/>
					</xsl:variable>
					<xsl:variable name="outerRuleWithVblsChanged" as="element(tt-rule)">
						<xsl:apply-templates select="$outerRuleExpanded" mode="postfix_variable_names"/>
					</xsl:variable>
					<xsl:variable name="outerTerm" as="element()" select="$outerRuleWithVblsChanged/tt-conclusion/lhs/*"/>
					<xsl:variable name="outerReduction" as="element()" select="$outerRuleWithVblsChanged/tt-conclusion/rhs/*"/>
					<xsl:variable name="outerContext" as="element(context)" select="$outerRuleWithVblsChanged/context"/>
					<xsl:variable name="outer_rule_id" select="id"/>
					<xsl:variable name="top_level_stub" as="element()">
						<point/>
					</xsl:variable>
					<xsl:variable name="results" as="element(result)*">
						<xsl:apply-templates select="$outerTerm" mode="get_instances_of">
							<xsl:with-param name="targetTerm" select="$innerTerm"/>
							<xsl:with-param name="stub" select="$top_level_stub"/>
						</xsl:apply-templates>
					</xsl:variable>
					<xsl:for-each select="$results">
						<xsl:variable name="diamond_identity" select="concat($inner_rule_id,'+',$outer_rule_id,'(',position(),')')"/>
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
						<xsl:variable name="innerTerm_in_stub" as="element(term)">
							<xsl:apply-templates select="stub"  mode="fill_in_stub">
								<xsl:with-param name="subterm" select="$innerTerm"/>
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
								<xsl:with-param name="subterm" select="$innerReduction"/>
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
							<xsl:apply-templates select="$outerTerm" mode="substitution"> <!-- changed to purified because need to annotate with types after substitution -->
								<xsl:with-param name="substitutions" select="substitution"/> 
							</xsl:apply-templates>
						</xsl:variable>
						<xsl:variable name="outerTermSpecialised_text">
							<xsl:apply-templates select="$outerTermSpecialised" mode="text"/>
						</xsl:variable>
						<xsl:variable name="firstCutDiamondContextInitial" as="element(context)">
							<xsl:variable name="merged_declarations" as="element()*">
								<xsl:call-template name="merge_declarations">
									<xsl:with-param name="result_declarations_so_far" select="()"/>
									<xsl:with-param name="lhs_declarations" 
											select="$outerContextSubstituted/*"/>
									<xsl:with-param name="rhs_declarations" 
											select="$innerContextSubstituted/*"/>
								</xsl:call-template>
							</xsl:variable>
							<gat:context>
								<xsl:call-template name="remove_duplicate_declarations">
									<xsl:with-param name="declarations_so_far" select="()"/>
									<xsl:with-param name="declarations" select="$merged_declarations"/>
								</xsl:call-template>
							</gat:context>
						</xsl:variable>
						<xsl:variable name="left_reduction" as="element(term)">
							<gat:term>
								<xsl:apply-templates select="$outerReduction" mode="substitution">
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
										<xsl:apply-templates select="$outerTerm" mode="text"/>
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
										<xsl:apply-templates select="$innerTerm" mode="text"/>
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
	
		<xsl:template match="*" mode="normalise_rhs">
		<xsl:copy>
			<xsl:apply-templates mode="normalise_rhs"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="rhs" mode="normalise_rhs">
			<xsl:apply-templates select="." mode="normalise"/>
	</xsl:template>
	

	<!-- type_correction -->
	<xsl:param name="diamond_selection_pattern" select="'.*'"/>

	<xsl:template match="*" mode="type_correction">
		<xsl:copy>
			<xsl:apply-templates mode="type_correction"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="gat:algebra/gat:diamond" mode="type_correction">
		<xsl:if test="matches(identity,$diamond_selection_pattern)">
			<xsl:message>Type correcting <xsl:value-of select="gat:identity"/></xsl:message>
			<xsl:copy>
				<xsl:copy-of select="gat:identity"/>
				<gat:from_outer_id>
					<xsl:value-of select="from/outer/id"/>
				</gat:from_outer_id>
				<gat:from_inner_id>
					<xsl:value-of select="from/inner/id"/>
				</gat:from_inner_id>
				<gat:roughcut_text>
					<xsl:apply-templates select="gat:roughcut/*" mode="structured_text"/>
				</gat:roughcut_text>
				<xsl:variable name="firstCutDiamondContext" as="element(context)">    
					<xsl:call-template name="recursive_rewrite">
						<xsl:with-param name="document" select="gat:roughcut/gat:context"/>
					</xsl:call-template>
				</xsl:variable>

				<xsl:variable name="firstCutTopOfDiamondRule" as="element(tT-rule)">
					<gat:tT-rule>
						<xsl:copy-of select="$firstCutDiamondContext"/>
						<gat:tT-conclusion>
							<gat:term>
								<xsl:copy-of select="gat:roughcut/gat:top_of_diamond/*"/>
							</gat:term>
						</gat:tT-conclusion>							
					</gat:tT-rule>
				</xsl:variable>

				<xsl:message>Type enriching first cut diamond rule</xsl:message>
				<xsl:variable name="firstCutTopOfDiamondRuleTypeEnriched" as="element(tT-rule)">
					<xsl:apply-templates select="$firstCutTopOfDiamondRule" mode="type_enrich"/>
				</xsl:variable>
				<xsl:message>End of type enriching first cut diamond rule</xsl:message>
				<xsl:if test="not($quiet)">
					<xsl:message>firstCutTopOfDiamondRuleTypeEnriched <xsl:apply-templates select="$firstCutTopOfDiamondRuleTypeEnriched" mode="text"/>
					</xsl:message>
				</xsl:if>

				<xsl:choose>
					<xsl:when test="$firstCutTopOfDiamondRuleTypeEnriched/descendant::gat:illformed">
						<xsl:copy-of select="$firstCutTopOfDiamondRuleTypeEnriched/descendant::gat:type_error[gat:illformed]"/>
					</xsl:when>
					<xsl:when test="$firstCutTopOfDiamondRuleTypeEnriched/descendant::gat:insufficient_explicit_typing">
						<xsl:copy-of select="$firstCutTopOfDiamondRuleTypeEnriched/descendant::gat:type_error[gat:insufficient_explicit_typing]"/>
					</xsl:when>
					<xsl:when test="$firstCutTopOfDiamondRuleTypeEnriched/descendant::gat:type_error/gat:need-equal">
						<gat:type_corrected>
							<xsl:variable name="typeCorrection" as="element(result)?">
								<xsl:call-template name="specialise_to_correct_typing">
									<xsl:with-param name="tT-ruleTypeEnriched" select="$firstCutTopOfDiamondRuleTypeEnriched"/>
								</xsl:call-template>
							</xsl:variable>

							<xsl:variable name="typeCorrectionSubstitution" as="element(substitution)?" select="$typeCorrection/substitution"/>
							<xsl:choose>	
								<xsl:when test="not($typeCorrection/term/*/gat:type)">
									<xsl:message>Type correction INCOMPLETE  </xsl:message> 
									<gat:ABANDONED>
										<gat:NO-TYPE-CALCULATED/>
										<xsl:copy-of select="$typeCorrection"/>
									</gat:ABANDONED>								
								</xsl:when>	
								<xsl:when test="$typeCorrectionSubstitution">	
									<gat:top_of_diamond>
										<gat:tT-rule>
											<xsl:apply-templates select="$firstCutTopOfDiamondRule/context" mode="substitution">
												<xsl:with-param name="substitutions" select="$typeCorrectionSubstitution"/>
											</xsl:apply-templates>
											<gat:tT-conclusion>
												<xsl:apply-templates select="$firstCutTopOfDiamondRule/tT-conclusion/term" mode="substitution">
													<xsl:with-param name="substitutions" select="$typeCorrectionSubstitution"/>
												</xsl:apply-templates>
												<xsl:copy-of select="$typeCorrection/term/*/gat:type"/>
											</gat:tT-conclusion>
										</gat:tT-rule>							
									</gat:top_of_diamond>
									<gat:left_reduction>
										<xsl:apply-templates select="from/outer/left_reduction/*" mode="substitution">
											<xsl:with-param name="substitutions" select="$typeCorrectionSubstitution"/>
										</xsl:apply-templates>
									</gat:left_reduction>
									<gat:right_reduction>
										<xsl:apply-templates select="from/inner/right_reduction/*" mode="substitution">
											<xsl:with-param name="substitutions" select="$typeCorrectionSubstitution"/>
										</xsl:apply-templates>
									</gat:right_reduction>
								</xsl:when>
								<xsl:otherwise>
									<gat:ABANDONED>
										<xsl:copy-of select="$typeCorrection"/>
									</gat:ABANDONED>
								</xsl:otherwise>
							</xsl:choose>
						</gat:type_corrected>
					</xsl:when>
					<xsl:otherwise>
						<xsl:if test="not($firstCutTopOfDiamondRuleTypeEnriched/tT-conclusion/term/*/gat:type)">
							<xsl:message terminate="yes">Out OF SPEC <xsl:copy-of select="$firstCutTopOfDiamondRuleTypeEnriched/tT-conclusion/term/*"/></xsl:message>
						</xsl:if>
						<gat:type_corrected>
							<gat:top_of_diamond>
								<gat:tT-rule>
									<xsl:copy-of select="$firstCutTopOfDiamondRule/context"/>
									<gat:tT-conclusion>
										<xsl:copy-of select="$firstCutTopOfDiamondRule/tT-conclusion/term"/>
										<xsl:copy-of select="$firstCutTopOfDiamondRuleTypeEnriched/tT-conclusion/term/*/gat:type"/>
									</gat:tT-conclusion>
								</gat:tT-rule>							
							</gat:top_of_diamond>
							<xsl:copy-of select="from/outer/left_reduction"/>
							<xsl:copy-of select="from/inner/right_reduction" />
						</gat:type_corrected>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:copy>
		</xsl:if>
	</xsl:template>


	<!-- correlate diamonds -->
	<xsl:template match = "*" mode="correlate_diamonds">
		<xsl:copy>
			<xsl:apply-templates mode="correlate_diamonds"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="gat:algebra/gat:diamond[type_corrected/ABANDONED]" mode="correlate_diamonds">
	</xsl:template>

	<xsl:template match="algebra/diamond[not(type_corrected/ABANDONED)]" mode="correlate_diamonds">
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
							<xsl:message terminate="yes"> Number of target substitutions is <xsl:value-of select="count(target/substitute)"/> </xsl:message>
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
							<xsl:if test="not($candidate_more_general_right_reduction_text=$subject_right_reduction_text)">
								<gat:right_reduction_text>
									<xsl:value-of select="$candidate_more_general_right_reduction_text"/>
								</gat:right_reduction_text>
								<gat:subject_right_reduction_text>
									<xsl:value-of select="$subject_right_reduction_text"/>
								</gat:subject_right_reduction_text>
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

	<!-- diamond_filter -->

	<xsl:template match="*" mode="diamond_filter">
		<xsl:copy>
			<xsl:apply-templates mode="diamond_filter"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="gat:algebra/gat:diamond
		[not(most_generalising_tops/most_generalising_top
		[right_reduction_more_general
		and 
		left_reduction_more_general
		]
		)
		]" mode="diamond_filter">
		<xsl:message>Keeping <xsl:value-of select="identity"/>
		</xsl:message>
		<xsl:copy>
			<xsl:copy-of select="*[not(self::most_generalising_tops)]"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="gat:algebra/gat:diamond
		[most_generalising_tops/most_generalising_top
		[right_reduction_more_general
		and 
		left_reduction_more_general
		]
		]" mode="diamond_filter">

		<!-- filter out this diamond -->
		<xsl:variable name="generalising_top_that_itself_has_a_generalisation"
				as="element(most_generalising_top)*"
				select="most_generalising_tops/most_generalising_top
			[right_reduction_more_general
			and 
			left_reduction_more_general
			]
			[  some $diamond_id in diamond-id 
			satisfies //diamond[identity=$diamond_id]/most_generalising_tops/most_generalising_top
			[right_reduction_more_general
			and 
			left_reduction_more_general
			]
			]
			"/>
		<xsl:choose>
			<xsl:when test="$generalising_top_that_itself_has_a_generalisation">
				<xsl:message> Diamond <xsl:value-of select="identity"/> has generalising top that itself has a generalisation...</xsl:message>
				<xsl:variable name="subject_identity" select="identity"/>
				<xsl:choose>
					<xsl:when test="every $such_generalising_top
						in $generalising_top_that_itself_has_a_generalisation
						satisfies
						some $generalising_diamond in  //diamond[identity=$such_generalising_top/diamond-id],
						$further_generalisation in $generalising_diamond/most_generalising_tops/most_generalising_top,
						$diamond-id in $further_generalisation/diamond-id
						satisfies $diamond-id=$subject_identity
						">
						<xsl:message>... every one of them is to a more general diamond that itself has this one as a generalisation...</xsl:message>
						<!-- mutually generalising - filter out all but the first one  -->
						<xsl:variable name="subject_position" select="tokenize(identity,'-')[last()]"/>
						<xsl:choose>
							<xsl:when test="every $such_generalising_top
								in $generalising_top_that_itself_has_a_generalisation
								satisfies number($such_generalising_top/tokenize(diamond-id,'-')[last()]) &gt; number($subject_position)">
								<xsl:message>... keep this one as it is the first one.</xsl:message>
								<xsl:copy>
									<xsl:copy-of select="*[not(self::most_generalising_tops)]"/>
								</xsl:copy> 
							</xsl:when>
							<xsl:otherwise>
								<xsl:message>... discard this one as it is not the first one.</xsl:message>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<xsl:message>...discard this one because there is no circularity and generalisation is transitive</xsl:message>
					</xsl:otherwise>
				</xsl:choose>
				<!-- I don't know whether or not we could get circular generalisations -->
			</xsl:when>
			<xsl:otherwise>
				<xsl:message> Filtering out <xsl:value-of select="identity"/>
				</xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- grow_diamond
	-->
	<xsl:template match="*" mode="grow_diamond">
		<xsl:copy>
			<xsl:apply-templates mode="grow_diamond"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="algebra/gat:diamond" mode="grow_diamond">
		<xsl:copy>
			<xsl:copy-of select="*"/>
			<xsl:message> Normalise the left reduction </xsl:message>
			<xsl:variable name="leftReductionNormalised" as="element(term)">
				<xsl:call-template name="recursive_rewrite">
					<xsl:with-param name="document" select="type_corrected/left_reduction/term"/>
				</xsl:call-template>
			</xsl:variable>	
			<xsl:variable name="leftReductionNormalisedText">
				<xsl:apply-templates select="$leftReductionNormalised" mode="text"/>
			</xsl:variable>	
			<xsl:variable name="lhscost" as="xs:double">
				<xsl:apply-templates select="$leftReductionNormalised" mode="number"/>
			</xsl:variable>
			<xsl:variable name="rightReductionNormalised" as="element(term)">
				<xsl:call-template name="recursive_rewrite">
					<xsl:with-param name="document" select="type_corrected/right_reduction/term"/>
				</xsl:call-template>
			</xsl:variable>
			<xsl:variable name="rightReductionNormalisedText">
				<xsl:apply-templates select="$rightReductionNormalised" mode="text"/>
			</xsl:variable>	
			<xsl:variable name="rhscost" as="xs:double">
				<xsl:apply-templates select="$rightReductionNormalised" mode="number"/>
			</xsl:variable>
			<gat:leftside>
				<gat:left_reduction_normalised>
					<xsl:copy-of select="$leftReductionNormalised"/>
				</gat:left_reduction_normalised>
				<gat:cost>
					<xsl:value-of select="$lhscost"/>
				</gat:cost>
			</gat:leftside>
			<gat:rightside>
				<xsl:variable name="rightReductionNormalised" as="element(term)">
					<xsl:call-template name="recursive_rewrite">
						<xsl:with-param name="document" select="type_corrected/right_reduction/term"/>
					</xsl:call-template>
				</xsl:variable>
				<gat:right_reduction_normalised>
					<xsl:copy-of select="$rightReductionNormalised"/>
				</gat:right_reduction_normalised>
				<gat:cost>
					<xsl:value-of select="$rhscost"/>
				</gat:cost>
			</gat:rightside>

			<xsl:if test="not($leftReductionNormalisedText=$rightReductionNormalisedText)">
				<gat:NON-CONFLUENT>
					<xsl:if test="$lhscost=$rhscost">
						<gat:STALEMATE/>
					</xsl:if>
					<xsl:if test="$lhscost &lt; $rhscost">
						<gat:RIGHT-TO-LEFT/>
						<xsl:call-template name="rewrite_rule">
							<xsl:with-param name="lhs" select="$rightReductionNormalised"/>
							<xsl:with-param name="rhs" select="$leftReductionNormalised"/>
						</xsl:call-template>
					</xsl:if>
					<xsl:if test="$rhscost &lt; $lhscost">
						<gat:LEFT-TO-RIGHT/>
						<xsl:call-template name="rewrite_rule">
							<xsl:with-param name="lhs" select="$leftReductionNormalised"/>
							<xsl:with-param name="rhs" select="$rightReductionNormalised"/>
						</xsl:call-template>
					</xsl:if>
				</gat:NON-CONFLUENT>
				<xsl:message>*********** Diamond <xsl:value-of select="identity"/>  NON CONFLUENT ************</xsl:message>
			</xsl:if>

		</xsl:copy>
	</xsl:template>

	<xsl:template match="algebra/gat_diamond" name="rewrite_rule">
		<xsl:param name="lhs" as="element(term)"/>
		<xsl:param name="rhs" as="element(term)"/>
		<xsl:variable name="rewrite_rule" as="element(rewriteRule)">
			<gat:rewriteRule>
				<gat:id><xsl:value-of select="identity"/></gat:id>
				<gat:tt-rule>
					<xsl:copy-of	select="type_corrected/top_of_diamond/tT-rule/context" copy-namespaces="no"/>
					<gat:tt-conclusion>
						<gat:lhs>
							<xsl:copy-of select="$lhs/*"/>
						</gat:lhs>
						<gat:rhs>
							<xsl:copy-of select="$rhs/*"/>
						</gat:rhs>
					</gat:tt-conclusion>
				</gat:tt-rule>
			</gat:rewriteRule>
		</xsl:variable>
		<xsl:apply-templates select="$rewrite_rule" mode="unpostfix_variable_names_if_safe"/>
	</xsl:template>

	<!-- correlate rewrites -->
	<xsl:template match = "*" mode="correlate_rewrites">
		<xsl:copy>
			<xsl:apply-templates mode="correlate_rewrites"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="algebra/diamond[not(NON-CONFLUENT)]" mode="correlate_rewrites">
		<!-- confluent diamond - omit -->
	</xsl:template>


	<xsl:template match="algebra/diamond[NON-CONFLUENT/rewriteRule]" mode="correlate_rewrites">
		<xsl:copy>
			<xsl:message>Considering diamond rewrite: <xsl:value-of select="identity"/></xsl:message>			
			<xsl:apply-templates select="*[not(self::type_corrected|self::leftside|self::rightside)]" mode="correlate_rewrites"/>
			<xsl:variable name="subject_lhs" as="element(lhs)" select="NON-CONFLUENT/rewriteRule/tt-rule/tt-conclusion/lhs"/>
			<xsl:for-each select="(preceding-sibling::*|following-sibling::*)
				[self::gat:diamond]
				[NON-CONFLUENT/rewriteRule]
				">
				<xsl:variable name="candidate_identity" select="identity"/>
				<xsl:message>... is <xsl:value-of select="$candidate_identity"/> more general? </xsl:message>
				<xsl:variable name="how_specialises" as="element(gat:substitution)*">
					<xsl:for-each select="NON-CONFLUENT/rewriteRule/tt-rule/tt-conclusion/lhs/*">
						<xsl:call-template name="changeTargetVariablesAndSpecialiseTerm">
							<xsl:with-param name="targetTerm" select="$subject_lhs/*"/>
						</xsl:call-template>
					</xsl:for-each>
				</xsl:variable>
				<xsl:if test="$how_specialises">
					<xsl:if test="not(count(target/substitute)=0)">
						<xsl:message terminate="yes"> Number of target substitutions is <xsl:value-of select="count(target/substitute)"/> </xsl:message>
					</xsl:if>
					<gat:more_general_rewrite>
						<gat:diamond-id><xsl:value-of select="$candidate_identity"/></gat:diamond-id>
					</gat:more_general_rewrite>
				</xsl:if>
			</xsl:for-each>
		</xsl:copy>
	</xsl:template>

	<!-- rewrite filter -->

	<xsl:param name="include" />
	<xsl:param name="iteration" />

	<xsl:template match="algebra" mode="rewrite_filter">
		<xsl:copy>
		    <xsl:copy-of select="name|namespace|rewriteRule"/>
			<xsl:variable name="rewrite_rules" as="element(rewriteRule)*">
				<xsl:apply-templates mode="rewrite_filter"/>
			</xsl:variable>
			<xsl:for-each select="$rewrite_rules">
				<gat:rewriteRule>
					<gat:id>
						<xsl:value-of select="concat('x',$iteration,'.',position())"/>
					</gat:id>
					<gat:diamond>
						<xsl:value-of select="gat:id"/>
					</gat:diamond>
					<xsl:copy-of select="*[not(self::gat:id)]"/>
				</gat:rewriteRule>
			</xsl:for-each>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="text()" mode="rewrite_filter">
	</xsl:template>

	<xsl:template match="*|text()" mode="rewrite_filter">
		<xsl:apply-templates mode="rewrite_filter"/>
	</xsl:template>

	<xsl:template match="algebra/gat:diamond
		[NON-CONFLUENT/rewriteRule]
		[not(more_general_rewrite)]" mode="rewrite_filter">
		<xsl:message>Keeping rewrite <xsl:value-of select="identity"/>
		</xsl:message>
		<xsl:apply-templates select="NON-CONFLUENT/rewriteRule" mode="relabel"/>
	</xsl:template>

	<xsl:template match="algebra/gat:diamond
		[NON-CONFLUENT/rewriteRule]
		[more_general_rewrite]" mode="rewrite_filter">

		<!-- filter out this diamond unless the more general rewrite 
		     itself has this rewrite as a more general in 
			 in which case we choose the earliest in document order-->
		<xsl:variable name="more_general_rewrite_that_itself_has_a_more_general_rewrite"
				as="element(more_general_rewrite)*"
				select="more_general_rewrite
			[  some $diamond_id in diamond-id 
			satisfies //diamond[identity=$diamond_id]/more_general_rewrite
			]
			"/>
		<xsl:choose>
			<xsl:when test="$more_general_rewrite_that_itself_has_a_more_general_rewrite">
				<xsl:message> Diamond <xsl:value-of select="identity"/> has generalising top that itself has a generalisation...</xsl:message>
				<xsl:variable name="subject_identity" select="identity"/>
				<xsl:choose>
					<xsl:when test="every $such_more_general_rule
						in $more_general_rewrite_that_itself_has_a_more_general_rewrite
						satisfies
						some $more_general_rules_diamond in  //diamond[identity=$such_more_general_rule/diamond-id],
						$further_more_general_rules_diamond in $more_general_rules_diamond/more_general_rewrite,
						$diamond-id in $further_more_general_rules_diamond/diamond-id
						satisfies $diamond-id=$subject_identity
						">
						<xsl:message>... every one of them is to a more general rule that itself has this one as a generalisation...</xsl:message>
						<!-- mutually generalising - filter out all but the first one  -->
						<xsl:variable name="subject_id" select="generate-id()"/>
						<xsl:message>subject_id <xsl:value-of select="$subject_id"/></xsl:message>
						<xsl:choose>
							<xsl:when test="every $such_more_general_rule
								in $more_general_rewrite_that_itself_has_a_more_general_rewrite
								satisfies some $more_general_rules_diamond in  //diamond[identity=$such_more_general_rule/diamond-id]
								satisfies $more_general_rules_diamond/generate-id() &gt; $subject_id">
								<xsl:for-each select="$more_general_rewrite_that_itself_has_a_more_general_rewrite">
									<xsl:message>later is <xsl:value-of select="diamond-id"/></xsl:message>
								</xsl:for-each>
								<xsl:message>... keep this one as it is the first one in generate-id order.</xsl:message>
								<xsl:apply-templates select="NON-CONFLUENT/rewriteRule" mode="relabel"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:message>... discard this one as it is not the first one.</xsl:message>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<xsl:message>...discard this one because there is no circularity and generalisation is transitive</xsl:message>
					</xsl:otherwise>
				</xsl:choose>
				<!-- I don't know whether or not we could get circular generalisations -->
			</xsl:when>
			<xsl:otherwise>
				<xsl:message> Filtering out <xsl:value-of select="identity"/>
				</xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="rewriteRule" mode="relabel">
		<xsl:variable name="relabelling" as="element(relabel)*" select="ccseqfun:relabelling(tt-rule/context)"/>
		<xsl:copy copy-namespaces="no">
			<xsl:apply-templates mode="relabel_variables">
				<xsl:with-param name="relabelling" select="$relabelling"/>
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>


	<xsl:template match="*" mode="relabel_variables">
		<xsl:param name="relabelling" as="element(relabel)*"/>
	
		<xsl:copy copy-namespaces="no">
			<xsl:apply-templates mode="relabel_variables">
				<xsl:with-param name="relabelling" select="$relabelling"/>
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>


	<xsl:template match="*[self::decl|self::sequence|self::*:var|self::*:seq]" mode="relabel_variables">
		<xsl:param name="relabelling" as="element(relabel)*"/>
		<xsl:copy>
			<gat:name>
				<xsl:value-of select="$relabelling[pre=current()/gat:name]/post"/>
			</gat:name>
			
			<xsl:apply-templates select="*[not(self::gat:name)]" mode="relabel_variables">
				<xsl:with-param name="relabelling" select="$relabelling"/>
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>



	<xsl:template match="*" mode="expand_metavariables">
		<xsl:copy copy-namespaces="no">
			<xsl:apply-templates mode="expand_metavariables"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="gat:decl[gat:term]" mode="expand_metavariables">
		<!-- This is a meta-variable so don't copy -->
	</xsl:template>

	<xsl:template match="gat:decl[not(gat:term)]" mode="expand_metavariables">
		<xsl:copy copy-namespaces="no">
			<xsl:apply-templates select="*" mode="expand_metavariables"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*:var[(ancestor::T-rule|ancestor::tT-rule|ancestor::tt-rule|ancestor::TT-rule)/context/decl[name=current()/name]/term]" mode="expand_metavariables">
		<xsl:apply-templates select="(ancestor::T-rule|ancestor::tT-rule|ancestor::tt-rule|ancestor::TT-rule)/context/decl[name=current()/name]/term/*"
				mode="expand_metavariables"/>
	</xsl:template>

	<xsl:template match="*:var[not((ancestor::T-rule|ancestor::tT-rule|ancestor::tt-rule|ancestor::TT-rule)/context/decl[name=current()/name]/term)]" mode="expand_metavariables">
		<xsl:copy copy-namespaces="no">
			<xsl:apply-templates select="*" mode="expand_metavariables"/>
		</xsl:copy>
	</xsl:template>


	<xsl:template match="*" mode="postfix_variable_names">
		<xsl:copy copy-namespaces="no">
			<xsl:apply-templates mode="postfix_variable_names"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*:var|*:seq|gat:sequence|gat:decl" mode="postfix_variable_names">
		<xsl:copy copy-namespaces="no">
			<gat:name>
				<xsl:value-of select="gat:name"/>'</gat:name>
			<xsl:apply-templates select="*[not(self::gat:name)]" mode="postfix_variable_names"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*" mode="unpostfix_variable_names_if_safe">
		<xsl:copy copy-namespaces="no">
			<xsl:apply-templates mode="unpostfix_variable_names_if_safe"/>
		</xsl:copy>
	</xsl:template>

	<!--	 [substring(name,string-length(name)-1,string-length(name))=''''] -->
	<xsl:template match="*[self::*:var|self::*:seq|self::gat:sequence|self::gat:decl]
		[substring(name,string-length(name),1)='''']
		[not(some $varlike 
		in (ancestor::T-rule|ancestor::tT-rule|ancestor::tt-rule|ancestor::TT-rule)/(descendant::*:seq|descendant::*:var)
		satisfies $varlike/name = substring(name,1,string-length(name)-1)
		)
		]
		" 
			priority="100"							  
			mode="unpostfix_variable_names_if_safe">
		<xsl:copy copy-namespaces="no">
			<gat:name>
				<xsl:value-of select="replace(substring(name,1,string-length(name)-1),'''','8')"/>
			</gat:name>
			<xsl:apply-templates select="*[not(self::gat:name)]" mode="unpostfix_variable_names_if_safe"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*[self::*:var|self::*:seq|self::gat:sequence|self::gat:decl]
		[substring(name,string-length(name),1)='''']
		[some $decl 
		in (ancestor::T-rule|ancestor::tT-rule|ancestor::tt-rule|ancestor::TT-rule)/context/*
		satisfies ($decl/type/*:Ob/*:var/gat:name = name and
		not(substring($decl/name,string-length($decl/name) - 1,1)='''') and
		not(some $varlike 
		in (ancestor::T-rule|ancestor::tT-rule|ancestor::tt-rule|ancestor::TT-rule)/(descendant::*:seq|descendant::*:var)
		satisfies $varlike/name = concat($decl/name,'_p')
		)
		)
		]
		" 
			priority="150"
			mode="unpostfix_variable_names_if_safe">
		<xsl:copy copy-namespaces="no">
			<xsl:variable name="decl" 
					select="(ancestor::T-rule|ancestor::tT-rule|ancestor::tt-rule|ancestor::TT-rule)/context/child::decl
				[type/*:Ob/*:var/gat:name = current()/name
				and not(substring(name,string-length(name) - 1,1)='''')
				and not(some $varlike 
				in (ancestor::T-rule|ancestor::tT-rule|ancestor::tt-rule|ancestor::TT-rule)/(descendant::*:seq|descendant::*:var)
				satisfies $varlike/name = concat(name,'_p')
				)][1]"/>    
			<xsl:if test="substring($decl/name,string-length(name) - 1,1)=''''">
				<xsl:message terminate="yes">OUT OF SPEC</xsl:message>
			</xsl:if>
			<gat:name>
				<xsl:value-of select="replace(concat($decl/name,'_p'),'''','9')"/>
			</gat:name>
			<xsl:apply-templates select="*[not(self::gat:name)]" mode="unpostfix_variable_names_if_safe"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*[self::*:var|self::*:seq|self::gat:sequence|self::gat:decl]
		" 
			priority="50"							  
			mode="unpostfix_variable_names_if_safe">
		<xsl:copy copy-namespaces="no">
			<gat:name>
				<xsl:value-of select="replace(name,'''','m')"/>
			</gat:name>
			<xsl:apply-templates select="*[not(self::gat:name)]" mode="unpostfix_variable_names_if_safe"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*" mode="prefix_variable_names">
		<xsl:copy copy-namespaces="no">
			<xsl:apply-templates mode="prefix_variable_names"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*:var|*:seq|gat:sequence|gat:decl" mode="prefix_variable_names">
		<xsl:copy copy-namespaces="no">
			<gat:name>v<xsl:value-of select="gat:name"/>
			</gat:name>
			<xsl:apply-templates select="*[not(self::gat:name)]" mode="prefix_variable_names"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*" mode="unprefix_variable_names">
		<xsl:copy copy-namespaces="no">
			<xsl:apply-templates mode="unprefix_variable_names"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="substitute" mode="unprefix_variable_names">
		<xsl:copy copy-namespaces="no">
			<xsl:copy-of select="*:var|*:seq"/>
			<xsl:apply-templates select="*[not(self::*:var|self::*:seq)]" mode="unprefix_variable_names"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*:var|*:seq" mode="unprefix_variable_names">
		<xsl:copy copy-namespaces="no">
			<gat:name>
				<xsl:value-of select="substring(gat:name,2)"/>
			</gat:name>
			<xsl:apply-templates select="*[not(self::gat:name)]" mode="unprefix_variable_names"/>
		</xsl:copy>
	</xsl:template>



	<!-- "get_instances_of" is an abbreviation of 
       "get all matching subtitutional instances of this and its a proper subterms"
       This template returns zero or more <result> elements.
       Each <result> contains  a pointed version of the given term <pointed_lhs_specialised>
       and a substititution <substitutions> which when applied at the subterm at the point yields a match 
       to the target term.       
       Modified 19 Feb 2018. 
           Now is invoked within context of a rewrite rule to which we wish to find
              all matching subtitutional instances of its lhs term and its a proper subterms.
           Now is passed a targetRule whose lhs is the target term.
  -->
	<xsl:template match="*" mode="get_instances_of">
		<xsl:param name="targetTerm" as="element()"/>
		<xsl:param name="stub"       as="element()"/>


		<!-- First look for specialisations (i.e. substuituitional instances) of the current term -->
		<xsl:variable name="substitutions" as="element()*">
			<xsl:call-template name="unifyTerms">
				<xsl:with-param name="subjectTerm" select="."/>
				<xsl:with-param name="targetTerm" select="$targetTerm"/>
			</xsl:call-template>
		</xsl:variable> 
		<!-- If found then add to the output stream -->
		<xsl:for-each select="$substitutions">

			<xsl:if test="not(self::INCOMPATIBLE)">
				<result>
					<xsl:copy-of select="."/>
					<stub>
						<xsl:apply-templates  select="$stub" mode="substitution">
							<xsl:with-param name="substitutions" select="."/>
						</xsl:apply-templates>
					</stub>
				</result>
			</xsl:if>
		</xsl:for-each>
		<!-- Next do the same for all subterms (recursively) -->
		<xsl:for-each select="*">
			<xsl:variable name="local_stub" as="element()">
				<xsl:apply-templates  select="$stub" mode="push_point">
					<xsl:with-param name="elementname" select="../name()"/>
					<xsl:with-param name="preceding" select="preceding-sibling::*"/>
					<xsl:with-param name="following" select="following-sibling::*[not(self::gat:*)]"/>
				</xsl:apply-templates>
			</xsl:variable>
			<xsl:apply-templates select="." mode="get_instances_of">
				<xsl:with-param name="targetTerm" select="$targetTerm"/>
				<xsl:with-param name="stub" select="$local_stub"/>
			</xsl:apply-templates>
		</xsl:for-each>
	</xsl:template>  


	<xsl:template match="*" mode="push_point">
		<xsl:param name="elementname" as="xs:string"/>
		<xsl:param name="preceding" as="element()*"/>
		<xsl:param name="following" as="element()*"/>
		<xsl:copy>
			<xsl:apply-templates  mode="push_point">
				<xsl:with-param name="elementname" select="$elementname"/>
				<xsl:with-param name="preceding" select="$preceding"/>
				<xsl:with-param name="following" select="$following"/>
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="point" mode="push_point">
		<xsl:param name="elementname" as="xs:string"/>
		<xsl:param name="preceding" as="element()*"/>
		<xsl:param name="following" as="element()*"/>
		<xsl:element name="{$elementname}" 
				namespace="http://www.entitymodelling.org/theory/contextualcategory/sequence">
			<xsl:copy-of select="$preceding"/>
			<point/>
			<xsl:copy-of select="$following"/>
		</xsl:element>
	</xsl:template>


	<xsl:template match="stub" mode="fill_in_stub">
		<xsl:param name="subterm"/>
		<term>
			<xsl:apply-templates mode="fill_in_stub">
				<xsl:with-param name="subterm" select="$subterm"/>
			</xsl:apply-templates>
		</term>
	</xsl:template>

	<xsl:template match="point" mode="fill_in_stub">
		<xsl:param name="subterm"/>
		<xsl:copy-of select="$subterm"/>
	</xsl:template>

	<xsl:template match="*" mode="fill_in_stub">
		<xsl:param name="subterm"/>
		<xsl:copy>
			<xsl:apply-templates mode="fill_in_stub">
				<xsl:with-param name="subterm" select="$subterm"/>
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>


	<xsl:template match="*:var|*:seq" mode="get_instances_of">
		<!-- don't want a result from a variable or sequence matching whole lhs term-->
	</xsl:template>     

	<xsl:template match="*" mode="cleanse_of_attributes">
		<xsl:copy copy-namespaces="no">
			<xsl:apply-templates mode="cleanse_of_attributes"/>
		</xsl:copy>
	</xsl:template>



</xsl:transform>
