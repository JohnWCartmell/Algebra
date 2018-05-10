<!-- 
Description
 This is module is responsible for generic aspects of type enrichment
 
 -->


<xsl:transform version="2.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:gat              ="http://www.entitymodelling.org/theory/generalisedalgebraictheory"
		xmlns:cc               ="http://www.entitymodelling.org/theory/contextualcategory"
		xmlns:ccseq="http://www.entitymodelling.org/theory/contextualcategory/sequence"
		xpath-default-namespace="http://www.entitymodelling.org/theory/generalisedalgebraictheory"	   
		xmlns="http://www.entitymodelling.org/theory/generalisedalgebraictheory"
		exclude-result-prefixes="ccseq cc gat">

	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

	<xsl:template name="specialise_to_correct_typing">
		<xsl:param name="tT-ruleTypeEnriched" as="element(tT-rule)"/>
		<xsl:message>Entering specialise_to_correct_typing </xsl:message>

		<xsl:if test="not($tT-ruleTypeEnriched/tT-conclusion/term/*)">
			<xsl:message>
				<xsl:copy-of select="$tT-ruleTypeEnriched/tT-conclusion"/>
			</xsl:message>
			<xsl:message terminate="yes">OUT-OF-SPEC</xsl:message>
		</xsl:if>
		<xsl:variable name="termInitial" as="element()" select="$tT-ruleTypeEnriched/tT-conclusion/term/*"/>
		<xsl:choose>
			<xsl:when test="$termInitial/descendant::illformed">
				<xsl:message>Bail out of type correction - cant be done</xsl:message>
			</xsl:when>
			<xsl:when test="$termInitial/descendant::lacking_type_information">
				<xsl:message>Bail out of type correction - lacking type information </xsl:message>
			</xsl:when>
			<xsl:when test="$termInitial/descendant::type_error/need-equal">
				<xsl:message>Found need- equaltype errors in initial term: </xsl:message>
				<xsl:variable name="lhs_error_terms" as="element(tail)">
					<gat:tail>
						<xsl:for-each select="$termInitial/descendant::type_error/need-equal/lhs/*">
							<ccseq:s>
								<xsl:apply-templates select="." mode="remove_gat_annotations"/>
							</ccseq:s>
						</xsl:for-each>
					</gat:tail>
				</xsl:variable>
				<xsl:variable name="rhs_error_terms" as="element(tail)">
					<gat:tail>			
						<xsl:for-each select="$termInitial/descendant::type_error/need-equal/rhs/*">
							<ccseq:s>
								<xsl:apply-templates select="." mode="remove_gat_annotations"/>
							</ccseq:s>
						</xsl:for-each>
					</gat:tail>
				</xsl:variable>
				<xsl:message> Dealing with type errors:[[[ </xsl:message>
				<xsl:for-each select="$termInitial/descendant::type_error">
					<xsl:message>
						<xsl:apply-templates select="description" mode="text"/> 
					</xsl:message>
				</xsl:for-each>
				<xsl:message> ]]]</xsl:message>
				<xsl:for-each select="$lhs_error_terms">
					<xsl:variable name="specialisation_results" as="element()*">
						<xsl:call-template name="unifyTermsConsistentWithContext">
							<xsl:with-param name="targetTerm" select="$rhs_error_terms"/>
							<!--<xsl:with-param name="targetTerm" select="$rhs/*"/>-->
							<xsl:with-param name="context" select="$tT-ruleTypeEnriched/context"/>
						</xsl:call-template>
					</xsl:variable>  			   
					<xsl:choose>
						<xsl:when test="not($specialisation_results)">
							<xsl:message terminate="yes">This can't happen can it?</xsl:message>
						</xsl:when>
						<xsl:when test="$specialisation_results[self::incompatible]">
							<xsl:message>Cannot specialise diamond to be well-typed </xsl:message>
							<gat:result>
								<xsl:copy-of select="$specialisation_results"/>
							</gat:result>
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
									<!-- !!! just doing the first one !!! -->
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
							<xsl:variable name="further_improvement" as="element(result)?">
								<xsl:call-template name="specialise_to_correct_typing">
									<xsl:with-param name="tT-ruleTypeEnriched" select="$typeImprovedRuleTypeEnriched"/>
								</xsl:call-template>  
							</xsl:variable>			
							<xsl:message>End of recurse into type correction</xsl:message>							
							<!-- return composed substitutions -->
							<xsl:choose>
								<xsl:when test="$further_improvement">
									<gat:result>
										<xsl:copy-of select="$further_improvement/term"/>
										<xsl:apply-templates select="$further_improvement/substitution" mode="compose_substitutions">
											<xsl:with-param name="head_substitution" select="$specialisation_results[1]"/>
										</xsl:apply-templates>
									</gat:result>									
								</xsl:when>	
								<xsl:otherwise>
									<xsl:message>Bailing out of type correction</xsl:message>							
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</xsl:when>
			<xsl:when test="not($termInitial/gat:type)">
				<xsl:message>termInitial <xsl:copy-of select="$termInitial"/></xsl:message>
				<xsl:message terminate="yes">No errors spotted but no type nontheless for termInitial</xsl:message>
			</xsl:when>			 
			<xsl:otherwise>
				<xsl:message>End of type correction with identity sub</xsl:message>
				<!-- empty (identity) substitution -->
				<gat:result>
					<gat:term>
						<xsl:copy-of select="$termInitial"/>
					</gat:term>
					<gat:substitution>
						<gat:subject/>
						<gat:target/>
					</gat:substitution>
				</gat:result>
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
				<gat:incompatible>
					<gat:subject><xsl:copy-of select="."/></gat:subject>
					<gat:target><xsl:copy-of select="$targetTerm"/></gat:target>
				</gat:incompatible>
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
								<xsl:message>context <xsl:apply-templates select="$context" mode="text"/></xsl:message>
								<xsl:message>substitution <xsl:apply-templates select="." mode="text"/></xsl:message>
								<xsl:message>targetTerm <xsl:apply-templates select="$targetTerm" mode="text"/></xsl:message>
								
							<xsl:message >Avoiding dependency cycle </xsl:message>
							<gat:incompatible>
								Avoiding dependency cycle
							</gat:incompatible>
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


	<xsl:template match="*[self::context]" mode="remove_gat_annotations">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates select="*" mode="remove_gat_annotations"/>
		</xsl:copy>
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

	<xsl:template match="*[self::decl|self::sequence]" mode="remove_gat_annotations">
		<!-- need to keeep gat:type and gat:name for decl and for sequence however -->
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:copy-of select="gat:name"/>
			<xsl:apply-templates select="gat:type" mode="remove_gat_annotations"/>
			<xsl:apply-templates select="*[not(self::gat:*)]" mode="remove_gat_annotations"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="/" mode="type_enrich">
		<xsl:for-each select="gat:algebra">
			<xsl:copy>
				<xsl:copy-of select="namespace::*"/>
				<xsl:apply-templates select="gat:*" mode="type_enrich"/>
			</xsl:copy>
		</xsl:for-each>
	</xsl:template>
	

	<xsl:template match="tT-rule|rewriteRule" mode="type_enrich">
	    <xsl:message>Type enriching  rule <xsl:value-of select="gat:id"/></xsl:message>
		<xsl:copy>
			<xsl:apply-templates  mode="type_enrich"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="*" mode="type_enrich">
		<xsl:copy>
			<xsl:apply-templates  mode="type_enrich"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="tT-rule|tt-rule" mode="type_enrich">
		<xsl:variable name="empty_context" as="element(context)">
			<gat:context/>
		</xsl:variable>
		<xsl:variable name="type_enriched_context" as="element(context)">
			<xsl:apply-templates select="context" mode="type_enrich_context">
				<xsl:with-param name="contextsofar" select="$empty_context"/>
			</xsl:apply-templates>
		</xsl:variable>
		<xsl:variable name="type_enriched_conclusion" as="element()">
			<xsl:call-template name="initial_enrichment_recursive">
				<xsl:with-param name="interim" select="tT-conclusion|tt-conclusion"/>
				<xsl:with-param name="context" select="$type_enriched_context"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:copy>
			<xsl:copy-of select="$type_enriched_context"/>
			<xsl:copy-of select="$type_enriched_conclusion"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="context" mode="type_enrich_context">
		<xsl:param name="contextsofar" as="element(context)"/>
		<xsl:choose>
			<xsl:when test="count(*[self::gat:decl|self::gat:sequence])=count($contextsofar/*[self::gat:decl|self::gat:sequence])">
				<xsl:copy-of select="$contextsofar"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="next" as="element()" select="*[self::gat:decl|self::gat:sequence][count($contextsofar/*[self::gat:decl|self::gat:sequence])+1]"/>
				<xsl:variable name="next_enriched" as="element()">
					<xsl:apply-templates select="$next" mode="initial_enrichment_recursive">
						<xsl:with-param name="context" select="$contextsofar"/>
					</xsl:apply-templates>
				</xsl:variable>
				<xsl:variable name="context_extended" as="element(context)">
					<gat:context>
						<xsl:copy-of select="$contextsofar/*[self::gat:decl|self::gat:sequence]"/>
						<xsl:copy-of select="$next_enriched"/>
					</gat:context>
				</xsl:variable>
				<xsl:apply-templates select="." mode="type_enrich_context">
					<xsl:with-param name="contextsofar" select="$context_extended"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*[self::*:var][not(gat:type)]" mode="initial_enrichment_recursive" priority="100">
		<xsl:param name="context" as="element(context)"/>
		<xsl:copy>  
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="initial_enrichment_recursive">
				<xsl:with-param name="context" select="$context"/>
			</xsl:apply-templates>
			<xsl:choose>
				<xsl:when test="$context/decl[name=current()/name]">
					<xsl:apply-templates mode="normalise" 
							select="$context/decl[name=current()/name]/type"/>
				</xsl:when>		
				<xsl:when test="(ancestor::decl|ancestor::sequence)/following-sibling::decl[name=current()/name]">
					<xsl:message terminate="yes">var <xsl:value-of select="name"/> doesn't have a type in earlier part of context but has one in later part of context</xsl:message>
				</xsl:when>
				<xsl:otherwise>
					<!-- untyped variable -->
				</xsl:otherwise>
			</xsl:choose>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*[self::*:seq][not(gat:type)]" mode="initial_enrichment_recursive" priority="100">
		<xsl:param name="context" as="element(context)"/>
		<xsl:copy>  
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="initial_enrichment_recursive">
				<xsl:with-param name="context" select="$context"/>
			</xsl:apply-templates>
			<xsl:choose>
				<xsl:when test="$context/sequence[name=current()/name]">
					<xsl:apply-templates mode="normalise" 
							select="$context/sequence[name=current()/name]/type"/>
				</xsl:when>		
				<xsl:when test="(ancestor::decl|ancestor::sequence)/following-sibling::sequence[name=current()/name]">
				    <xsl:variable name="identity" select="ancestor::*/gat:id"/>
					<xsl:message terminate="yes">seq  <xsl:value-of select="name"/> in <xsl:value-of select="$identity"/>doesn't have a type in earlier part of context but has one in later part of context</xsl:message>
				</xsl:when>
				<xsl:otherwise>
					<!-- untyped variable -->
				</xsl:otherwise>
			</xsl:choose>
		</xsl:copy>
	</xsl:template>

	<xsl:template name="initial_enrichment_recursive">
		<xsl:param name="interim" as="element()"/>
		<xsl:param name="context" as="element()"/>
		<xsl:variable name ="next" as="element()">
			<xsl:for-each select="$interim">
				<xsl:copy>
					<xsl:apply-templates mode="initial_enrichment_recursive">
						<xsl:with-param name="context" select="$context"/>
					</xsl:apply-templates>
				</xsl:copy>
			</xsl:for-each>
		</xsl:variable>
		<xsl:variable name="result" as="element()">
			<xsl:choose>
				<xsl:when test="not(deep-equal($interim,$next))">
					<xsl:call-template name="initial_enrichment_recursive">
						<xsl:with-param name="interim" select="$next"/>
						<xsl:with-param name="context" select="$context"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:copy-of select="$interim"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>  
		<xsl:copy-of select="$result"/>
	</xsl:template>

	<xsl:template match="*"
			mode="initial_enrichment_recursive"> 
		<xsl:param name="context" as="element()"/>
		<xsl:copy copy-namespaces="no">
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="initial_enrichment_recursive">
				<xsl:with-param name="context" select="$context"/>
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="gat:type_error"
			mode="initial_enrichment_recursive"> 
		<xsl:param name="context" as="element()"/>
		<xsl:copy-of select="."/>
	</xsl:template>

</xsl:transform>
