<!--
algebratext.module.xslt
**********************

DESCRIPTION

-->

<xsl:transform version="2.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:ccseq               ="http://www.entitymodelling.org/theory/contextualcategory/sequence"
		xmlns:gat              ="http://www.entitymodelling.org/theory/generalisedalgebraictheory" 	   
		xpath-default-namespace="http://www.entitymodelling.org/theory/contextualcategory/sequence" >

	<xsl:template match="gat:lhs|gat:rhs|gat:term" mode="tex">	
		<xsl:text>\ofT{</xsl:text>
		<xsl:apply-templates select="ccseq:*" mode="tex"/>
		<xsl:text>}{</xsl:text>
		<xsl:apply-templates select="ccseq:*/gat:type/ccseq:*" mode="tex"/>
		<xsl:text>}</xsl:text>				      
	</xsl:template>
	

	<xsl:template match="Ob" mode="tex">
		<xsl:text>Ob(</xsl:text>
		<xsl:apply-templates select="ccseq:*" mode="tex"/>
		<xsl:text>)</xsl:text>
	</xsl:template>

	<xsl:template match="Hom" mode="tex">
		<xsl:text>Hom(</xsl:text>
		<xsl:apply-templates select="ccseq:*[1]" mode="tex"/>
		<xsl:text>, </xsl:text>
		<xsl:apply-templates select="ccseq:*[2]" mode="tex"/>
		<xsl:text>)</xsl:text>
	</xsl:template>

	<xsl:template match="HomSeq" mode="tex">
		<xsl:text>H\overrightarrow{om}(</xsl:text>
		<xsl:apply-templates select="ccseq:*[1]" mode="tex"/>
		<xsl:text>, </xsl:text>
		<xsl:apply-templates select="ccseq:*[2]" mode="tex"/>
		<xsl:text>)</xsl:text>
	</xsl:template>

	<xsl:template match="o"  mode="tex">		
		<xsl:text>o_{</xsl:text>
		<xsl:apply-templates select="ccseq:*[1]" mode="tex"/>
		<xsl:text>}</xsl:text>
				<xsl:variable name="args" as="xs:string *">
			<xsl:for-each select="ccseq:*[position() &gt; 1]">
				<xsl:variable name="arg">
					<xsl:apply-templates select="." mode="tex"/>
				</xsl:variable>
				<xsl:value-of select="$arg"/>
			</xsl:for-each>
		</xsl:variable>
		<xsl:text>(</xsl:text>
		<xsl:value-of select="string-join($args,',')"/>
		<xsl:text>)</xsl:text>
	</xsl:template>

	<xsl:template match="q" mode="tex">
		<xsl:text>q_{</xsl:text>
		<xsl:apply-templates select="*[1]" mode="tex"/>
		<xsl:text>}(</xsl:text>
		<xsl:apply-templates select="*[2]" mode="tex"/>
		<xsl:text>,</xsl:text>
		<xsl:apply-templates select="*[3]" mode="tex"/>
		<xsl:text>)</xsl:text>
	</xsl:template>

	<xsl:template match="star" mode="tex">
	    <xsl:text>{</xsl:text>
		<xsl:choose> 
			<xsl:when test="*[2][self::o|self::star]">
				<xsl:text>(</xsl:text>
				<xsl:apply-templates select="*[2]" mode="tex"/>
				<xsl:text>)</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="*[2]" mode="tex"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>}_{</xsl:text>
		   <xsl:apply-templates select="*[1]" mode="tex"/>
		<xsl:text>}^*</xsl:text>
		<xsl:choose> 
			<xsl:when test="*[3][self::o | self::star]">
				<xsl:text>(</xsl:text>
				<xsl:apply-templates select="*[3]" mode="tex"/>
				<xsl:text>)</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="*[3]" mode="tex"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="s" mode="tex">
		<xsl:text>s_{</xsl:text>
		<xsl:apply-templates select="*[1]" mode="tex"/>
		<xsl:text>}(</xsl:text>
		<xsl:apply-templates select="*[2]" mode="tex"/>
		<xsl:text>)</xsl:text>
	</xsl:template>

	<xsl:template match="p" mode="tex">
		<xsl:text>p^{</xsl:text>
		<xsl:apply-templates select="*[1]" mode="tex"/>
		<xsl:text>}_{</xsl:text>
		<xsl:apply-templates select="*[2]" mode="tex"/>
		<xsl:text>}</xsl:text>
	</xsl:template>

	<xsl:template match="id" mode="tex">
		<xsl:text>id_{</xsl:text>
		<xsl:apply-templates select="*[1]" mode="tex"/>
		<xsl:text>}</xsl:text>
	</xsl:template>


	<xsl:template match="a|b|c|d|e" mode="tex">
		<xsl:value-of select="name()"/>
	</xsl:template>
		<xsl:template match="gat:lhs|gat:rhs|gat:term" mode="tex">	
		<xsl:text>\ofT{</xsl:text>
		<xsl:apply-templates select="ccseq:*" mode="tex"/>
		<xsl:text>}{</xsl:text>
		<xsl:apply-templates select="ccseq:*/gat:type/ccseq:*" mode="tex"/>
		<xsl:text>}</xsl:text>				      
	</xsl:template>
	
	<xsl:template match="subm" mode="tex">
	    <xsl:text>{</xsl:text>
		<xsl:choose> 
			<xsl:when test="*[2][self::o|self::star]">
				<xsl:text>(</xsl:text>
				<xsl:apply-templates select="*[2]" mode="tex"/>
				<xsl:text>)</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="*[2]" mode="tex"/>
			</xsl:otherwise>
		</xsl:choose>
				<xsl:text>}_{</xsl:text>
		   <xsl:apply-templates select="*[1]" mode="tex"/>
		<xsl:text>}^*</xsl:text>
		<xsl:choose> 
			<xsl:when test="*[3][self::o | self::star]">
				<xsl:text>(</xsl:text>
				<xsl:apply-templates select="*[3]" mode="tex"/>
				<xsl:text>)</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="*[3]" mode="tex"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	
	
	<!-- tex.short -->
	
	
	
	<xsl:template match="gat:lhs|gat:rhs|gat:term" mode="tex.short">	
		<xsl:text>\ofT{</xsl:text>
		<xsl:apply-templates select="ccseq:*" mode="tex.short"/>
		<xsl:text>}{</xsl:text>
		<xsl:apply-templates select="ccseq:*/gat:type/ccseq:*" mode="tex.short"/>
		<xsl:text>}</xsl:text>				      
	</xsl:template>

	<xsl:template match="Ob" mode="tex.short">
		<xsl:text>Ob(</xsl:text>
		<xsl:apply-templates select="ccseq:*" mode="tex.short"/>
		<xsl:text>)</xsl:text>
	</xsl:template>

	<xsl:template match="Hom" mode="tex.short">
		<xsl:text>Hom(</xsl:text>
		<xsl:apply-templates select="ccseq:*[1]" mode="tex.short"/>
		<xsl:text>, </xsl:text>
		<xsl:apply-templates select="ccseq:*[2]" mode="tex.short"/>
		<xsl:text>)</xsl:text>
	</xsl:template>

	<xsl:template match="HomSeq" mode="tex.short">
		<xsl:text>H\overrightarrow{om}(</xsl:text>
		<xsl:apply-templates select="ccseq:*[1]" mode="tex.short"/>
		<xsl:text>, </xsl:text>
		<xsl:apply-templates select="ccseq:*[2]" mode="tex.short"/>
		<xsl:text>)</xsl:text>
	</xsl:template>

	<xsl:template match="o"  mode="tex.short">		
		<xsl:text>o</xsl:text>
		<xsl:variable name="args" as="xs:string *">
			<xsl:for-each select="ccseq:*[position() &gt; 1]">
				<xsl:variable name="arg">
					<xsl:apply-templates select="." mode="tex.short"/>
				</xsl:variable>
				<xsl:value-of select="$arg"/>
			</xsl:for-each>
		</xsl:variable>
		<xsl:text>(</xsl:text>
		<xsl:value-of select="string-join($args,',')"/>
		<xsl:text>)</xsl:text>
	</xsl:template>

	<xsl:template match="q" mode="tex.short">
		<xsl:text>q(</xsl:text>
		<xsl:apply-templates select="*[2]" mode="tex.short"/>
		<xsl:text>,</xsl:text>
		<xsl:apply-templates select="*[3]" mode="tex.short"/>
		<xsl:text>)</xsl:text>
	</xsl:template>

	<xsl:template match="star" mode="tex.short">
	    <xsl:text>{</xsl:text>
		<xsl:choose> 
			<xsl:when test="*[2][self::o|self::star]">
				<xsl:text>(</xsl:text>
				<xsl:apply-templates select="*[2]" mode="tex.short"/>
				<xsl:text>)</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="*[2]" mode="tex.short"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>}</xsl:text>
		<xsl:text>^*</xsl:text>
		<xsl:choose> 
			<xsl:when test="*[3][self::o | self::star]">
				<xsl:text>(</xsl:text>
				<xsl:apply-templates select="*[3]" mode="tex.short"/>
				<xsl:text>)</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="*[3]" mode="tex.short"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="subm" mode="tex.short">
	    <xsl:text>{</xsl:text>
		<xsl:choose> 
			<xsl:when test="*[2][self::o|self::star]">
				<xsl:text>(</xsl:text>
				<xsl:apply-templates select="*[2]" mode="tex.short"/>
				<xsl:text>)</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="*[2]" mode="tex.short"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>}^*</xsl:text>
		<xsl:choose> 
			<xsl:when test="*[2][self::o | self::star]">
				<xsl:text>(</xsl:text>
				<xsl:apply-templates select="*[3]" mode="tex.short"/>
				<xsl:text>)</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="*[3]" mode="tex.short"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="s" mode="tex.short">
		<xsl:text>s(</xsl:text>
		<xsl:apply-templates select="*[2]" mode="tex.short"/>
		<xsl:text>)</xsl:text>
	</xsl:template>

	<xsl:template match="p" mode="tex.short">
		<xsl:text>p</xsl:text>
		<!--
        go for short being very short for p		
		<xsl:text>_{</xsl:text>
		<xsl:apply-templates select="*[2]" mode="tex.short"/>
		<xsl:text>}</xsl:text>
		-->
	</xsl:template>
	

</xsl:transform>
