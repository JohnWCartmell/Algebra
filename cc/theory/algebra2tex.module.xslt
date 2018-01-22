<!--
algebratext.module.xslt
**********************

DESCRIPTION

-->

<xsl:transform version="2.0" 
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
	    xmlns:cc               ="http://www.entitymodelling.org/theory/contextualcategory"
		xmlns:gat              ="http://www.entitymodelling.org/theory/generalisedalgebraictheory"
		xpath-default-namespace="http://www.entitymodelling.org/theory/contextualcategory" 	   
		                  xmlns="http://www.entitymodelling.org/theory/contextualcategory" >


	<xsl:template match="Ob" mode="tex">
		<xsl:text>Ob(</xsl:text>
		<xsl:apply-templates mode="tex"/>
		<xsl:text>)</xsl:text>
	</xsl:template>

	<xsl:template match="Hom" mode="tex">
         <xsl:text>Hom(</xsl:text>
		 <xsl:apply-templates select="*[1]" mode="tex"/>
		 <xsl:text>, </xsl:text>
		 <xsl:apply-templates select="*[2]" mode="tex"/>
		 <xsl:text>)</xsl:text>
	</xsl:template>

	<xsl:template match="o"  mode="tex">
		<xsl:variable name="args" as="xs:string *">
			<xsl:for-each select="*">
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


	<xsl:template match="q" mode="tex">
		<xsl:text>q(</xsl:text>
		<xsl:apply-templates select="*[1]" mode="tex"/>
		<xsl:text>,</xsl:text>
		<xsl:apply-templates select="*[2]" mode="tex"/>
		<xsl:text>)</xsl:text>
	</xsl:template>

	<xsl:template match="star" mode="tex">
		<xsl:choose> 
			<xsl:when test="*[1][self::o|self::star]">
				<xsl:text>(</xsl:text>
				<xsl:apply-templates select="*[1]" mode="tex"/>
				<xsl:text>)</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="*[1]" mode="tex"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>^*</xsl:text>
		<xsl:choose> 
			<xsl:when test="*[2][self::o | self::star]">
				<xsl:text>(</xsl:text>
				<xsl:apply-templates select="*[2]" mode="tex"/>
				<xsl:text>)</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="*[2]" mode="tex"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="s" mode="tex">
		<xsl:text>s(</xsl:text>
		<xsl:apply-templates select="*[1]" mode="tex"/>
		<xsl:text>)</xsl:text>
	</xsl:template>
	
	<xsl:template match="p|id" mode="tex">
		<xsl:value-of select="name()"/>
		<xsl:text>_{</xsl:text>
		<xsl:apply-templates mode="tex"/>
		<xsl:text>}</xsl:text>
	</xsl:template>

	<xsl:template match="a|b|c|d|e" mode="tex">
		<xsl:value-of select="name()"/>
	</xsl:template>

</xsl:transform>
