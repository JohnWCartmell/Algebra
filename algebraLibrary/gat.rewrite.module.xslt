<xsl:transform version="2.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:gat              ="http://www.entitymodelling.org/theory/generalisedalgebraictheory"
		xpath-default-namespace="http://www.entitymodelling.org/theory/generalisedalgebraictheory"	   
		xmlns="http://www.entitymodelling.org/theory/generalisedalgebraictheory"
		exclude-result-prefixes="xs gat">

	<xsl:strip-space elements="*"/> 
	<xsl:template match="*" mode="diamond_filter">
		<xsl:copy>
			<xsl:apply-templates mode="diamond_filter"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="gat:diamond
			[not(most_generalising_tops/most_generalising_top
			[right_reduction_more_general
			and 
			left_reduction_more_general
			]
			)
			]" mode="diamond_filter">
		<xsl:message>Keeping <xsl:value-of select="identity"/></xsl:message>
		<xsl:copy>
			<xsl:copy-of select="*[not(self::most_generalising_tops)]"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="gat:diamond
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




	<xsl:template match="*" mode="type_correction">
		<xsl:copy>
			<xsl:apply-templates mode="type_correction"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="gat:diamond" mode="type_correction">
		<xsl:copy>
			<!--<xsl:copy-of select="*"/>-->
			<xsl:copy-of select="gat:identity"/>
			<gat:from_outer_id>
				<xsl:value-of select="from/outer/id"/>
			</gat:from_outer_id>
			<gat:from_inner_id>
				<xsl:value-of select="from/inner/id"/>
			</gat:from_inner_id>

			<gat:type_corrected>
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

				<xsl:message>firstCutTopOfDiamondRuleTypeEnriched <xsl:apply-templates select="$firstCutTopOfDiamondRuleTypeEnriched" mode="text"/>
				</xsl:message>

				<xsl:variable name="typeCorrectionSubstitution" as="element(substitution)?">
					<xsl:call-template name="specialise_to_correct_typing">
						<xsl:with-param name="tT-ruleTypeEnriched" select="$firstCutTopOfDiamondRuleTypeEnriched"/>
					</xsl:call-template>
				</xsl:variable> 

				<xsl:choose>						
					<xsl:when test="$typeCorrectionSubstitution">	
						<gat:top_of_diamond>
							<xsl:apply-templates select="$firstCutTopOfDiamondRule" mode="substitution">
								<xsl:with-param name="substitutions" select="$typeCorrectionSubstitution"/>
							</xsl:apply-templates>  
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
						<gat:ABANDONED/>
					</xsl:otherwise>
				</xsl:choose>
			</gat:type_corrected>
		</xsl:copy>
	</xsl:template>


	<xsl:template match="*[self::gat:*][not(self::gat:term)][not(self::gat:type)]" mode="normalise">
		<xsl:message> THIS "normailise" template is only used from normalisation unit test</xsl:message>
		<xsl:copy>
			<xsl:copy-of select="namespace::*"/>
			<xsl:apply-templates mode="normalise"/>
		</xsl:copy>
	</xsl:template>


	<xsl:template match="gat:type" mode="normalise">  

		<xsl:copy>
			<xsl:call-template name="recursive_rewrite">
				<xsl:with-param name="document" select="*"/> 
			</xsl:call-template>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="gat:term" mode="normalise">  
		<xsl:copy>
			<xsl:call-template name="recursive_rewrite">
				<xsl:with-param name="document" select="*"/> 
			</xsl:call-template>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*[not(self::gat:*)]" mode="normalise"> 
		<xsl:call-template name="recursive_rewrite">
			<xsl:with-param name="document" select="."/> 
		</xsl:call-template>
	</xsl:template>



	<xsl:template name="specialise_to_correct_typing">
		<xsl:param name="tT-ruleTypeEnriched" as="element(tT-rule)"/>

		<xsl:message>Entering type correction </xsl:message>
		<xsl:if test="not($tT-ruleTypeEnriched/tT-conclusion/term/*)">
			<xsl:message>
				<xsl:copy-of select="$tT-ruleTypeEnriched/tT-conclusion"/>
			</xsl:message>
			<xsl:message terminate="yes">OUT-OF-SPEC</xsl:message>
		</xsl:if>
		<xsl:variable name="termInitial" as="element()" select="$tT-ruleTypeEnriched/tT-conclusion/term/*"/>

		<xsl:variable name="first_type_error" select="$termInitial/descendant::type_error[1]" as="element(type_error)?"/>
		<xsl:choose>
			<xsl:when test="$termInitial/descendant::illformed">
				<xsl:message>Bail out of type correction - cant be done</xsl:message>
			</xsl:when>
			<xsl:when test="$termInitial/descendant::lacking_type_information">
				<xsl:message>Bail out of type correction - lacking type information </xsl:message>
			</xsl:when>
			<xsl:when test="$first_type_error">
				<xsl:message>Found type errors in initial term: </xsl:message>
				<!--
				<xsl:message>          <xsl:value-of select="$termInitial/descendant::type_error"/> </xsl:message>
				-->
				<xsl:message> Dealing with type error <xsl:value-of select="$first_type_error/description"/>
				</xsl:message>
				<xsl:variable name="lhs" as="element()">
					<xsl:apply-templates select="$first_type_error/need-equal/lhs" mode="remove_gat_annotations"/>
				</xsl:variable>
				<xsl:variable name="rhs" as="element()">
					<xsl:apply-templates select="$first_type_error/need-equal/rhs" mode="remove_gat_annotations"/>
				</xsl:variable>
				<xsl:for-each select="$lhs/*"> 
					<xsl:variable name="specialisation_results" as="element()*">
						<xsl:call-template name="unifyTermsConsistentWithContext">
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
							<xsl:if test="count($specialisation_results) &gt; 1">
								<xsl:message>Number of ways to correct type error: <xsl:value-of select="count($specialisation_results)"/>
								</xsl:message>
							</xsl:if>
							<xsl:message>Applying type correction substitution <xsl:apply-templates select="$specialisation_results[1]" mode="text"/>
							</xsl:message>						
							<xsl:variable name="typeImprovedtT-rule" as="element(tT-rule)">   
								<xsl:apply-templates select="$tT-ruleTypeEnriched" mode="substitution">
									<xsl:with-param name="substitutions" select="$specialisation_results[1]"/>
									<!-- just do the first one -->
								</xsl:apply-templates>  
							</xsl:variable>
							<xsl:if test="not($typeImprovedtT-rule/tT-conclusion/term/*)">
								<xsl:message>
									<xsl:copy-of select="$typeImprovedtT-rule/tT-conclusion"/>
								</xsl:message>
								<xsl:message terminate="yes">OUT-OF-SPEC</xsl:message>
							</xsl:if>
							<xsl:message>Now cleanse and type enrich  </xsl:message>
							<xsl:variable name="typeImprovedRuleTypeEnriched" as="element(tT-rule)">
								<xsl:apply-templates 	select="$typeImprovedtT-rule" mode="cleanse_and_type_enrich"/>
							</xsl:variable>
							<xsl:if test="$typeImprovedRuleTypeEnriched/descendant::illformed">
								<xsl:message>************illformed on return from type enrichment during type correction</xsl:message>
							</xsl:if>
							<xsl:if test="not($typeImprovedRuleTypeEnriched/tT-conclusion/term/*)">
								<xsl:message>
									<xsl:copy-of select="$typeImprovedtT-rule/tT-conclusion"/>
								</xsl:message>
								<xsl:message terminate="yes">OUT-OF-SPEC</xsl:message>
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
				<gat:substitution>
					<gat:subject/>
					<gat:target/>
				</gat:substitution>
				<!--<xsl:copy-of select="$tT-ruleTypeEnriched"/>-->
			</xsl:otherwise>
		</xsl:choose>  
	</xsl:template>


	<xsl:template name="unifyTermsConsistentWithContext">
		<xsl:param name="targetTerm" as="element()"/>
		<xsl:param name="context" as="element(context)"/>

		<xsl:variable name="specialisations" as="element()*">
			<xsl:call-template name="unifyTerms">
				<xsl:with-param name="subjectTerm" select="."/>
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
						<xsl:message terminate="yes">Assertion failuure <xsl:value-of select="name()"/>
						</xsl:message>
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
			<xsl:copy-of select="gat:name"/>
			<!-- only applicable to var's and seq's -->
			<xsl:apply-templates select="*[not(self::gat:*)]" mode="remove_gat_annotations"/>
		</xsl:copy>
	</xsl:template>


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



	<xsl:template match="*" mode="rewrite">
		<xsl:copy>
			<xsl:apply-templates mode="rewrite"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="gat:type_error" mode="rewrite">
	</xsl:template>


	<xsl:template name="recursive_rewrite">
		<xsl:param name="document" as="element()"/>
		<xsl:variable name ="next" as="element()">
			<xsl:for-each select="$document">
				<xsl:apply-templates select="." mode="rewrite"/>
			</xsl:for-each>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="not(deep-equal($document,$next))">
				<xsl:call-template name="recursive_rewrite">
					<xsl:with-param name="document" select="$next"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
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
