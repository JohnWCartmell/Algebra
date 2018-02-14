<xsl:transform version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:ccseq               ="http://www.entitymodelling.org/theory/contextualcategory/sequence"
    xmlns:gat              ="http://www.entitymodelling.org/theory/generalisedalgebraictheory"
    xpath-default-namespace="http://www.entitymodelling.org/theory/contextualcategory/sequence" 	   
    xmlns="http://www.entitymodelling.org/theory/contextualcategory/sequence" >

  <xsl:strip-space elements="*"/>

  <!--
  <xsl:include href="algebra2txt.module.xslt" />
  <xsl:include href="algebra2tex.module.xslt" />
  <xsl:include href="algebra2type.module.xslt" />
--> 

<!--
  <xsl:include href="temp/rewrite.module.xslt" />
  -->
  <xsl:include href="../../algebraLibrary/algebra2.initial_enrichment.module.xslt"/>
  
  <!--
  <xsl:include href="../../algebraLibrary/gat.module.xslt"/>
  <xsl:include href="../../algebraLibrary/gat.rewrite.module.xslt"/>
  -->


  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="yes"/>



</xsl:transform>

