<xsl:transform version="2.0" 
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:gat              ="http://www.entitymodelling.org/theory/generalisedalgebraictheory"
		xpath-default-namespace="http://www.entitymodelling.org/theory/generalisedalgebraictheory"	   
		                  xmlns="http://www.entitymodelling.org/theory/generalisedalgebraictheory">

	<xsl:strip-space elements="*"/> 

<!-- gat.substitution.module.xslt-->

<xsl:template match="*" mode="substitution">
	<xsl:param name="substitutions"/>
	<xsl:copy>
		<xsl:apply-templates mode="substitution">
			<xsl:with-param name="substitutions" select="$substitutions"/>
		</xsl:apply-templates>
	</xsl:copy>
</xsl:template>


<xsl:template match="*:decl" mode="substitution">  
	<xsl:param name="substitutions"/>
	<xsl:choose>
		<xsl:when test="some $var in $substitutions/substitute/*:var satisfies $var/name = ./name">
		</xsl:when>
		<xsl:otherwise>
			<xsl:copy>
				<xsl:apply-templates mode="copy"/>
			</xsl:copy>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="*:sequence" mode="substitution">  
	<xsl:param name="substitutions"/>
	<xsl:choose>
		<xsl:when test="some $seq in $substitutions/substitute/*:seq satisfies $seq/name = ./name">
		</xsl:when>
		<xsl:otherwise>
			<xsl:copy>
				<xsl:apply-templates mode="copy"/>
			</xsl:copy>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>


<xsl:template match="*:var" mode="substitution">  
	<xsl:param name="substitutions"/>
	<xsl:choose>
		<xsl:when test="some $var in $substitutions/substitute/*:var satisfies $var/name = ./name">
			<xsl:apply-templates select="$substitutions/substitute[*:var/name = current()/name]/term/*" 
					mode="copy"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:copy>
				<xsl:apply-templates mode="copy"/>
			</xsl:copy>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="*:seq" mode="substitution">  
	<xsl:param name="substitutions"/>
	<xsl:message>Firing at seq count <xsl:value-of select="count($substitutions/*)"/>
	</xsl:message>

	<xsl:choose>
		<xsl:when test="some $seq in $substitutions/substitute/*:seq satisfies $seq/name = ./name">
			<xsl:message>Firing IN seq </xsl:message>
			<xsl:apply-templates select="$substitutions/substitute[*:seq/name = current()/name]/term/*" 
					mode="copy"/>

		</xsl:when>
		<xsl:otherwise>
			<xsl:copy>
				<xsl:apply-templates mode="copy"/>
			</xsl:copy>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

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


<xsl:template match="*" mode="copy">
	<xsl:copy>
		<xsl:apply-templates mode="copy"/>
	</xsl:copy>
</xsl:template>
<!-- end substitutions -->


</xsl:transform>

