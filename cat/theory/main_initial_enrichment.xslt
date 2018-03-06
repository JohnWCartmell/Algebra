<xsl:transform version="2.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:cat               ="http://www.entitymodelling.org/theory/category"
		xmlns:gat              ="http://www.entitymodelling.org/theory/generalisedalgebraictheory"
		xpath-default-namespace="http://www.entitymodelling.org/theory/category" 	   
		xmlns="http://www.entitymodelling.org/theory/category" >

	<xsl:strip-space elements="*"/>

	<!--
  <xsl:include href="algebra2txt.module.xslt" />
  <xsl:include href="algebra2tex.module.xslt" />
  <xsl:include href="algebra2type.module.xslt" />
--> 

	<xsl:include href="../../algebraLibrary/algebra2.initial_enrichment.module.xslt"/>

	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="yes"/>


	<xsl:template match="id[not(gat:type)][child::cat:*/gat:type]" 
			mode="initial_enrichment_recursive">
		<xsl:copy>
		<xsl:message> Adding gat:type to id </xsl:message>
			<xsl:apply-templates mode="copy"/>
			<gat:type>
				<!-- add typecheck here that childtype is an instance of "Ob" -->
				<Hom>
					<xsl:copy-of select="cat:*"/>
					<xsl:copy-of select="cat:*"/>
				</Hom>
			</gat:type>
		</xsl:copy>
	</xsl:template>		

	<xsl:template match="o[not(gat:type)]
		[every $subterm in child::cat:* satisfies $subterm/gat:type]" 
			mode="initial_enrichment_recursive">
		<xsl:copy>
			<xsl:apply-templates mode="copy"/>
			<gat:type>
				<!-- add typechecking here ? -->
				<Hom>
					<xsl:copy-of select="cat:*[1]/gat:type/cat:Hom/cat:*[1]"/>
					<xsl:copy-of select="cat:*[2]/gat:type/cat:Hom/cat:*[2]"/>
				</Hom>
			</gat:type>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*" mode="copy">
		<xsl:copy copy-namespaces="no">
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="copy"/>
		</xsl:copy>
	</xsl:template>

</xsl:transform>

