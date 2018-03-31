<xsl:transform version="2.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:gat              ="http://www.entitymodelling.org/theory/generalisedalgebraictheory"
		xpath-default-namespace="http://www.entitymodelling.org/theory/generalisedalgebraictheory"	   
		xmlns="http://www.entitymodelling.org/theory/generalisedalgebraictheory"
		exclude-result-prefixes="xs gat">

	<xsl:strip-space elements="*"/> 



	<xsl:template match="*[self::gat:*][not(self::gat:term)][not(self::gat:type)]" mode="normalise">
		<xsl:message> THIS "normailise" template is only used from normalisation unit test</xsl:message>
		<xsl:copy>
			<xsl:copy-of select="namespace::*"/>
			<xsl:apply-templates mode="normalise"/>
		</xsl:copy>
	</xsl:template>


	<xsl:template match="gat:type" mode="normalise">  
		<xsl:message> Normalising type <xsl:apply-templates select="." mode="text"/>
			<xsl:copy-of select="."/></xsl:message>

		<xsl:copy>
			<xsl:call-template name="recursive_rewrite">
				<xsl:with-param name="document" select="*"/> 
			</xsl:call-template>
		</xsl:copy>
		<xsl:message> End Normalising type <xsl:apply-templates select="." mode="text"/> </xsl:message>
	</xsl:template>

	<xsl:template match="gat:term" mode="normalise">  
		<xsl:message> Normalising term <xsl:apply-templates select="." mode="text"/></xsl:message>
		<xsl:copy>
			<xsl:call-template name="recursive_rewrite">
				<xsl:with-param name="document" select="*"/> 
			</xsl:call-template>
		</xsl:copy>
		<xsl:message> End Normalising term <xsl:apply-templates select="." mode="text"/></xsl:message>
	</xsl:template>

	<xsl:template match="*[not(self::gat:*)]" mode="normalise">  
		<xsl:message> Normalising <xsl:apply-templates select="." mode="text"/></xsl:message>
		<xsl:call-template name="recursive_rewrite">
			<xsl:with-param name="document" select="."/> 
		</xsl:call-template>
		<xsl:message> End Normalising <xsl:apply-templates select="." mode="text"/></xsl:message>
	</xsl:template>


	<xsl:template match = "/" mode="prepare_diamonds">
		<xsl:apply-templates mode="prepare_diamonds"/>
	</xsl:template>

	<xsl:template match="algebra" mode="prepare_diamonds">
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
					<xsl:message>outer term <xsl:copy-of select="$outerTerm"/></xsl:message>

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
								<xsl:call-template name="merge_declarations">
									<xsl:with-param name="result_declarations_so_far" select="()"/>
									<xsl:with-param name="lhs_declarations" select="$outerContextSubstituted/*[(some $var_or_seq 
										in $outerTermSpecialised/descendant::*[self::*:var|self::*:seq]
										satisfies $var_or_seq/name = ./name)]"/>
									<xsl:with-param name="rhs_declarations" select="$innerContextSubstituted/*[(some $var_or_seq 
										in $outerTermSpecialised/descendant::*[self::*:var|self::*:seq] 
										satisfies $var_or_seq/name = ./name)]"/>
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
								<xsl:message>right_reduction  is <xsl:copy-of copy-namespaces="no" select="$right_reduction"/></xsl:message>

								<xsl:message>right_reduction context is <xsl:apply-templates select="$typeCorrectedDiamondRuleTypeEnriched/context" mode="text"/></xsl:message>
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
									<xsl:message> left reduction type enriched is <xsl:copy-of select="$leftReductionTypeEnriched"/> </xsl:message>
									<xsl:message> Normalise the left reduction </xsl:message>
									<xsl:variable name="leftReductionNormalised" as="element(term)">
										<xsl:call-template name="recursive_rewrite">
											<xsl:with-param name="document" select="$left_reduction" /> <!-- 31 March 2018 Change from ledtReductioTypeEnriched -->
										</xsl:call-template>
									</xsl:variable>
									<xsl:variable name="leftReductionNormalisedText">
										<xsl:apply-templates select="$leftReductionNormalised" mode="text"/>
									</xsl:variable>	
									<xsl:message>left reduction normalised <xsl:value-of select="$leftReductionNormalisedText"/></xsl:message>									
									<xsl:variable name="lhscost" as="xs:double">
										<xsl:apply-templates select="$leftReductionNormalised" mode="number"/>
									</xsl:variable>
									<!-- Normalise right hand side -->
									<xsl:message> Normalise the right reduction </xsl:message>
									<xsl:message> right reduction  type enriched is <xsl:copy-of copy-namespaces="no" select="$rightReductionTypeEnriched"/> </xsl:message>
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

	<xsl:template name="specialise_to_correct_typing">
		<xsl:param name="tT-ruleTypeEnriched" as="element(tT-rule)"/>

		<xsl:message>Entering type correction </xsl:message>
		<xsl:variable name="termInitial" as="element()" select="$tT-ruleTypeEnriched/tT-conclusion/term/*"/>

		<xsl:variable name="first_type_error" select="$termInitial/descendant::type_error[1]" as="element(type_error)?"/>
		<xsl:choose>
			<xsl:when test="$termInitial/descendant::illformed">
				<xsl:message>Bail out of type correction - cant be done</xsl:message>
			</xsl:when>
			<xsl:when test="$first_type_error">
				<xsl:message>Found type errors in initial term: </xsl:message>
				<xsl:message>          <xsl:value-of select="$termInitial/descendant::type_error"/> </xsl:message>
				<xsl:message> Dealing with type error <xsl:value-of select="$first_type_error/description"/> </xsl:message>
				<xsl:variable name="lhs" as="element()">
					<xsl:apply-templates select="$first_type_error/need-equal/lhs" mode="remove_gat_annotations"/>
				</xsl:variable>
				<xsl:variable name="rhs" as="element()">
					<xsl:apply-templates select="$first_type_error/need-equal/rhs" mode="remove_gat_annotations"/>
				</xsl:variable>
				<xsl:for-each select="$lhs/*"> 
					<xsl:variable name="specialisation_results" as="element()*">
						<xsl:call-template name="specialiseTermConsistentWithContext">
							<xsl:with-param name="targetTerm" select="$rhs/*"/>
							<xsl:with-param name="context" select="$tT-ruleTypeEnriched/context"/>
						</xsl:call-template>
					</xsl:variable>        
					<xsl:choose>
						<xsl:when test="not($specialisation_results) or $specialisation_results[self::INCOMPATIBLE]">
							<xsl:message>Cannot specialise diamond to be well-typed</xsl:message>
							<!--<xsl:copy-of select="$tT-ruleTypeEnriched"/> -->
						</xsl:when>
						<xsl:otherwise>
							<xsl:message>Applying type correction substitution <xsl:apply-templates select="$specialisation_results[1]" mode="text"/></xsl:message>						
							<xsl:variable name="typeImprovedtT-rule" as="element(tT-rule)">   
								<xsl:apply-templates select="$tT-ruleTypeEnriched" mode="substitution">
									<xsl:with-param name="substitutions" select="$specialisation_results[1]"/> <!-- just do the first one -->
								</xsl:apply-templates>  
							</xsl:variable>
							<xsl:message>Now cleanse and type enrich</xsl:message>
							<xsl:variable name="typeImprovedRuleTypeEnriched" as="element(tT-rule)">
								<xsl:apply-templates 	select="$typeImprovedtT-rule" mode="cleanse_and_type_enrich"/>
							</xsl:variable>
							<xsl:if test="$typeImprovedRuleTypeEnriched/descendant::illformed">
								<xsl:message>************illformed on return from type enrichment during type correction</xsl:message>
							</xsl:if>
							<xsl:message>Recursing into type correction"</xsl:message>
							<xsl:variable name="further_improvement_substitution" as="element(substitution)?">
								<xsl:call-template name="specialise_to_correct_typing">
									<xsl:with-param name="tT-ruleTypeEnriched" select="$typeImprovedRuleTypeEnriched"/>
								</xsl:call-template>  
							</xsl:variable>			
							<xsl:message>End of recurse into type correction</xsl:message>							
							<!-- return composed substitutions -->
							<xsl:choose>
								<xsl:when test="$further_improvement_substitution">
									<xsl:apply-templates select="$further_improvement_substitution" mode="compose_substitutions">
										<xsl:with-param name="head_substitution" select="$specialisation_results[1]"/>
									</xsl:apply-templates>		
								</xsl:when>	
								<xsl:otherwise>
									<xsl:message>Bailing out of type correction</xsl:message>							
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:message>End of type correction with identity sub</xsl:message>
				<!-- empty (identity) substitution -->
				<substitution>
					<subject></subject>
					<target></target>
				</substitution>
				<!--<xsl:copy-of select="$tT-ruleTypeEnriched"/>-->
			</xsl:otherwise>
		</xsl:choose>  
	</xsl:template>


	<xsl:template name="specialiseTermConsistentWithContext">
		<xsl:param name="targetTerm" as="element()"/>
		<xsl:param name="context" as="element(context)"/>

		<xsl:variable name="specialisations" as="element()*">
			<xsl:call-template name="specialiseTerm">
				<xsl:with-param name="targetTerm" select="$targetTerm"/>		
			</xsl:call-template>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="not($specialisations) or $specialisations[self::INCOMPATIBLE]">
				<INCOMPATIBLE/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:for-each select="$specialisations">
					<xsl:if test="not(self::substitution)">
						<xsl:message terminate="yes">Assertion failuure <xsl:value-of select="name()"/></xsl:message>
					</xsl:if>
					<xsl:choose>
						<xsl:when test="some $substitute in (subject|target)/substitute,
							$varlike_being_substituted_for in $substitute/(*:var|*:seq),  
							$varlike_in_substituting_term in $substitute/term/(descendant::*:var|descendant::*:seq), 
							$defining_decl_of_varlike_in_substituting_term in $context/(decl|sequence)[name=$varlike_in_substituting_term/name],
							$varlike_dependended_on_by_substituting_term_varlike 
							in $defining_decl_of_varlike_in_substituting_term/type/(descendant::*:var|descendant::*:seq)										 
							satisfies $varlike_being_substituted_for/name=$varlike_dependended_on_by_substituting_term_varlike/name">
							<xsl:message>Avoiding dependency cycle </xsl:message>
							<INCOMPATIBLE/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:copy-of select="."/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>


	<xsl:template match="tT-rule" mode="cleanse_and_type_enrich">
		<xsl:variable name="termCleansed" as="element(term)">
			<xsl:apply-templates select="./tT-conclusion/term" mode="remove_gat_annotations"/>
		</xsl:variable>
		<xsl:variable name="tT-rule_cleansed" as="element(tT-rule)">
			<gat:tT-rule>
				<xsl:copy-of select="./context"/>
				<gat:tT-conclusion>
					<xsl:copy-of select="$termCleansed"/>
				</gat:tT-conclusion>
			</gat:tT-rule>
		</xsl:variable>
		<xsl:apply-templates 	select="$tT-rule_cleansed" mode="type_enrich"/>
	</xsl:template>



	<xsl:template match="*" mode="remove_gat_annotations">
		<!-- need to keeep gat:name however -->
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:copy-of select="gat:name"/> <!-- only applicable to var's and seq's -->
			<xsl:apply-templates select="*[not(self::gat:*)]" mode="remove_gat_annotations"/>
		</xsl:copy>
	</xsl:template>

	<!--
	<xsl:template match="gat:*" mode="assign_ids">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates  mode="assign_ids"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*[not(self::gat:*)][@id]" mode="assign_ids">	
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates  mode="assign_ids"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*[not(self::gat:*)][not(@id)]" mode="assign_ids">	
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:attribute name="id" select="generate-id()"/>
			<xsl:apply-templates  mode="assign_ids"/>
		</xsl:copy>
	</xsl:template>
	
	-->


	<xsl:template name="merge_declarations">
		<xsl:param name="result_declarations_so_far" as="element()*"/>
		<xsl:param name="lhs_declarations" as="element()*"/>
		<xsl:param name="rhs_declarations" as="element()*"/>
		<xsl:variable name="next_from_lhs" as="element()?">
			<xsl:copy-of select="$lhs_declarations[not(some $var_or_seq in ($lhs_declarations|$rhs_declarations)/type satisfies $var_or_seq/name = ./name)][1]"/>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$next_from_lhs">
				<xsl:variable name="result_next" as="element()*">
					<xsl:copy-of select="$result_declarations_so_far"/>
					<xsl:copy-of select="$next_from_lhs"/>
				</xsl:variable>
				<xsl:call-template name="merge_declarations">
					<xsl:with-param name="result_declarations_so_far" select="$result_next"/>
					<xsl:with-param name="lhs_declarations" select="$lhs_declarations[not(name=$next_from_lhs/name)]"/>
					<xsl:with-param name="rhs_declarations" select="$rhs_declarations"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="next_from_rhs" as="element()?">
					<xsl:copy-of select="$rhs_declarations[not(some $var_or_seq in ($lhs_declarations|$rhs_declarations)/type satisfies $var_or_seq/name = ./name)][1]"/>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="$next_from_rhs">
						<xsl:variable name="result_next" as="element()*">
							<xsl:copy-of select="$result_declarations_so_far"/>
							<xsl:copy-of select="$next_from_rhs"/>
						</xsl:variable>
						<xsl:call-template name="merge_declarations">
							<xsl:with-param name="result_declarations_so_far" select="$result_next"/>
							<xsl:with-param name="lhs_declarations" select="$lhs_declarations"/>
							<xsl:with-param name="rhs_declarations" select="$rhs_declarations[not(name=$next_from_rhs/name)]"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:copy-of select="$result_declarations_so_far"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="postfix_variable_names">
		<xsl:copy>
			<xsl:apply-templates mode="postfix_variable_names"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*:var|*:seq|gat:sequence|gat:decl" mode="postfix_variable_names">
		<xsl:copy>
			<gat:name><xsl:value-of select="gat:name"/>'</gat:name>
			<xsl:apply-templates select="*[not(self::gat:name)]" mode="postfix_variable_names"/>
		</xsl:copy>
	</xsl:template>

	<!--
	<xsl:template match="point" mode="innerReduction">
		<xsl:param name="rule_id"/>
		<xsl:message> innerReduction using rule <xsl:value-of select="$rule_id"/>
		</xsl:message>
		<xsl:for-each select="*[1]">
			<xsl:call-template name="apply_named_rule">
				<xsl:with-param name="ruleid" select="$rule_id"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="*" mode="innerReduction">
		<xsl:param name="rule_id"/>
		<xsl:copy>
			<xsl:apply-templates mode="innerReduction">
				<xsl:with-param name="rule_id" select="$rule_id"/>
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*:var" mode="innerReduction">
		<xsl:param name="rule_id"/>
		<xsl:copy>
			<xsl:apply-templates mode="copy"/>
		</xsl:copy>
	</xsl:template>	
	-->

	<xsl:template match="*" mode="rewrite">
		<xsl:copy>
			<xsl:apply-templates mode="rewrite"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template name="recursive_rewrite">
		<xsl:param name="document" as="element()"/>
		<xsl:message>
			entering recursive_rewrite <xsl:apply-templates select ="$document" mode="text"/>
		</xsl:message>
		<xsl:variable name ="next" as="element()">
			<xsl:for-each select="$document">
				<xsl:apply-templates select="." mode="rewrite"/>
			</xsl:for-each>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="not(deep-equal($document,$next))">
				<xsl:message>rewritten</xsl:message>
				<xsl:call-template name="recursive_rewrite">
					<xsl:with-param name="document" select="$next"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:message>no further rewrites found 
					<xsl:apply-templates select ="$document" mode="text"/>
				</xsl:message>
				<xsl:copy-of select="$document"/>					
			</xsl:otherwise>
		</xsl:choose>
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
			<xsl:call-template name="specialiseTerm">
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


	<!--
	<xsl:template match="*" mode="insert_point_and_remove_ids">
		<xsl:param name="point_id"/>
		<xsl:choose>
			<xsl:when test="@id=$point_id">
				<xsl:message>INSERTING point in node name() <xsl:value-of select="name()"/></xsl:message>
				<point>
					<xsl:copy>
						<xsl:apply-templates mode="cleanse_of_attributes"/>
					</xsl:copy>
				</point>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy>
					<xsl:apply-templates mode="insert_point_and_remove_ids">
						<xsl:with-param name="point_id" select="$point_id"/>
					</xsl:apply-templates>
				</xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="extract_subterm_at_point">
		<xsl:apply-templates select="*[not(self::*:var|self::*:seq)]" mode="extract_subterm_at_point"/>
	</xsl:template>

	<xsl:template match="point" mode="extract_subterm_at_point">
		<xsl:copy-of select="*"/>
	</xsl:template>

	<xsl:template match="point" mode="remove_point">
		<xsl:apply-templates mode="copy"/>
	</xsl:template>
-->

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
