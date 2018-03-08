<xsl:transform version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:ccseq               ="http://www.entitymodelling.org/theory/contextualcategory/sequence"
    xmlns:gat              ="http://www.entitymodelling.org/theory/generalisedalgebraictheory"
    xpath-default-namespace="http://www.entitymodelling.org/theory/contextualcategory/sequence" 	   
    xmlns="http://www.entitymodelling.org/theory/contextualcategory/sequence" >

  <xsl:strip-space elements="*"/>

  <xsl:include href="ccseq2txt.module.xslt" />
  <xsl:include href="ccseq2type_enrichment.module.xslt" />
  <xsl:include href="temp/rewrite.module.xslt" />
  <xsl:include href="../../algebraLibrary/gat.module.xslt"/>
  <xsl:include href="../../algebraLibrary/gat.rewrite.module.xslt"/>
  <xsl:include href="../../algebraLibrary/gat.text.module.xslt"/>
  <xsl:include href="../../algebraLibrary/gat.specialisation.module.xslt"/>
	<xsl:include href="../../algebraLibrary/gat.tex.module.xslt"/>
	<xsl:include href="../../algebraLibrary/gat.substitution.module.xslt"/>
	<xsl:include href="../../algebraLibrary/gat.type_enrichment.module.xslt"/>


  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="yes"/>
  
  <xsl:template match="/">
    <xsl:for-each select="gat:algebra">
      <xsl:copy>
        <xsl:copy-of select="namespace::*"/>
        <xsl:apply-templates select="gat:*" mode="type_enrich"/>
      </xsl:copy>
    </xsl:for-each>
  </xsl:template>
  

</xsl:transform>

