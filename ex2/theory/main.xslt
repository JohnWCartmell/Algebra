<xsl:transform version="2.0" 
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:strip-space elements="*"/>
  
  <xsl:include href="algebra2txt.module.xslt" />
  <xsl:include href="algebra2tex.module.xslt" />
  <xsl:include href="algebra2type.module.xslt" />
  
  <xsl:include href="../../algebraLibrary/gat.module.xslt"/>

  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="yes"/>


</xsl:transform>

