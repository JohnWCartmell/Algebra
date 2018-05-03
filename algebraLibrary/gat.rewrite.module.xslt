<xsl:transform version="2.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:gat              ="http://www.entitymodelling.org/theory/generalisedalgebraictheory"
		xmlns:ccseq="http://www.entitymodelling.org/theory/contextualcategory/sequence"
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




</xsl:transform>
