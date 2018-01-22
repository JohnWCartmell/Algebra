<xsl:transform version="2.0" 
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:gat              ="http://www.entitymodelling.org/theory/generalisedalgebraictheory"
		xpath-default-namespace="http://www.entitymodelling.org/theory/generalisedalgebraictheory"	   
		                  xmlns="http://www.entitymodelling.org/theory/generalisedalgebraictheory">

	<xsl:strip-space elements="*"/> 

	<xsl:template match="*" mode="normalise">
	    <xsl:message>copying <xsl:value-of select="name()"/> </xsl:message>
		<xsl:copy>
		    <xsl:copy-of select="namespace::*"/>
			<xsl:apply-templates mode="normalise"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="term" mode="normalise">
		<xsl:copy>
			<xsl:call-template name="recursive_rewrite">
				<xsl:with-param name="document">
					<xsl:apply-templates select="*" mode="rewrite"/>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:copy>
	</xsl:template>

	<xsl:template match = "/" mode="prepare_diamonds">
		<xsl:apply-templates mode="prepare_diamonds"/>
	</xsl:template>

	<xsl:template match="algebra" mode="prepare_diamonds">
	   <xsl:copy>
	    <xsl:copy-of select="namespace::*"/>
		<xsl:message>Node <xsl:value-of select="name()"/> </xsl:message>
		<!-- find branches -->
		<xsl:variable name="algebra_name" select="name"/>
		<xsl:for-each select="rewriteRule">
			<xsl:variable name="inner_rule_id" select="concat($algebra_name,id)"/>
			<innerTerm>    
				<id>
					<xsl:value-of select="$inner_rule_id"/>
				</id>
				<term>
					<xsl:apply-templates select="lhs/*" mode="text"/>
				</term>
				<xsl:variable name="innerTerm" select="lhs/*"/>
				<xsl:for-each select="../rewriteRule/lhs/*">
					<xsl:variable name="outer_rule_id" select="concat($algebra_name,../../id)"/>
					<xsl:variable name="results">
						<xsl:apply-templates select="." mode="get_instances_of">
							<xsl:with-param name="target" select="$innerTerm"/>
						</xsl:apply-templates>
					</xsl:variable>
					<xsl:if test="count($results/*) != 0">
						<outerTerm>
							<id>
								<xsl:value-of select="$outer_rule_id"/>
							</id>
							<term>
								<xsl:apply-templates select="." mode="text"/>
							</term>
							<xsl:variable name="outerTerm" select="."/>
							<xsl:for-each select="$results/result">
								<diamond>
									<!--<xsl:copy-of select="$results/result/*"/>-->
									<top_of_diamond>
										<xsl:apply-templates select="pointed_lhs_specialised" mode="text"/>
									</top_of_diamond>
									<xsl:message> Top of diamond <xsl:copy-of select="pointed_lhs_specialised"/>
									</xsl:message>
									<!--outerTerm-->
									<xsl:variable name="left_reduction">
										<term>
											<xsl:for-each select="lhs_specialised/*">
												<xsl:call-template name="apply_named_rule">
													<xsl:with-param name="ruleid" select="$outer_rule_id"/>
												</xsl:call-template> 
											</xsl:for-each>
										</term>
									</xsl:variable>
									<leftreduction>
										<xsl:apply-templates select="$left_reduction" mode="text"/>
									</leftreduction>
									<!-- inner Term -->
									<xsl:variable name="right_reduction">
										<term>
											<xsl:for-each select="pointed_lhs_specialised">
												<xsl:message>Inner rule is <xsl:value-of select="$inner_rule_id"/>
												</xsl:message>
												<xsl:apply-templates mode="innerReduction">
													<xsl:with-param name="rule_id" select="$inner_rule_id"/>
												</xsl:apply-templates> 
											</xsl:for-each>
										</term>
									</xsl:variable>
									<rightreduction>
										<xsl:apply-templates select="$right_reduction" mode="text"/>
									</rightreduction>
									<xsl:variable name="leftReductionNormalised">
										<xsl:call-template name="recursive_rewrite">
											<xsl:with-param name="document">
												<xsl:apply-templates select="$left_reduction" mode="rewrite"/>
											</xsl:with-param>
										</xsl:call-template>
									</xsl:variable>
									<xsl:variable name="lhscost" as="xs:double">
										<xsl:apply-templates select="$leftReductionNormalised" mode="number"/>
									</xsl:variable>
									<leftReductionNormalised>
										<xsl:apply-templates select="$leftReductionNormalised" mode="text"/>
										<xsl:text>{</xsl:text>
										<xsl:value-of select="$lhscost"/>
										<xsl:text>}</xsl:text>
									</leftReductionNormalised>
									<xsl:message>normalise rhs reduction</xsl:message>
									<xsl:variable name="rightReductionNormalised">
										<xsl:call-template name="recursive_rewrite">
											<xsl:with-param name="document">
												<xsl:apply-templates select="$right_reduction" mode="rewrite"/>
											</xsl:with-param>
										</xsl:call-template>
									</xsl:variable>
									<xsl:variable name="rhscost" as="xs:double">
										<xsl:apply-templates select="$rightReductionNormalised" mode="number"/>
									</xsl:variable>
									<rightReductionNormalised>
										<xsl:apply-templates select="$rightReductionNormalised" mode="text"/>
										<xsl:text>{</xsl:text>
										<xsl:value-of select="$rhscost"/>
										<xsl:text>}</xsl:text>
									</rightReductionNormalised>
									<xsl:if test="not(deep-equal($leftReductionNormalised,$rightReductionNormalised))">
										<NON-CONFLUENT/>
										<xsl:if test="$lhscost=$rhscost">
											<STALEMATE/>
										</xsl:if>
										<xsl:if test="$lhscost &lt; $rhscost">
											<RIGHT-TO-LEFT/>
										</xsl:if>
										<xsl:if test="$rhscost &lt; $lhscost">
											<LEFT-TO-RIGHT/>
										</xsl:if>
										<xsl:message>*************  NON CONFLUENT ************</xsl:message>
									</xsl:if>
								</diamond>
							</xsl:for-each>
						</outerTerm>  
					</xsl:if>
				</xsl:for-each>
			</innerTerm> 
		</xsl:for-each>
		</xsl:copy>
	</xsl:template>

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

	<xsl:template match="*" mode="rewrite">
		<xsl:copy>
			<xsl:apply-templates mode="rewrite"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template name="recursive_rewrite">
		<xsl:param name="document"/>
		<xsl:variable name ="next">
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
  -->
	<xsl:template match="*" mode="get_instances_of">
		<xsl:param name="target"/>
		<!-- First look for specialisations (i.e. substuituitional instances) of the current term -->
		<xsl:variable name="substitutions">
			<xsl:call-template name="specialiseTerm">
				<xsl:with-param name="targetTerm" select="$target"/>
			</xsl:call-template>
		</xsl:variable> 
		<xsl:variable name="point_id" select="generate-id()"/>
		<xsl:variable name="ancestor_lhs" select="ancestor-or-self::lhs/*[1]"/>
		<!-- If found then add to the output stream -->
		<xsl:for-each select="$substitutions/substitution">
			<xsl:message> AT HERE </xsl:message>
			<xsl:if test="not(self::INCOMPATIBLE)">
				<result>
					<xsl:copy-of select="."/>
					<xsl:variable name="lhs_as_pointedTerm">
						<xsl:apply-templates select="$ancestor_lhs" mode="insert_point">
							<xsl:with-param name="substitutions" select="."/>
							<xsl:with-param name="point_id" select="$point_id" />
						</xsl:apply-templates>
					</xsl:variable>
					<xsl:message>lhs_as_pointed_term <xsl:copy-of select="$lhs_as_pointedTerm"/>
					</xsl:message>
					<!--COPY the ancestor term with the result substitutions and mark application_node_id -->
					<xsl:variable name="lhs_specialised">
						<xsl:apply-templates select="$ancestor_lhs" mode="substitution">
							<xsl:with-param name="substitutions" select="."/>
						</xsl:apply-templates>
					</xsl:variable>
					<xsl:variable name="pointed_lhs_specialised">
						<xsl:apply-templates select="$lhs_as_pointedTerm" mode="substitution">
							<xsl:with-param name="substitutions" select="."/>
						</xsl:apply-templates>
					</xsl:variable>
					<lhs_specialised>
						<xsl:copy-of select="$lhs_specialised"/>
					</lhs_specialised>
					<pointed_lhs_specialised>
						<xsl:copy-of select="$pointed_lhs_specialised"/>
					</pointed_lhs_specialised>
				</result>
			</xsl:if>
		</xsl:for-each>
		<!-- Next do the same for all subterms (recursively) -->
		<xsl:apply-templates mode="get_instances_of">
			<xsl:with-param name="target" select="$target"/>
		</xsl:apply-templates>
	</xsl:template>  

	<xsl:template match="*" mode="insert_point">
		<xsl:param name="point_id"/>
		<xsl:choose>
			<xsl:when test="generate-id()=$point_id">
				<xsl:message>INSERTING point </xsl:message>
				<point>
					<xsl:copy-of select="."/>
				</point>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy>
					<xsl:apply-templates mode="insert_point">
						<xsl:with-param name="point_id" select="$point_id"/>
					</xsl:apply-templates>
				</xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template match="point" mode="remove_point">
		<xsl:apply-templates mode="copy"/>
	</xsl:template>

	<xsl:template match="*:var|*:seq" mode="get_instances_of">
		<!-- don't want a result from a variable or sequence matching whole lhs term-->
	</xsl:template>     


</xsl:transform>

