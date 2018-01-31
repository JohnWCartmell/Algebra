<!--
algebratext.module.xslt
**********************

DESCRIPTION

-->

<xsl:transform version="2.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:cat               ="http://www.entitymodelling.org/theory/category"
		xmlns:gat              ="http://www.entitymodelling.org/theory/generalisedalgebraictheory"
		xpath-default-namespace="http://www.entitymodelling.org/theory/category" 	   
		xmlns="http://www.entitymodelling.org/theory/category" >

	<xsl:template match="gat:lhs|gat:rhs|gat:term" mode="tex">	
		<xsl:text>\ofT{</xsl:text>
		<xsl:apply-templates select="cat:*" mode="tex"/>
		<xsl:text>}{</xsl:text>
		<xsl:apply-templates select="cat:*/gat:type/cat:*" mode="tex"/>
		<xsl:text>}</xsl:text>				      
	</xsl:template>

	<xsl:template match="Ob" mode="tex">
		<xsl:text>Ob</xsl:text>
	</xsl:template>

	<xsl:template match="Hom" mode="tex">
		<xsl:text>Hom(</xsl:text>
		<xsl:apply-templates select="cat:*[1]" mode="tex"/>
		<xsl:text>, </xsl:text>
		<xsl:apply-templates select="cat:*[2]" mode="tex"/>
		<xsl:text>)</xsl:text>
	</xsl:template>

	<xsl:template match="o"  mode="tex">
		<xsl:variable name="args" as="xs:string *">
			<xsl:for-each select="cat:*">
				<xsl:variable name="arg">
					<xsl:apply-templates select="." mode="tex"/>
				</xsl:variable>
				<xsl:value-of select="$arg"/>
			</xsl:for-each>
		</xsl:variable>
		<xsl:text>o(</xsl:text>
		<xsl:value-of select="string-join($args,',')"/>
		<xsl:text>)</xsl:text>
	</xsl:template>

	<xsl:template match="id" mode="tex">
		<xsl:value-of select="name()"/>
		<xsl:text>_{</xsl:text>
		<xsl:apply-templates select="cat:*" mode="tex"/>
		<xsl:text>}</xsl:text>
	</xsl:template>

</xsl:transform>
