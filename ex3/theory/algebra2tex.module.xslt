<!--
algebra2tex.module.xslt
**********************

DESCRIPTION

-->

<xsl:transform version="2.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:ex3               ="http://www.entitymodelling.org/theory/gat-examplethree"
		xmlns:gat              ="http://www.entitymodelling.org/theory/generalisedalgebraictheory"
		xpath-default-namespace="http://www.entitymodelling.org/theory/gat-examplethree" 	   
		xmlns="http://www.entitymodelling.org/theory/gat-examplethree" >


	<xsl:template match="gat:lhs|gat:rhs|gat:term" mode="tex">	
		<xsl:text>\ofT{</xsl:text>
		<xsl:apply-templates select="ex3:*" mode="tex"/>
		<xsl:text>}{</xsl:text>
		<xsl:apply-templates select="ex3:*/gat:type/ex3:*" mode="tex"/>
		<xsl:text>}</xsl:text>				      
	</xsl:template>

	<xsl:template match="A" mode="tex">
		<xsl:text>A</xsl:text>
	</xsl:template>
	
	
	<xsl:template match="Ap" mode="tex">
		<xsl:text>A'</xsl:text>
	</xsl:template>
	
	<xsl:template match="C" mode="tex">
		<xsl:text>C</xsl:text>
	</xsl:template>
	
	  	<xsl:template match="f" mode="tex">
		<xsl:text>f(</xsl:text>
		<xsl:apply-templates select="ex3:*[1]" mode="tex"/>
		<xsl:text>)</xsl:text>
	</xsl:template>

	<xsl:template match="B" mode="tex">
		<xsl:text>B(</xsl:text>
		<xsl:apply-templates select="ex3:*[1]" mode="tex"/>
		<xsl:text>)</xsl:text>
	</xsl:template>
  
  	<xsl:template match="g" mode="tex">
		<xsl:text>g([</xsl:text>
		<xsl:apply-templates select="ex3:*[1]" mode="tex"/>
		<xsl:text>], </xsl:text>
		<xsl:apply-templates select="ex3:*[2]" mode="tex"/>
		<xsl:text>)</xsl:text>
	</xsl:template>

	<xsl:template match="a_1|a_2" mode="tex">
		<xsl:value-of select="name()"/>
	</xsl:template>

</xsl:transform>
