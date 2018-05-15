<xsl:transform version="2.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:gat              ="http://www.entitymodelling.org/theory/generalisedalgebraictheory"
		xpath-default-namespace="http://www.entitymodelling.org/theory/generalisedalgebraictheory"	   
		xmlns="http://www.entitymodelling.org/theory/generalisedalgebraictheory">

	<xsl:strip-space elements="*"/> 

	<!-- gat.substitution.module.xslt-->

	<!-- mode="substitution" applies a substitution -->
	<!-- primarily a substitution is applied to a term but
       equally it can be applied to a substitution or a context.
	   
	   When a substitution is applied to a context then wish to keep original type if the substituted 
	   variable doesn't have a type. 
    -->

	<xsl:template match="*" mode="substitution">
		<xsl:param name="substitutions" as="element(substitution)"/>
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates  mode="substitution">
				<xsl:with-param name="substitutions" select="$substitutions"/>
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="type_error" mode="substitution">
		<xsl:param name="substitutions" as="element(substitution)"/>
		<!-- no action -->
	</xsl:template>

	<xsl:template match="context" mode="substitution">  
		<xsl:param name="substitutions" as="element(substitution)"/>
		<xsl:variable name="context" as="element(context)" select="."/>

		<xsl:variable name="varlike_substituting_terms" as="element()*" select="$substitutions/(subject|target)/substitute[count(term/*)=1 and term/*[self::*:var|self::*:seq]] /(*:var|*:seq)"/>

		<xsl:variable name="declikes_substituted_by_varlike" as="element()*" select="./*[some $varlike in $varlike_substituting_terms satisfies $varlike/name=name]"/>

		<xsl:variable name="firstcut_context" as="element(context)">
			<xsl:copy>
				<xsl:apply-templates  mode="substitution_into_context">
					<xsl:with-param name="substitutions" select="$substitutions"/>
					<xsl:with-param name="context" select="."/>
				</xsl:apply-templates>          
			</xsl:copy>
		</xsl:variable>
		<!-- now use 'merge_declarations' sort the decls into an order consistent with their inter-dependencies -->
		<xsl:variable name="declarations_with_duplicates_removed" as="element()*">
			<xsl:call-template name="remove_duplicate_declarations">
				<xsl:with-param name="declarations_so_far" select="()"/>
				<xsl:with-param name="declarations" select="$firstcut_context/*"/>
			</xsl:call-template>
		</xsl:variable>
		<gat:context>
			<xsl:call-template name="merge_declarations">
				<xsl:with-param name="result_declarations_so_far" select="()"/>
				<xsl:with-param name="lhs_declarations" 
						select="$declarations_with_duplicates_removed"/>
				<xsl:with-param name="rhs_declarations" select="()"/>
			</xsl:call-template>
		</gat:context>
	</xsl:template>

	<xsl:template name="remove_duplicate_declarations">
		<xsl:param name="declarations_so_far" as="element()*"/>
		<xsl:param name="declarations" as="element()*"/>

		<xsl:variable name="next_decl" as="element()?" select="$declarations[1]"/>
		<xsl:choose>
			<xsl:when test="not($next_decl)">
				<xsl:copy-of select="$declarations_so_far"/>
			</xsl:when>
			<xsl:otherwise>
			    <xsl:if test="count($declarations[position() &gt; 1] [self::*:decl|self::*:sequence][name=$next_decl/name]) &gt; 1">
				    <xsl:message> Multiple copies of <xsl:copy-of select="$declarations[position() &gt; 1] [self::*:decl|self::*:sequence][name=$next_decl/name]"/></xsl:message>
				</xsl:if>
				<xsl:variable name="duplicate_named_earlier_decl" as="element()?" select="$declarations_so_far[self::*:decl|self::*:sequence][name=$next_decl/name]"/>
				<xsl:variable name="duplicate_named_later_decl" as="element()?" select="$declarations[position() &gt; 1] [self::*:decl|self::*:sequence][name=$next_decl/name][1]"/> 
				<xsl:choose>
					<xsl:when test="$duplicate_named_earlier_decl
							or 
							($duplicate_named_later_decl and  count( $duplicate_named_later_decl/type/descendant::*) &gt; count( $next_decl/type/descendant::*))
							">
						<!-- drop in favour of either earlier or later and deeper -->
						<xsl:call-template name="remove_duplicate_declarations">
							<xsl:with-param name="declarations_so_far" select="$declarations_so_far"/>
							<xsl:with-param name="declarations" select="$declarations[position() &gt; 1]"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:variable name="result_next" as="element()*">
							<xsl:copy-of select="$declarations_so_far"/>
							<xsl:copy-of select="$next_decl"/>
						</xsl:variable>
						<xsl:call-template name="remove_duplicate_declarations">
							<xsl:with-param name="declarations_so_far" select="$result_next"/>
							<xsl:with-param name="declarations" select="$declarations[position() &gt; 1]"/>
						</xsl:call-template>

					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="merge_declarations">
		<xsl:param name="result_declarations_so_far" as="element()*"/>
		<xsl:param name="lhs_declarations" as="element()*"/>
		<xsl:param name="rhs_declarations" as="element()*"/>
		<xsl:variable name="next_from_lhs" as="element()?">
			<xsl:copy-of select="$lhs_declarations[not(some $var_or_seq in $lhs_declarations|$rhs_declarations, 
					$depended_on_var_or_seq in ./type/(descendant::*:var|descendant::*:seq)
					satisfies $var_or_seq/name = $depended_on_var_or_seq/name)
					]
					[1]"/>
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
					<xsl:copy-of select="$rhs_declarations[not(some $var_or_seq in $lhs_declarations|$rhs_declarations, 
							$depended_on_var_or_seq in ./type/(descendant::*:var|descendant::*:seq)
							satisfies $var_or_seq/name = $depended_on_var_or_seq/name)
							]
							[1]"/>
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


	<xsl:template match="*:decl" mode="substitution_into_context">  
		<xsl:param name="substitutions" as="element(substitution)"/>
		<xsl:param name="context" as="element(context)"/>
		<xsl:variable name="substituting_term" as="element(term)?" select="$substitutions/(subject|target)/substitute[*:var/name = current()/name]/term"/>
		<xsl:variable name="substituting_var" as="element()?" select="$substituting_term/*:var"/>
		<xsl:variable name="decllike_of_substituting_var" as="element()?" select="$context/*:decl[name=$substituting_var/name]"/>
		<xsl:choose>
			<xsl:when test="$substituting_term and not($substituting_var)">
				<!-- omit this decl -->
			</xsl:when>
			<xsl:otherwise>
				<!-- in the case that a decl is being substituted by a var then we will get a duplicate but this is resolved at the context level in a second pass -->
				<xsl:copy>
					<xsl:copy-of select="if($substituting_var) 
							then $substituting_var/name 
							else name"/>
					<xsl:apply-templates select="type" mode="substitution">
						<xsl:with-param name="substitutions" select="$substitutions"/>
					</xsl:apply-templates>          
				</xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*:sequence" mode="substitution_into_context">  
		<xsl:param name="substitutions" as="element(substitution)"/>
		<xsl:param name="context" as="element(context)"/>
		<xsl:choose>
			<xsl:when test="some $seq in $substitutions/(subject|target)/substitute/*:seq satisfies $seq/name = ./name">
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy>
					<xsl:copy-of select="name"/>
					<xsl:apply-templates select="type" mode="substitution">
						<xsl:with-param name="substitutions" select="$substitutions"/>
					</xsl:apply-templates>          
				</xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*:var" mode="substitution">  
		<xsl:param name="substitutions" as="element(substitution)"/>
		<xsl:choose>
			<xsl:when test="some $var in $substitutions/(subject|target)/substitute/*:var satisfies $var/name = ./name">
				<xsl:apply-templates select="$substitutions/(subject|target)/substitute[*:var/name = current()/name]/term/*" 
						mode="copy"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy>
					<xsl:apply-templates mode="substitution">
						<xsl:with-param name="substitutions" select="$substitutions"/>
					</xsl:apply-templates> 
				</xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template match="*:seq" mode="substitution">  
		<xsl:param name="substitutions" as="element(substitution)"/>
		<xsl:choose>
			<xsl:when test="some $seq in $substitutions/(subject|target)/substitute/*:seq satisfies $seq/name = ./name">
				<xsl:apply-templates select="$substitutions/(subject|target)/substitute[*:seq/name = current()/name]/term/*" 
						mode="copy"/>  
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy>
					<xsl:apply-templates mode="substitution">
						<xsl:with-param name="substitutions" select="$substitutions"/>
					</xsl:apply-templates> 
				</xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="substitute" mode="substitution">
		<xsl:param name="substitutions" as="element(substitution)"/>
		<xsl:if test="some $varlike in $substitutions/(subject|target)/substitute/(*:var|*:seq) satisfies  (    ($varlike/name = (*:seq|*:var)/name) 
				and 
				($varlike/name()=(*:seq|*:var)/name())  
				)">
			<xsl:message>OUT OF SPEC context <xsl:copy-of select="."/></xsl:message>
			<xsl:message>OUT OF SPEC substitutions <xsl:copy-of select="$substitutions"/> </xsl:message>
			<xsl:message terminate="yes">OUT OF SPEC when applying a substitution to a substitution substitute of a var or seq </xsl:message>
		</xsl:if>
		<xsl:copy>
			<xsl:copy-of select="*:seq|*:var"/>
			<xsl:apply-templates select="term"  mode="substitution">
				<xsl:with-param name="substitutions" select="$substitutions"/>
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>


	<!-- mode="insert_subject_substitute" -->
	<!-- used to add a subject substitute to a substitution -->
	<!-- must apply the substitution along the way -to both subject and target substitutions -->
	<xsl:template match="*" mode="insert_subject_substitute">
		<xsl:param name="substitute" as="element(substitute)"/> 
		<xsl:copy>
			<xsl:apply-templates mode="insert_subject_substitute">
				<xsl:with-param name="substitute" select="$substitute"/>
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="subject" mode="insert_subject_substitute">
		<xsl:param name="substitute" as="element(substitute)"/> 
		<xsl:copy>
			<xsl:variable name="subject_sub" as="element(substitution)">
				<gat:substitution>
					<subject>
						<xsl:copy-of select="$substitute"/>
					</subject>
				</gat:substitution>
			</xsl:variable>
			<xsl:apply-templates mode="substitution">
				<xsl:with-param name="substitutions" select="$subject_sub"/>
			</xsl:apply-templates>
			<xsl:copy-of select="$substitute"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="target" mode="insert_subject_substitute">
		<xsl:param name="substitute" as="element(substitute)"/> 
		<xsl:copy>
			<xsl:variable name="subject_sub" as="element(substitution)">
				<gat:substitution>
					<subject>
						<xsl:copy-of select="$substitute"/>
					</subject>
				</gat:substitution>
			</xsl:variable>
			<xsl:apply-templates mode="substitution">
				<xsl:with-param name="substitutions" select="$subject_sub"/>
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*" mode="insert_target_substitute">
		<xsl:param name="substitute" as="element(substitute)"/>
		<xsl:if test="$substitute/substitution">
			<xsl:message terminate="yes">Out OF SPEC - Nested substitution!</xsl:message>
		</xsl:if>
		<xsl:copy>
			<xsl:apply-templates mode="insert_target_substitute">
				<xsl:with-param name="substitute" select="$substitute"/>
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="target" mode="insert_target_substitute">
		<xsl:param name="substitute" as="element(substitute)"/> 
		<xsl:copy>
			<xsl:variable name="target_sub" as="element(substitution)">
				<gat:substitution>
					<target>
						<xsl:copy-of select="$substitute"/>
					</target>
				</gat:substitution>
			</xsl:variable>
			<xsl:apply-templates mode="substitution">
				<xsl:with-param name="substitutions" select="$target_sub"/>
			</xsl:apply-templates>
			<xsl:copy-of select="$substitute"/>
		</xsl:copy>
	</xsl:template>


	<xsl:template match="subject" mode="insert_target_substitute">
		<xsl:param name="substitute" as="element(substitute)"/> 

		<xsl:copy>
			<xsl:variable name="target_sub" as="element(substitution)">
				<gat:substitution>
					<target>
						<xsl:copy-of select="$substitute"/>
					</target>
				</gat:substitution>
			</xsl:variable>
			<xsl:apply-templates mode="substitution">
				<xsl:with-param name="substitutions" select="$target_sub"/>
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>


	<xsl:template match="substitution" mode="compose_substitutions">
		<xsl:param name="head_substitution" as="element(substitution)"/> <!-- changed param name to head_substitution because not symetric -->
		<!--
    <xsl:message>              Composing substitutions </xsl:message>
    <xsl:message>              dot substitution subject  <xsl:apply-templates select="./subject" mode="text"/></xsl:message>
    <xsl:message>              dot substitution target  <xsl:apply-templates select="./target" mode="text"/></xsl:message>
    <xsl:message>              head substitution subject <xsl:apply-templates select="$head_substitution/subject" mode="text"/></xsl:message>
    <xsl:message>              head substitution target <xsl:apply-templates select="$head_substitution/target" mode="text"/></xsl:message>
	-->
		<xsl:if test="$head_substitution/*/substitute/substitution">
			<xsl:message terminate="yes">Out OF SPEC - Nested substitution!</xsl:message>
		</xsl:if>
		<xsl:if test="./*/substitute/substitution">
			<xsl:message terminate="yes">Out OF SPEC - Nested substitution!</xsl:message>
		</xsl:if>
		<xsl:variable name="result_substitution" as="element(substitution)">
			<xsl:copy>
				<xsl:apply-templates select="$head_substitution" mode="compose_substitutionsxxxx">
					<xsl:with-param name="substitution" select="."/>
				</xsl:apply-templates>
			</xsl:copy>
		</xsl:variable>
		<xsl:if test="not($quiet)">
			<xsl:message>              Result composed substitution </xsl:message>
			<xsl:message>                   subject: <xsl:apply-templates select="$result_substitution/subject" mode="text"/> </xsl:message>
			<xsl:message>                  target: <xsl:apply-templates select="$result_substitution/target" mode="text"/> </xsl:message>
		</xsl:if>
		<xsl:copy-of select="$result_substitution"/>
	</xsl:template>


	<xsl:template match="subject" mode="compose_substitutionsxxxx">
		<xsl:param name="substitution" as="element(substitution)"/> 

		<xsl:copy>
			<xsl:apply-templates mode="substitution">
				<xsl:with-param name="substitutions" select="$substitution"/>
			</xsl:apply-templates>
			<xsl:copy-of select="$substitution/subject/*"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="target" mode="compose_substitutionsxxxx">
		<xsl:param name="substitution" as="element(substitution)"/> 

		<xsl:copy>
			<xsl:apply-templates mode="substitution">
				<xsl:with-param name="substitutions" select="$substitution"/>
			</xsl:apply-templates>    
			<xsl:copy-of select="$substitution/target/*"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*" mode="copy">
		<xsl:copy>
			<xsl:apply-templates mode="copy"/>
		</xsl:copy>
	</xsl:template>

</xsl:transform>

