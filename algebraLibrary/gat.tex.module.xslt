<xsl:transform version="2.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:gat              ="http://www.entitymodelling.org/theory/generalisedalgebraictheory"
		xpath-default-namespace="http://www.entitymodelling.org/theory/generalisedalgebraictheory"	   
		xmlns="http://www.entitymodelling.org/theory/generalisedalgebraictheory">
	<xsl:strip-space elements="*"/> 


	<xsl:template match="/" mode="tex" >
		<xsl:text>
			\documentclass[10pt,a4paper]{article}
			\usepackage{mathtools}
			\usepackage{alltt}
			\usepackage{mnsymbol}
			\renewcommand{\ttdefault}{txtt}
			\newcommand{\ofT}[2]
			{#1 \in #2
			}
			\newcommand{\tstyle}{\vdash}
			\begin{document}
			\title{
		</xsl:text>
		<xsl:value-of select="algebra/name"/>
		<xsl:text>
			Rules}
			\maketitle
		</xsl:text>
		<xsl:apply-templates mode="tex"/>
		<xsl:text>
			\end{document}
			&#xA;
		</xsl:text>
	</xsl:template>


	<!--
<xsl:template match="*" >
<xsl:message>Wildcard name() <xsl:value-of select="name()" /> </xsl:message>
	<xsl:apply-templates mode="tex"/>
</xsl:template>
-->

	<!--
<xsl:template match="term" mode="tex"> 
	<xsl:apply-templates mode="tex"/>	   
</xsl:template>
-->

	<xsl:template match="example" mode="tex">
		<xsl:text>
			\begin{equation}
		</xsl:text>
		<xsl:text>\tag{</xsl:text>
		<xsl:value-of select="id"/> 
		<xsl:text>}</xsl:text>   
		<xsl:text>&#xA;\frac{</xsl:text>
		<xsl:apply-templates select="context" mode="tex"/>
		<xsl:text>}{</xsl:text>
		<xsl:apply-templates select="term" mode="tex"/>
		<xsl:text>
			}
			\end{equation}
		</xsl:text>
	</xsl:template>

	<xsl:template match="*" mode="tex">
		<xsl:message>Wildcard mode tex name() <xsl:value-of select="name()"/> </xsl:message>
		<xsl:apply-templates mode="tex"/>
	</xsl:template>

	<xsl:template match="algebra" mode="tex">
		<xsl:apply-templates mode="tex"/>
	</xsl:template>

	<xsl:template match="rewriteRule|equation" mode="tex">
		<xsl:variable name="lhstypetex">
			<xsl:apply-templates select="lhs/*/gat:type/*" mode="tex"/>
		</xsl:variable>
		<xsl:variable name="rhstypetex">
			<xsl:apply-templates select="rhs/*/gat:type/*" mode="tex"/>
		</xsl:variable>
		<xsl:text>
			\begin{equation}
		</xsl:text>
		<xsl:text>\tag{</xsl:text>
		<xsl:value-of select="id"/> 
		<xsl:text>}</xsl:text>   
		<xsl:text>&#xA;\frac{</xsl:text>
		<xsl:apply-templates select="context" mode="tex"/>
		<xsl:text>}{</xsl:text>
		<xsl:choose>
			<xsl:when test="$lhstypetex=$rhstypetex">
				<xsl:apply-templates select="lhs/*" mode="tex"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>\ofT{</xsl:text>
				<xsl:apply-templates select="lhs/*" mode="tex"/>
				<xsl:text>}{</xsl:text>
				<xsl:value-of select="$lhstypetex"/>
				<xsl:text>}</xsl:text>
			</xsl:otherwise>
		</xsl:choose>			     
		<!--
    <xsl:text>\left\{</xsl:text>
    <xsl:for-each select="lhs">
      <xsl:apply-templates mode="number"/>
    </xsl:for-each>
    <xsl:text>\right\}</xsl:text>
    -->
		<xsl:choose>
			<xsl:when test="self::equation">
				<xsl:text> = </xsl:text>
			</xsl:when>
			<xsl:when test="self::rewriteRule">
				<xsl:text>\Rightarrow </xsl:text>
			</xsl:when>
		</xsl:choose>

		<xsl:text>\ofT{</xsl:text>
		<xsl:apply-templates select="rhs/*" mode="tex"/>
		<xsl:text>}{</xsl:text>

		<xsl:value-of select="$rhstypetex"/>
		<xsl:text>}</xsl:text>
		<!--
    <xsl:text>\left\{</xsl:text>
    <xsl:for-each select="rhs">
      <xsl:apply-templates mode="number"/>
    </xsl:for-each>
    <xsl:text>\right\}</xsl:text>
    -->
		<xsl:text>
			}
			\end{equation}
		</xsl:text>

	</xsl:template>


	<xsl:template match="context" mode="tex">
		<xsl:for-each select="decl">
			<xsl:apply-templates select="." mode ="tex"/>
			<xsl:if test="following-sibling::decl">
				<xsl:text>,\ </xsl:text>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="decl" mode="tex">
		<xsl:text>\ofT{</xsl:text>
		<xsl:value-of select="name"/>
		<xsl:text>}{</xsl:text>
		<xsl:apply-templates select="type" mode="tex"/>
		<xsl:text>}</xsl:text>
	</xsl:template>

	<xsl:template match="type" mode="tex">
		<xsl:apply-templates mode="tex"/> 
	</xsl:template>

	<xsl:template match="*:var" mode="tex">
		<xsl:value-of select="name"/>
	</xsl:template>

	<xsl:template match="*:seq" mode="tex">
		<xsl:variable name="stem" select="replace(., '[\d]', '')"/>
		<xsl:variable name="subscript" select="replace(., '[^\d]', '')"/>
		<xsl:text>\vec{</xsl:text>
		<xsl:value-of select="$stem"/>
		<xsl:value-of select="if (string-length($subscript)=0) then '' else concat('_',$subscript)"/>
		<xsl:text>}</xsl:text>

	</xsl:template>

	<xsl:template match="point" mode="tex">
		<xsl:text>\left[</xsl:text>
		<xsl:apply-templates select="*[1]" mode="tex"/>
		<xsl:text>\right]</xsl:text>
	</xsl:template>

	<xsl:template match="tail"  mode="tex">
		<xsl:variable name="args" as="xs:string *">
			<xsl:for-each select="*">
				<xsl:variable name="arg">
					<xsl:apply-templates select="." mode="tex"/>
				</xsl:variable>
				<xsl:value-of select="$arg"/>
			</xsl:for-each>
		</xsl:variable>
		<xsl:text>tail(</xsl:text>
		<xsl:value-of select="string-join($args,',')"/>
		<xsl:text>)</xsl:text>
	</xsl:template>

	<!-- end of tex -->


</xsl:transform>

