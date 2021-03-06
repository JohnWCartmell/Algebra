<xsl:transform version="2.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:ccseq               ="http://www.entitymodelling.org/theory/contextualcategory/sequence"
		xmlns:ccseqfun            ="http://www.entitymodelling.org/theory/contextualcategory/sequence/fun"
		xmlns:gat              ="http://www.entitymodelling.org/theory/generalisedalgebraictheory" 	   
		xmlns="http://www.entitymodelling.org/theory/contextualcategory/sequence" 
		xpath-default-namespace="http://www.entitymodelling.org/theory/contextualcategory/sequence"
				exclude-result-prefixes="xs gat ccseq ccseqfun">


	<xsl:function name="ccseqfun:relabelling" as="element(gat:relabel)*">
		<xsl:param name="context" as="element(gat:context)"/>
		<xsl:sequence select="ccseqfun:relabelling_for_homlike($context)"/>
		<xsl:sequence select="ccseqfun:relabelling_for_obj_vars($context)"/>
	</xsl:function>

	<xsl:function name="ccseqfun:relabelling_for_obj_vars" as="element(gat:relabel)*">
		<xsl:param name="context" as="element(gat:context)"/>
		<!-- assume all vars that are  not explicitly HomLike are objct variables -->
		<xsl:variable name="all_explicit_and_implicit_variable_names" as="xs:string*"
				select="distinct-values($context/(descendant::decl|descendant::var)/gat:name)"/>
		<xsl:variable name="HomVarNames" as="xs:string*" select="$context/gat:decl[gat:type/Hom]/gat:name"/>

		<xsl:variable name="HomSeqVarNames" as="xs:string*" select="$context/gat:sequence[gat:type/HomSeq]/gat:name"/>
		<xsl:variable name="all_object_VarNames" as="xs:string*" 
				select="ccseqfun:value-except(ccseqfun:value-except($all_explicit_and_implicit_variable_names,$HomVarNames), $HomSeqVarNames)"/>
	
		<xsl:variable name="top_level_object_VarNames" as="xs:string*" 
				select="$all_object_VarNames[not(some $decl in $context/gat:decl satisfies $decl/gat:type/ccseq:Ob/ccseq:var/gat:name = .)]"/>

		<xsl:variable name="generatedNamesForTopLevel" as="xs:string*" select="ccseqfun:obj_variables(count($top_level_object_VarNames))"/>

		<xsl:if test="not(count($generatedNamesForTopLevel)=count($top_level_object_VarNames))">
			<xsl:message terminate="yes">OUT OF SPEC </xsl:message>
		</xsl:if>

		<xsl:variable name="dependedOn_VarNames" as="xs:string*" select="ccseqfun:value-except($all_object_VarNames,$top_level_object_VarNames)"/>

		<xsl:variable name="relabelling_for_top_level_object_vars" as="element(gat:relabel)*">
			<xsl:for-each select="$top_level_object_VarNames">
			    <xsl:variable name="index"  select="position()"/>
				<gat:relabel>
					<gat:pre>
						<xsl:value-of select="."/>
					</gat:pre>
					<gat:post>
						<xsl:value-of select="$generatedNamesForTopLevel[position()=$index]"/>
					</gat:post>
				</gat:relabel>
			</xsl:for-each>
		</xsl:variable>
		<xsl:variable name="newNamesForDependedOn_Vars" as="xs:string*">
		<xsl:message>Count of dependedOn_varNames is <xsl:value-of select="count($dependedOn_VarNames)"/></xsl:message>
			<xsl:for-each select="$dependedOn_VarNames">
				<xsl:sequence select="ccseqfun:generateDependentName($context,$relabelling_for_top_level_object_vars,.)"/>
			</xsl:for-each>
		</xsl:variable>
		<xsl:if test="not(count($newNamesForDependedOn_Vars)=count($dependedOn_VarNames))">
			<xsl:message terminate="yes">OUT OF SPEC </xsl:message>
		</xsl:if>
		<xsl:variable name="relabelling_for_dependedOn_object_vars" as="element(gat:relabel)*">
			<xsl:for-each select="$dependedOn_VarNames">
			    <xsl:variable name="index"  select="position()"/>
				<gat:relabel>
					<gat:pre>
						<xsl:value-of select="."/>
					</gat:pre>
					<gat:post>
						<xsl:value-of select="$newNamesForDependedOn_Vars[position()=$index]"/>
					</gat:post>
				</gat:relabel>
			</xsl:for-each>
		</xsl:variable>
		<xsl:copy-of select="$relabelling_for_dependedOn_object_vars"/>
		<xsl:copy-of select="$relabelling_for_top_level_object_vars"/>
	</xsl:function>

	<xsl:function name="ccseqfun:generateDependentName" as="xs:string">
		<xsl:param name="context" as="element(gat:context)"/>
		<xsl:param name="relabelling" as="element(gat:relabel)*"/>
		<xsl:param name="dependedOn_name" as="xs:string"/>
		<xsl:variable name="dependent" as="element(gat:decl)?" 
				select="$context/gat:decl[gat:type/Ob/var/gat:name = $dependedOn_name][1]"/>
		<xsl:choose>
			<xsl:when test="$dependent">
				<xsl:variable name="dependents_name" as="xs:string"
						select="ccseqfun:generateDependentName($context,$relabelling,$dependent/gat:name)"/>
				<xsl:choose>
					<xsl:when test="substring($dependents_name,string-length($dependents_name)-1,1)='p'">
						<xsl:value-of select="concat($dependents_name,'p')"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="concat($dependents_name,'_p')"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$relabelling[gat:pre=$dependedOn_name]/gat:post"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>


	<xsl:function name="ccseqfun:relabelling_for_homlike" as="element(gat:relabel)*">
		<xsl:param name="context" as="element(gat:context)"/>
		<xsl:variable name="HomVarNames" as="xs:string*" 
				select="$context/gat:decl[gat:type/Hom]/gat:name"/>
		<xsl:variable name="HomSeqVarNames" as="xs:string*" 
				select="$context/gat:sequence[gat:type/HomSeq]/gat:name"/>
		<xsl:variable name="HomVarGeneratedNames" as="xs:string*" 
				select="ccseqfun:hom_variables(count($HomVarNames),count($HomSeqVarNames))"/>
		<xsl:variable name="HomSeqVarGeneratedNames" as="xs:string*" 
				select="ccseqfun:homseq_variables(count($HomVarNames),count($HomSeqVarNames))"/>
			
		<xsl:if test="not(count($HomVarGeneratedNames)=count($HomVarNames))">
			<xsl:message terminate="yes">OUT OF SPEC - count(HomVarGeneratedNames): <xsl:value-of select="count($HomVarGeneratedNames)"/></xsl:message>
		</xsl:if>
		<xsl:if test="not(count($HomSeqVarGeneratedNames)=count($HomSeqVarNames))">
			<xsl:message terminate="yes">OUT OF SPEC </xsl:message>
		</xsl:if>
		<xsl:for-each select="$HomVarNames">
		    <xsl:variable name="index"  select="position()"/>
			<gat:relabel>
				<gat:pre>
					<xsl:value-of select="."/>
				</gat:pre>
				<gat:post>
					<xsl:value-of select="$HomVarGeneratedNames[position()=$index]"/>
				</gat:post>
			</gat:relabel>
		</xsl:for-each>
		<xsl:for-each select="$HomSeqVarNames">
		    <xsl:variable name="index"  select="position()"/>
			<gat:relabel>
				<gat:pre>
					<xsl:value-of select="."/>
				</gat:pre>
				<gat:post>
					<xsl:value-of select="$HomSeqVarGeneratedNames[position()=$index]"/>
				</gat:post>
			</gat:relabel>
		</xsl:for-each>
	</xsl:function>

	<xsl:function name="ccseqfun:obj_variables" as="xs:string*">
		<xsl:param name="numberOfObjVars" as="xs:integer"/>
		<xsl:choose>
			<xsl:when test="$numberOfObjVars=0">
				<xsl:sequence select="()"/>
			</xsl:when>
			<xsl:when test="$numberOfObjVars=1">
				<xsl:sequence select="('x')"/>
			</xsl:when>
			<xsl:when test="$numberOfObjVars=2">
				<xsl:sequence select="('x','y')"/>
			</xsl:when>
			<xsl:when test="$numberOfObjVars=3">
				<xsl:sequence select="('x','y','z')"/>
			</xsl:when>
			<xsl:when test="$numberOfObjVars=4">
				<xsl:sequence select="('w','x','y','z')"/>
			</xsl:when>
			<xsl:when test="$numberOfObjVars=5">
				<xsl:sequence select="('v','w','x','y','z')"/>
			</xsl:when>
			<xsl:when test="$numberOfObjVars=6">
				<xsl:sequence select="('u','v','w','x','y','z')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:for-each select="1 to $numberOfObjVars">
					<xsl:sequence select="concat('x_',.)"/>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:function name="ccseqfun:hom_variables" as="xs:string*">
		<xsl:param name="numberOfHomVars" as="xs:integer"/>
		<xsl:param name="numberOfHomSeqVars" as="xs:integer"/>
		<xsl:choose>
			<xsl:when test="$numberOfHomVars=0">
				<xsl:sequence select="()"/>
			</xsl:when>
			<xsl:when test="$numberOfHomVars=1">
				<xsl:sequence select="('f')"/>
			</xsl:when>
			<xsl:when test="$numberOfHomVars=2">
				<xsl:sequence select="('f','g')"/>
			</xsl:when>
			<xsl:when test="$numberOfHomSeqVars=0 and $numberOfHomVars=3">
				<xsl:sequence select="('f','g','h')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:for-each select="1 to $numberOfHomVars">
					<xsl:sequence select="concat('f_',.)"/>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:function name="ccseqfun:homseq_variables" as="xs:string*">
		<xsl:param name="numberOfHomVars" as="xs:integer"/>
		<xsl:param name="numberOfHomSeqVars" as="xs:integer"/>
		<xsl:choose>
			<xsl:when test="$numberOfHomVars=0">
				<xsl:sequence select="ccseqfun:hom_variables($numberOfHomSeqVars,0)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:for-each select="1 to $numberOfHomSeqVars">
					<xsl:sequence select="concat('h_',.)"/>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
<xsl:function name="ccseqfun:value-except" as="xs:anyAtomicType*">
  <xsl:param name="arg1" as="xs:anyAtomicType*"/>
  <xsl:param name="arg2" as="xs:anyAtomicType*"/>
  <xsl:sequence select="distinct-values($arg1[not(some $x in $arg2 satisfies .=$x)])"/>
 </xsl:function>
 

</xsl:transform>