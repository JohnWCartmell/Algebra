<xsl:transform version="2.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:gat              ="http://www.entitymodelling.org/theory/generalisedalgebraictheory"
		xpath-default-namespace="http://www.entitymodelling.org/theory/generalisedalgebraictheory"	   
		xmlns="http://www.entitymodelling.org/theory/generalisedalgebraictheory"
		exclude-result-prefixes="xs gat">

	<xsl:strip-space elements="*"/> 

	<xsl:template match="*" mode="structured_text">
		<xsl:copy>
			<xsl:apply-templates mode="structured_text"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*[self::gat:outer|self::gat:inner|self::gat:roughcut|self::gat:typed]/gat:*" mode="structured_text">
		<xsl:copy>
			<xsl:apply-templates mode="text"/>
		</xsl:copy>
	</xsl:template>

</xsl:transform>
