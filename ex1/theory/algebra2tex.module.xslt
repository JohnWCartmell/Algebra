<!--
algebra2tex.module.xslt
**********************

DESCRIPTION

-->

<xsl:transform version="2.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:ex1               ="http://www.entitymodelling.org/theory/exampleone"
		xmlns:gat              ="http://www.entitymodelling.org/theory/generalisedalgebraictheory"
		xpath-default-namespace="http://www.entitymodelling.org/theory/exampleone" 	   
		xmlns="http://www.entitymodelling.org/theory/exampleone" >

	<xsl:template match="gat:lhs|gat:rhs|gat:term" mode="tex">	
		<xsl:text>\ofT{</xsl:text>
		<xsl:apply-templates select="ex1:*" mode="tex"/>
		<xsl:text>}{</xsl:text>
		<xsl:apply-templates select="ex1:*/gat:type/ex1:*" mode="tex"/>
		<xsl:text>}</xsl:text>				      
	</xsl:template>

	<xsl:template match="A" mode="tex">
		<xsl:text>A</xsl:text>
	</xsl:template>

	<xsl:template match="B" mode="tex">
		<xsl:text>B(</xsl:text>
		<xsl:apply-templates select="ex1:*[1]" mode="tex"/>
		<xsl:text>)</xsl:text>
	</xsl:template>
  
  	<xsl:template match="C" mode="tex">
		<xsl:text>C(</xsl:text>
		<xsl:apply-templates select="ex1:*[1]" mode="tex"/>
		<xsl:text>, </xsl:text>
		<xsl:apply-templates select="ex1:*[2]" mode="tex"/>
		<xsl:text>)</xsl:text>
	</xsl:template>

	<xsl:template match="a_1|a_2" mode="tex">
		<xsl:value-of select="name()"/>
	</xsl:template>

</xsl:transform>
