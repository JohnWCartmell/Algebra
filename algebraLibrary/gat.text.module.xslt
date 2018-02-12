<xsl:transform version="2.0" 
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:gat              ="http://www.entitymodelling.org/theory/generalisedalgebraictheory"
		xpath-default-namespace="http://www.entitymodelling.org/theory/generalisedalgebraictheory"	   
		                  xmlns="http://www.entitymodelling.org/theory/generalisedalgebraictheory">

	<xsl:strip-space elements="*"/> 

	<!-- gat.text.module.xslt -->
	<xsl:template match="/" mode="text" >
		<xsl:copy>
			<xsl:apply-templates mode="text"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="term" mode="text"> 
		<xsl:apply-templates mode="text"/>	   
	</xsl:template>

	<xsl:template match="rewriteRule" mode="text">
		<xsl:text>&#xA;</xsl:text>
		<xsl:value-of select="id"/> 
		<xsl:text>.  </xsl:text>    
		<xsl:for-each select="lhs">
			<xsl:apply-templates mode="text"/>
		</xsl:for-each>
		<xsl:text>{</xsl:text>
		<xsl:for-each select="lhs">
			<xsl:apply-templates mode="number"/>
		</xsl:for-each>
		<xsl:text>}</xsl:text>
		<xsl:text disable-output-escaping="yes"> => </xsl:text>
	<xsl:for-each select="rhs">
		<xsl:apply-templates mode="text"/>
	</xsl:for-each>
	<xsl:text>{</xsl:text>
	<xsl:for-each select="rhs">
		<xsl:apply-templates mode="number"/>
	</xsl:for-each>
	<xsl:text>}</xsl:text>
	<xsl:text>&#xA;</xsl:text>
</xsl:template>

<xsl:template match="equation" mode="text">
	<xsl:text>&#xA;</xsl:text>
	<xsl:value-of select="id"/> 
	<xsl:text>.  </xsl:text>    
	<xsl:for-each select="lhs">
		<xsl:apply-templates mode="text"/>
	</xsl:for-each>
	<xsl:text> = </xsl:text>
	<xsl:for-each select="rhs">
		<xsl:apply-templates mode="text"/>
	</xsl:for-each>
	<xsl:text>&#xA;</xsl:text>
</xsl:template>

<xsl:template match="*:var" mode="text">
	<xsl:value-of select="."/>
</xsl:template>

<xsl:template match="*:seq" mode="text">
	<xsl:text>.</xsl:text>
	<xsl:value-of select="."/>
	<xsl:text>.</xsl:text>
</xsl:template>

<xsl:template match="point" mode="text">
	<xsl:text>[</xsl:text>
	<xsl:apply-templates select="*[1]" mode="text"/>
	<xsl:text>]</xsl:text>
</xsl:template>

<xsl:template match="tail"  mode="text">
	<xsl:variable name="args" as="xs:string *">
		<xsl:for-each select="*">
			<xsl:variable name="arg">
				<xsl:apply-templates select="." mode="text"/>
			</xsl:variable>
			<xsl:value-of select="$arg"/>
		</xsl:for-each>
	</xsl:variable>
	<xsl:text>tail(</xsl:text>
	<xsl:value-of select="string-join($args,',')"/>
	<xsl:text>)</xsl:text>
</xsl:template>

<xsl:template match="/" mode="longtext" >
	<xsl:copy>
		<xsl:apply-templates mode="longtext"/>
		<xsl:text>&#xA;</xsl:text>
	</xsl:copy>
</xsl:template>


<xsl:template match="rewriteRule|equation" mode="longtext" >
	<xsl:text>&#xA;</xsl:text>
	<xsl:value-of select="id"/> 
	<xsl:text>.  </xsl:text>  
	<xsl:for-each select="lhs">
		<xsl:variable name="lhstype">
			<xsl:apply-templates mode="type">
				<xsl:with-param name="absolute" select=".."/>
			</xsl:apply-templates>
		</xsl:variable>             
		<xsl:apply-templates mode="text"/>
		<xsl:text> : </xsl:text>
		<xsl:apply-templates select="$lhstype" mode="text"/>
	</xsl:for-each>
	<xsl:choose>
		<xsl:when test="self::equation">
			<xsl:text> = </xsl:text>
		</xsl:when>
		<xsl:when test="self::rewriteRule">
			<xsl:text disable-output-escaping="yes">=></xsl:text>
	    </xsl:when>
     </xsl:choose>

     <xsl:for-each select="rhs">
	    <xsl:variable name="rhstype">
			<xsl:apply-templates mode="type">
				<xsl:with-param name="absolute" select=".."/>
			</xsl:apply-templates>
		</xsl:variable>             
		<xsl:apply-templates mode="text"/>
		<xsl:text> : </xsl:text>
		<xsl:apply-templates select="$rhstype" mode="text"/>
	</xsl:for-each>
</xsl:template>


</xsl:transform>

