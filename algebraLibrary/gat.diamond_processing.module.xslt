<xsl:transform version="2.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:gat              ="http://www.entitymodelling.org/theory/generalisedalgebraictheory"
		xpath-default-namespace="http://www.entitymodelling.org/theory/generalisedalgebraictheory"	   
		xmlns="http://www.entitymodelling.org/theory/generalisedalgebraictheory"
		exclude-result-prefixes="xs gat">

	<xsl:strip-space elements="*"/> 




	<xsl:template match = "/" mode="process_diamonds">
		<xsl:apply-templates mode="process_diamonds"/>
	</xsl:template>

	<xsl:template match="algebra" mode="process_diamonds">
		<xsl:copy>
			<xsl:copy-of select="namespace::*"/>
			<xsl:variable name="algebra_name" select="name"/>
			<xsl:for-each select="rewriteRule/tt-rule"> 
				<xsl:variable name="inner_rule_id" select="concat($algebra_name,../id)"/>
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
					<xsl:variable name="outer_rule_id" select="concat($algebra_name,../id)"/>

					<xsl:variable name="outerTerm" as="element()" select="$outerRule_lhs/*"/>

					<!--
					<xsl:variable name="outerTerm" as="element()">
						id attributes are added to outerTerm which then go forward into
                   outerTermPurified. This is so that the point of application 
                   of the inner rule (in outerTermPurified) can be identified as 
                   a point in outerTerm.   NO LONGER REQD
                          
						<xsl:apply-templates select="$lhs/*" mode="assign_ids"/>
					</xsl:variable>
					-->
					<xsl:variable name="outerTermPurified" as="element()">
						<xsl:apply-templates select="$outerTerm" mode="remove_gat_annotations"/>
					</xsl:variable>
					<!--
					<xsl:message>outer term <xsl:copy-of select="$outerTerm"/></xsl:message>
					-->

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
						<xsl:variable name="outerTermSpecialised" as="element()">
							<xsl:apply-templates select="$outerTermPurified" mode="substitution"> <!-- changed to purified because need to annotate with types after substitution -->
								<xsl:with-param name="substitutions" select="substitution"/> 
							</xsl:apply-templates>
						</xsl:variable>
						<xsl:variable name="outerTermSpecialisedText">
							<xsl:apply-templates select="$outerTermSpecialised" mode="text"/>
						</xsl:variable>
						<xsl:variable name="firstCutDiamondContextInitial" as="element(context)">
							<context>
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
							</context>
						</xsl:variable>
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

						<xsl:message>Type enriching first cut diamond rule</xsl:message>
						<xsl:variable name="firstCutTopOfDiamondRuleTypeEnriched" as="element(tT-rule)">
							<xsl:apply-templates select="$firstCutTopOfDiamondRule" mode="type_enrich"/>
						</xsl:variable>
						<xsl:message>End of type enriching first cut diamond rule</xsl:message>

						<xsl:variable name="typeCorrectionSubstitution" as="element(substitution)?">
							<xsl:call-template name="specialise_to_correct_typing">
								<xsl:with-param name="tT-ruleTypeEnriched" select="$firstCutTopOfDiamondRuleTypeEnriched"/>
							</xsl:call-template>
						</xsl:variable> 



						<xsl:choose>						
							<xsl:when test="$typeCorrectionSubstitution">	

								<xsl:variable name="typeCorrectedDiamondRuleTypeEnriched" as="element(tT-rule)">   
									<xsl:apply-templates select="$firstCutTopOfDiamondRuleTypeEnriched" mode="substitution">
										<xsl:with-param name="substitutions" select="$typeCorrectionSubstitution"/> <!-- just do the first one -->
									</xsl:apply-templates>  
								</xsl:variable>

								<xsl:variable name="topOfDiamond" as="element()" 
										select="$typeCorrectedDiamondRuleTypeEnriched/tT-conclusion/term/*"/>


								<!-- 31st March 2018 -->
								<xsl:variable name="rhs_cleansed" as="element()">
									<xsl:apply-templates select="$outerRule_rhs/*" mode="remove_gat_annotations"/>
								</xsl:variable>

								<xsl:variable name="left_reduction_firstcut" as="element(term)">
									<gat:term>
										<xsl:apply-templates select="$rhs_cleansed" mode="substitution">
											<xsl:with-param name="substitutions" select="substitution"/>  
										</xsl:apply-templates>
									</gat:term>
								</xsl:variable>
								<xsl:variable name="left_reduction" as="element(term)">
									<xsl:apply-templates select="$left_reduction_firstcut" mode="substitution">
										<xsl:with-param name="substitutions" select="$typeCorrectionSubstitution"/>
									</xsl:apply-templates>
								</xsl:variable>
								<xsl:variable name="left_reductionRule" as="element(tT-rule)">
									<gat:tT-rule>
										<xsl:copy-of select="$typeCorrectedDiamondRuleTypeEnriched/context"/>
										<gat:tT-conclusion>
											<xsl:copy-of select="$left_reduction"/>
										</gat:tT-conclusion>							
									</gat:tT-rule>
								</xsl:variable>
								<xsl:variable name="left_reductionRuleTypeEnriched" as="element(tT-rule)">
									<xsl:apply-templates select="$left_reductionRule" mode="cleanse_and_type_enrich"/>
								</xsl:variable>

								<xsl:variable name="leftReductionTypeEnriched" as="element(term)"
										select="$left_reductionRuleTypeEnriched/tT-conclusion/term" />

								<!-- inner Term -->

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

								<xsl:variable name="innerTerm_rhs_in_context" as="element(term)">
									<xsl:apply-templates select="stub"  mode="fill_in_stub">
										<xsl:with-param name="subterm" select="$innerTerm_rhs"/>
									</xsl:apply-templates>
								</xsl:variable>

								<xsl:variable name="right_reduction_first_cut" as="element(term)">
									<gat:term>
										<xsl:apply-templates select="$innerTerm_rhs_in_context/*" mode="substitution">
											<xsl:with-param name="substitutions" select="substitution"/>
										</xsl:apply-templates>
									</gat:term>
								</xsl:variable>
								<xsl:variable name="right_reduction" as="element(term)">
									<gat:term>
										<xsl:apply-templates select="$right_reduction_first_cut/*" mode="substitution">
											<xsl:with-param name="substitutions" select="$typeCorrectionSubstitution"/>
										</xsl:apply-templates>
									</gat:term>
								</xsl:variable>

								<!-- 31 March 2018 cleanse right reduction -->
								<xsl:variable name="right_reduction_cleansed" as="element()">
									<xsl:apply-templates select="$right_reduction" mode="remove_gat_annotations"/>
								</xsl:variable>

								<xsl:message>right_reduction text is <xsl:apply-templates select="$right_reduction" mode="text"/></xsl:message>
								<!--								
								<xsl:message>right_reduction  is <xsl:copy-of copy-namespaces="no" select="$right_reduction"/></xsl:message>                      
								<xsl:message>right_reduction context is <xsl:apply-templates select="$typeCorrectedDiamondRuleTypeEnriched/context" mode="text"/></xsl:message>
								-->
								<xsl:variable name="right_reductionRule" as="element(tT-rule)">
									<gat:tT-rule>
										<xsl:copy-of select="$typeCorrectedDiamondRuleTypeEnriched/context"/>
										<gat:tT-conclusion>
											<xsl:copy-of select="$right_reduction"/>
										</gat:tT-conclusion>							
									</gat:tT-rule>
								</xsl:variable>
								<xsl:variable name="right_reductionRuleTypeEnriched" as="element(tT-rule)">
									<xsl:apply-templates select="$right_reductionRule" mode="cleanse_and_type_enrich"/>
								</xsl:variable>
								<xsl:variable name="rightReductionTypeEnriched" as="element(term)"
										select="$right_reductionRuleTypeEnriched/tT-conclusion/term" />



								<xsl:variable name="diamondIdentity" select="concat($outer_rule_id,'-',$inner_rule_id,'-',position())"/>
								<!-- OUTPUT -->
								<gat:diamond xmlns="http://www.entitymodelling.org/theory/contextualcategory/sequence">
									<gat:identity><xsl:value-of select="$diamondIdentity"/></gat:identity>
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
											<gat:substitution> 
												<xsl:apply-templates  select="substitution/subject/substitute" mode="text"/>
											</gat:substitution>
											<gat:contextsubstituted>
												<!--<xsl:copy-of select="$outerContextSubstituted"/>-->  <!-- MAKE INTO FIRST PASS XML. SECOND PASS TEXT OR EVEN tex -->
												<xsl:apply-templates select="$outerContextSubstituted" mode="text"/>  
											</gat:contextsubstituted>
											<gat:term_specialised>
												<!--<xsl:copy-of select="$outerTermSpecialised"/>-->
												<xsl:apply-templates select="$outerTermSpecialised" mode="text"/>
											</gat:term_specialised>

											<gat:leftreduction>
												<!--<xsl:copy-of select="$left_reduction" />-->
												<xsl:apply-templates select="$left_reduction" mode="text"/>
											</gat:leftreduction>
											<gat:left_reduction_type_errors>							     
												<xsl:apply-templates select="$left_reductionRuleTypeEnriched" mode="text_report_errors"/>
											</gat:left_reduction_type_errors>

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

											<gat:rightreduction>
												<!--<xsl:copy-of select="$right_reduction" />-->
												<xsl:apply-templates select="$right_reduction" mode="text"/>
											</gat:rightreduction>
											<gat:right_reduction_type_errors>
												<xsl:apply-templates select="$right_reductionRuleTypeEnriched" mode="text_report_errors"/>
											</gat:right_reduction_type_errors>

										</gat:inner>

										<xsl:if test="not($innerTerm_lhs_in_context_specialised_text = $outerTermSpecialisedText)">
											<gat:ERROR> OUT OF SPEC </gat:ERROR>
											<xsl:copy-of select="."/>  for diagnostic purposes 
										</xsl:if> 


									</gat:from>

									<!-- Normalise left hand side -->
									<!--
									<xsl:message> left reduction type enriched is <xsl:copy-of select="$leftReductionTypeEnriched"/> </xsl:message>
					                -->
									<xsl:message> Normalise the left reduction </xsl:message>
									<xsl:variable name="leftReductionNormalised" as="element(term)">
										<xsl:call-template name="recursive_rewrite">
											<xsl:with-param name="document" select="$left_reduction" /> <!-- 31 March 2018 Change from ledtReductioTypeEnriched -->
										</xsl:call-template>
									</xsl:variable>
									<xsl:variable name="leftReductionNormalisedText">
										<xsl:apply-templates select="$leftReductionNormalised" mode="text"/>
									</xsl:variable>	
									<!--
									<xsl:message>left reduction normalised <xsl:value-of select="$leftReductionNormalisedText"/></xsl:message>	
                                    -->									
									<xsl:variable name="lhscost" as="xs:double">
										<xsl:apply-templates select="$leftReductionNormalised" mode="number"/>
									</xsl:variable>
									<!-- Normalise right hand side -->
									<xsl:message> Normalise the right reduction </xsl:message>
									<!--
									<xsl:message> right reduction  type enriched is <xsl:copy-of copy-namespaces="no" select="$rightReductionTypeEnriched"/> </xsl:message>
                                    -->
									<xsl:variable name="rightReductionNormalised" as="element(term)">
										<xsl:call-template name="recursive_rewrite">
											<xsl:with-param name="document" select="$right_reduction_cleansed"/>
										</xsl:call-template>
									</xsl:variable>
									<xsl:variable name="rightReductionNormalisedText">
										<xsl:apply-templates select="$rightReductionNormalised" mode="text"/>
									</xsl:variable>							
									<xsl:message><xsl:value-of select="$rightReductionNormalisedText"/></xsl:message>
									<xsl:variable name="rhscost" as="xs:double">
										<xsl:apply-templates select="$rightReductionNormalised" mode="number"/>
									</xsl:variable>
									<!-- OUTPUT -->
									<gat:first_pass_diamond_context>
										<xsl:apply-templates select="$firstCutDiamondContext" mode="text"/> 
									</gat:first_pass_diamond_context>     
									<gat:first_pass_top_of_diamond>
										<!--<xsl:copy-of select="$firstCutTopOfDiamondRuleTypeEnriched/tT-conclusion/term/*"/>-->
										<xsl:apply-templates select="$firstCutTopOfDiamondRuleTypeEnriched/tT-conclusion/term/*" mode="text"/>
									</gat:first_pass_top_of_diamond>

									<gat:first_pass_diamond_type_errors>
										<xsl:apply-templates select="$firstCutTopOfDiamondRuleTypeEnriched" mode="text_report_errors"/>
									</gat:first_pass_diamond_type_errors>

									<!-- second pass -->
									<gat:diamond_context>
										<xsl:apply-templates select="$typeCorrectedDiamondRuleTypeEnriched/context" mode="text"/> 
									</gat:diamond_context>

									<!--COPY the ancestor term with the result substitutions and mark application_node_id -->
									<gat:top_of_diamond>
										<!--<xsl:copy-of select="$topOfDiamond"/>-->
										<xsl:apply-templates select="$topOfDiamond" mode="text"/>
									</gat:top_of_diamond>
									<gat:top_of_diamond_type>
										<!--<xsl:copy-of select="$typeCorrectedDiamondRuleTypeEnriched/tT-conclusion"/>-->
										<xsl:apply-templates select="$typeCorrectedDiamondRuleTypeEnriched/tT-conclusion/term/*/gat:type/*" mode="text"/> 
									</gat:top_of_diamond_type>


									<gat:top_of_diamond_type_errors>							     
										<!--<xsl:copy-of select="$topOfDiamondRuleTypeEnriched/tT-conclusion/term"/>-->
										<xsl:apply-templates select="$topOfDiamond" mode="text_report_errors"/>
									</gat:top_of_diamond_type_errors>

									<gat:leftReductionNormalised>
										<!--
									<xsl:if test="not($leftReductionNormalisedText=$rightReductionNormalisedText)">
										<xsl:copy-of select="$leftReductionNormalised"/>
									</xsl:if>
                                    -->
										<gat:text>
											<xsl:value-of select="$leftReductionNormalisedText"/>
											<xsl:text>{</xsl:text>
											<xsl:value-of select="$lhscost"/>
											<xsl:text>}</xsl:text>
										</gat:text>
									</gat:leftReductionNormalised>
									<gat:rightReductionNormalised>
										<!--
									<xsl:if test="not($leftReductionNormalisedText = $rightReductionNormalisedText)">
										<xsl:copy-of select="$rightReductionNormalised"/>
									</xsl:if>
                                    -->                  
										<gat:text>
											<xsl:value-of select="$rightReductionNormalisedText"/>
											<xsl:text>{</xsl:text>
											<xsl:value-of select="$rhscost"/>
											<xsl:text>}</xsl:text>
										</gat:text>
									</gat:rightReductionNormalised>
									<xsl:if test="not($leftReductionNormalisedText=$rightReductionNormalisedText)">
										<gat:NON-CONFLUENT>
											<xsl:if test="$lhscost=$rhscost">
												<gat:STALEMATE/>
											</xsl:if>
											<xsl:if test="$lhscost &lt; $rhscost">
												<gat:RIGHT-TO-LEFT/>
											</xsl:if>
											<xsl:if test="$rhscost &lt; $lhscost">
												<gat:LEFT-TO-RIGHT/>
											</xsl:if>
										</gat:NON-CONFLUENT>
										<xsl:message>*********** Diamond <xsl:value-of select="$diamondIdentity"/>  NON CONFLUENT ************</xsl:message>
									</xsl:if>


								</gat:diamond>

							</xsl:when>
							<xsl:otherwise>
								<ABANDONED/>
							</xsl:otherwise>
						</xsl:choose>

					</xsl:for-each> <!-- end outer term -->
				</xsl:for-each> <!-- end inner term -->
			</xsl:for-each>
		</xsl:copy>
	</xsl:template>




</xsl:transform>
