<xsl:transform version="2.0" 
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:strip-space elements="*"/> 

  <xsl:include href="ccseq2txt.module.xslt" />
  <xsl:include href="ccseq2type.module.xslt" />
  <xsl:include href="../../temp/ccseqRewrite.module.xslt"/>
  
  <xsl:include href="../../algebraLibrary/algebra.module.xslt"/>

  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>


</xsl:transform>

