<xsl:transform version="2.0" 
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:gat              ="http://www.entitymodelling.org/theory/generalisedalgebraictheory"
		xpath-default-namespace="http://www.entitymodelling.org/theory/generalisedalgebraictheory"	   
		                  xmlns="http://www.entitymodelling.org/theory/generalisedalgebraictheory">
		
	<xsl:strip-space elements="*"/> 


	<xsl:include href="gat.specialisation.module.xslt"/>
	<xsl:include href="gat.text.module.xslt"/>
	<xsl:include href="gat.tex.module.xslt"/>
	<xsl:include href="gat.substitution.module.xslt"/>


<!-- A specialisation of a term is a substitutional instance -->

<!-- This next tempate becomes obsolte and is not namespace cprrected -->
<xsl:template match="/" mode="annotate_with_type">
	<xsl:for-each select="test/term">
		<example>
			<term>
				<xsl:apply-templates select="./*" mode="text"/>
			</term>
			<type>
				<xsl:apply-templates  mode="type">
					<xsl:with-param name="context" select="'hom'"/>
				</xsl:apply-templates>
			</type>
		</example>
	</xsl:for-each>
</xsl:template>

<xsl:template match="/" mode="testspecialisation">
	<xsl:for-each select="algebra/termpair">
		<example>
			<super>
				<xsl:apply-templates select="super/*" mode="text"/>
			</super>
			<target>
				<xsl:message> target <xsl:apply-templates select="target/*" mode="text"/>
				</xsl:message>
				<xsl:apply-templates select= "target/*" mode="text"/>
			</target>
			<xsl:variable name="specialisations">
				<xsl:for-each select="super/*">
					<xsl:call-template name="specialiseTerm">
						<xsl:with-param name="targetTerm" select="../../target/*"/>
					</xsl:call-template>
				</xsl:for-each>
			</xsl:variable>
			<results>
				<xsl:variable name="super" as="element()" select="super"/>
				<xsl:variable name="target" as="element()" select="target"/>
				<xsl:for-each select="$specialisations/substitution">
					<xsl:variable name="substitution" select="." as="element(substitution)" />
					<xsl:message> substitution name <xsl:value-of select="$substitution/name()"/>
					</xsl:message> 
					<result>
						<xsl:copy-of select="."/>
						<specialisedTerm>
							<xsl:for-each select="$super"> 
								<xsl:message>DOT name <xsl:value-of select="name()"/>
								</xsl:message>
								<xsl:message>count $substitution/* <xsl:value-of select="count($substitution/*)"/>
								</xsl:message>
								<xsl:apply-templates mode="substitution">
									<xsl:with-param name="substitutions" select="$substitution"/>  
								</xsl:apply-templates>
							</xsl:for-each>
						</specialisedTerm>
						<specialisedTarget>
							<xsl:for-each select="$target">
                <!-- was 
								<xsl:call-template name="applyTargetSubstitutions">
									<xsl:with-param name="substitution" select="$substitution"/>
								</xsl:call-template>
                but now -->
                                 <xsl:apply-templates mode="substitution">
									<xsl:with-param name="substitutions" select="$substitution"/>
								</xsl:apply-templates>
							</xsl:for-each>
						</specialisedTarget>
					</result>
				</xsl:for-each>
			</results>
		</example>
	</xsl:for-each>
</xsl:template>

<xsl:template name="execute_specialisation" >
	<xsl:for-each select= "algebra/termSpecialisation">
		<xsl:message>specialising: <xsl:apply-templates select="upperTerm" mode="text"/> to: <xsl:apply-templates select="lowerTerm" mode="text"/>
		</xsl:message>
		<specialise>
			<upperTerm>
				<xsl:apply-templates select="upperTerm" mode="text"/>
			</upperTerm>
			<lowerTerm>
				<xsl:apply-templates select="lowerTerm" mode="text"/>
			</lowerTerm>
			<by>
				<xsl:for-each select="upperTerm/*">
					<xsl:call-template name="specialiseTerm">
						<xsl:with-param name="targetTerm" select="../../lowerTerm/*"/>
					</xsl:call-template>
				</xsl:for-each>
			</by>
		</specialise>
		<xsl:message/>
		<xsl:message/>
	</xsl:for-each>
</xsl:template>

<xsl:template name="execute_substitutions">
	<xsl:for-each select= "algebra/termSubstitution">
		<xsl:message>substitution in term: <xsl:apply-templates select="term" mode="text"/>
		</xsl:message>
		<xsl:copy>
			<xsl:apply-templates select="term" mode="substitution">
				<xsl:with-param name="substitutions" select="substitutions"/>
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:for-each>
</xsl:template>


<!-- Moved to substitution module 
<xsl:template name="applyTargetSubstitutions">
	<xsl:param name="substitution"/>
	<xsl:variable name="targetSubstitution">
		<substitution>
			<xsl:for-each select="$substitution/targetSubstitute">
				<substitute>
					<xsl:copy-of select="*"/>
				</substitute>
			</xsl:for-each>
		</substitution>
	</xsl:variable>
	<xsl:apply-templates select="." mode="substitution">
		<xsl:with-param name="substitutions" select="$targetSubstitution/*"/>
	</xsl:apply-templates>
</xsl:template>

-->

</xsl:transform>

