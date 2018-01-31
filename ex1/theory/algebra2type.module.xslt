<xsl:transform version="2.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:cc               ="http://www.entitymodelling.org/theory/contextualcategory"
		xmlns:gat              ="http://www.entitymodelling.org/theory/generalisedalgebraictheory"
		xpath-default-namespace="http://www.entitymodelling.org/theory/contextualcategory" 	   
		xmlns="http://www.entitymodelling.org/theory/contextualcategory" >

	<!--
   <xsl:template match="s[not(gat:type)][child::cc:*/gat:type]" 
                 mode="initial_enrichment_recursive"  >
				 -->
	<xsl:template match="s" priority="100" 
			mode="initial_enrichment_recursive"  >
		<xsl:message>Got there</xsl:message>
		<xsl:variable name="childtype" select="child::*/gat:type"/>
		<xsl:call-template name="s_typed">
			<xsl:with-param name="arg1type" select="child::*/gat:type"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="s" name="s_typed" mode="explicit">
		<xsl:param name="arg1type"/>
		<xsl:copy>
			<xsl:apply-templates mode="copy"/>
			<gat:type>
				<Hom>
					<xsl:copy-of select="$arg1type/*[1]"/>
					<star>
						<xsl:copy-of select="child::cc:*/*"/>
						<star>
							<p>
								<xsl:copy-of select="$arg1type/*[2]"/>
							</p>
							<xsl:copy-of select="$arg1type/*[2]"/>
						</star>
					</star>				
				</Hom>
			</gat:type>
		</xsl:copy>
	</xsl:template>





</xsl:transform>
