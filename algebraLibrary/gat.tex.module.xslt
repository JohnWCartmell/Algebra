<xsl:transform version="2.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:gat              ="http://www.entitymodelling.org/theory/generalisedalgebraictheory"
		xpath-default-namespace="http://www.entitymodelling.org/theory/generalisedalgebraictheory"	   
		xmlns="http://www.entitymodelling.org/theory/generalisedalgebraictheory">
	<xsl:strip-space elements="*"/> 

	<xsl:template match="/" mode="tex" >
		<xsl:text>
			\documentclass[10pt,a4paper,fleqn]{article}
			\usepackage{amsmath}
			\usepackage{mathtools}
			\usepackage{alltt}
			\usepackage{mnsymbol}
			\setlength{\mathindent}{0pt}
			\renewcommand{\ttdefault}{txtt}
			\newcommand{\ofT}[2]
			{#1 \in #2
			}
			\newcommand{\isT}[1]
			{#1\mbox{ is a type}}
			\newcommand{\tstyle}{\vdash}
			\begin{document}
			\title{
		</xsl:text>
		<xsl:value-of select="algebra/name"/>
		<xsl:text>}
			\maketitle
		</xsl:text>

		<xsl:if test="algebra/(sort|operator|axiom|rewriteRule|lemma)">
			<xsl:text>
				\noindent
				\begin{eqnarray}
			</xsl:text>
			<xsl:text disable-output-escaping="yes">
				<![CDATA[&]]>
			</xsl:text>
			<xsl:text>Symbol</xsl:text>
			<xsl:text disable-output-escaping="yes">
				<![CDATA[&]]>
			</xsl:text>     
			<xsl:text>\hspace{1cm}Introductory Rule \nonumber \\
			</xsl:text>
			<xsl:apply-templates select="algebra/(sort|operator)" mode="tex_tablestyle"/>
			<xsl:text disable-output-escaping="yes">
				<![CDATA[&]]>
			</xsl:text>
			<xsl:text>Axioms</xsl:text>
			<xsl:text disable-output-escaping="yes">
				<![CDATA[&]]>
			</xsl:text>
			<xsl:text>\nonumber \\
			</xsl:text>
			<xsl:apply-templates select="algebra/(axiom|rewriteRule)" mode="tex_tablestyle"/>
			<xsl:text>\end{eqnarray} 
				\noindent
				Derived Rules\\
			</xsl:text>
			<xsl:apply-templates select="algebra/lemma" mode="tex_linestyle"/> 
		</xsl:if>		

		<xsl:if test="algebra/diamond">
			<xsl:text>\section{Non-Confluent Diamonds}
			</xsl:text>
		</xsl:if>
		<xsl:apply-templates select="algebra/diamond[NON-CONFLUENT]" mode="tex"/>

		<xsl:text>
			\end{document}
			&#xA;
		</xsl:text>
	</xsl:template>

	<xsl:template match="diamond" mode="tex">
		<xsl:text>Identity </xsl:text>
		<xsl:value-of select="identity"/>
		<xsl:text> </xsl:text> 
		<xsl:text>\\&#xA;</xsl:text>
		<xsl:text>\begin{align*}&#xA;</xsl:text>
		<xsl:text disable-output-escaping="yes"><![CDATA[&]]></xsl:text>
		<xsl:apply-templates select="type_corrected/top_of_diamond/tT-rule/tT-conclusion/term/*" mode="tex"/>
		<xsl:text disable-output-escaping="yes"><![CDATA[&]]></xsl:text>
		<xsl:text>\mbox{(top)}\\&#xA;</xsl:text>
		<xsl:text disable-output-escaping="yes"><![CDATA[&]]></xsl:text>
		<xsl:apply-templates select="type_corrected/top_of_diamond/tT-rule/tT-conclusion/type/*" mode="tex"/>
		<xsl:text disable-output-escaping="yes"><![CDATA[&]]></xsl:text>
		<xsl:text>\mbox{(type)}\\&#xA;</xsl:text>
		<xsl:text disable-output-escaping="yes"><![CDATA[&]]></xsl:text>
		<xsl:apply-templates select="leftside/left_reduction_normalised/term/*" mode="tex"/>
		<xsl:text disable-output-escaping="yes"><![CDATA[&]]></xsl:text>
		<xsl:text>\mbox{(left)}\\&#xA;</xsl:text>
		<xsl:text disable-output-escaping="yes"><![CDATA[&]]></xsl:text>
		<xsl:apply-templates select="rightside/right_reduction_normalised/term/*" mode="tex"/>
		<xsl:text disable-output-escaping="yes"><![CDATA[&]]></xsl:text>
		<xsl:text>\mbox{(right)}\\&#xA;</xsl:text>
		<xsl:text>\end{align*}&#xA;</xsl:text>
		<xsl:text>where&#xA;</xsl:text>
		<xsl:text>\begin{equation*}&#xA;</xsl:text>
		<xsl:text>\begin{array}{l}&#xA;</xsl:text>
		<xsl:for-each select="type_corrected/top_of_diamond/tT-rule/context/*">
			<xsl:apply-templates select="." mode="tex"/>
			<xsl:text>\\&#xA;</xsl:text>
		</xsl:for-each>
		<xsl:text>\end{array}&#xA;</xsl:text>
		<xsl:text>\end{equation*}&#xA;</xsl:text>
		<xsl:text>\noindent\rule{8cm}{0.4pt}&#xA;</xsl:text>\\
		<xsl:text>&#xA;</xsl:text>
		<xsl:text>\noindent&#xA;</xsl:text>
	</xsl:template>

	<xsl:template match="/" mode="tex_rulestyle" >
		<xsl:text>
			\documentclass[10pt]{article}
			\usepackage[a4paper,margin=1in,landscape]{geometry}
			\usepackage{mathtools}
			\usepackage{alltt}
			\usepackage{mnsymbol}
			\renewcommand{\ttdefault}{txtt}
			\newcommand{\ofT}[2]
			{#1 \in #2
			}
			\newcommand{\isT}[1]
			{#1\mbox{ is a type}}
			\newcommand{\tstyle}{\vdash}
			\begin{document}
			\title{
		</xsl:text>
		<xsl:value-of select="algebra/name"/>
		<xsl:text>}
			\maketitle
		</xsl:text>
		<xsl:apply-templates  mode="tex_rulestyle"/>
		<xsl:text>
			\end{document}
			&#xA;
		</xsl:text>
	</xsl:template>

	<xsl:template match="algebra" mode="tex_rulestyle">
		<xsl:message> in algebra</xsl:message>
		<xsl:apply-templates mode="tex_rulestyle"/>
	</xsl:template>

	<xsl:template match="sort|operator" mode="tex_rulestyle">
		<xsl:text>
			\begin{equation}
		</xsl:text>
		<xsl:text>\tag{$</xsl:text>
		<xsl:value-of select="id"/> 
		<xsl:text>$ \textit{intro}}</xsl:text> 
		<xsl:apply-templates select="T-rule|tT-rule" mode="tex_rulestyle"/>
		<xsl:text>
			\end{equation}
		</xsl:text>
		<xsl:apply-templates mode="tex_report_errors"/>
	</xsl:template>

	<xsl:template match="rewriteRule|axiom" mode="tex_rulestyle">
		<xsl:message>in <xsl:value-of select="name()"/> <xsl:value-of select="gat:id"/></xsl:message>
		<xsl:text>
			\begin{equation}
		</xsl:text>
		<xsl:text>\tag{</xsl:text>
		<xsl:value-of select="id"/> 
		<xsl:text>}</xsl:text>   
		<xsl:apply-templates select="tt-rule|TT-rule" mode="tex_rulestyle"/>
		<xsl:text>
			\end{equation}
		</xsl:text>
		<xsl:apply-templates mode="tex_report_errors"/>
	</xsl:template>

	<xsl:template match="lemma" mode="tex_rulestyle">
		<xsl:variable name="filename" select="concat('example',id,'.tex')"/>
		<xsl:message>Filenamne is <xsl:value-of select="$filename"/>
		</xsl:message>
		<xsl:text>\input{</xsl:text>
		<xsl:value-of select="$filename"/>
		<xsl:text>}
		</xsl:text>
		<xsl:result-document href="{$filename}">
			<xsl:text>
				\begin{equation}
			</xsl:text>
			<xsl:text>\tag{</xsl:text>
			<xsl:value-of select="id"/> 
			<xsl:text>}</xsl:text>   
			<xsl:apply-templates select="T-rule|tT-rule|tt-rule|TT-rule" mode="tex_rulestyle"/>
			<xsl:text>
				\end{equation}
			</xsl:text>
		</xsl:result-document>
		<xsl:apply-templates mode="tex_report_errors"/>
	</xsl:template>

	<!-- changed 15 May 2018 to use a short style -->
	<xsl:template match="T-rule|tT-rule|tt-rule|TT-rule" mode="tex_rulestyle">
		<xsl:if test ="context/*">
			<xsl:text>&#xA;\frac{</xsl:text>
			<xsl:apply-templates select="context" mode="tex.short"/>
			<xsl:text>}{</xsl:text>
		</xsl:if>
		<xsl:apply-templates select="T-conclusion|tT-conclusion|tt-conclusion|TT-conclusion" mode="tex.short"/>
		<xsl:if test ="context/*">   
			<xsl:text>}</xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="tex_rulestyle">
		<xsl:message>Passing over element name() <xsl:value-of select="name()"/>
		</xsl:message>
	</xsl:template>


	<xsl:template match="sort|operator" mode="tex_tablestyle">
		<xsl:text disable-output-escaping="yes">
			<![CDATA[&]]>
		</xsl:text>
		<xsl:value-of select="id"/> \hspace{0.25cm}
		<xsl:text disable-output-escaping="yes">
			<![CDATA[&]]>\hspace{1cm}</xsl:text>
		<xsl:apply-templates select="T-rule|tT-rule" mode="tex"/>
		<xsl:text> \\
		</xsl:text>
	</xsl:template>

	<xsl:template match="rewriteRule|axiom" mode="tex_tablestyle">
		<xsl:text disable-output-escaping="yes">
			<![CDATA[&]]>
		</xsl:text>
		<!--<xsl:value-of select="id"/>-->
		<xsl:text disable-output-escaping="yes">
			<![CDATA[&]]>
		</xsl:text>		
		<xsl:apply-templates select="TT-rule|tt-rule" mode="tex_linestyle"/>
		<xsl:if test="following-sibling::*[self::sort|self::operator|self::rewriteRule|self::equation]">
			<xsl:text> \\</xsl:text>
		</xsl:if>
		<xsl:text>
		</xsl:text> 
	</xsl:template>

	<xsl:template match="T-rule|tT-rule|tt-rule|TT-rule" mode="tex_linestyle">
		<xsl:if test ="context/*">
			<xsl:apply-templates select="context" mode="tex"/>
			<xsl:text>\tstyle </xsl:text>
		</xsl:if>
		<xsl:apply-templates select="T-conclusion|tT-conclusion|tt-conclusion|TT-conclusion" mode="tex"/>
	</xsl:template>

	<xsl:template match="rewriteRule|axiom" mode="tex_linestyle">
		<xsl:text>
			\noindent
			$</xsl:text>
		<xsl:apply-templates select="tt-rule|TT-rule" mode="tex_linestyle"/>		
		<xsl:text>
			$ \\
		</xsl:text>
	</xsl:template>

	<xsl:template match="lemma" mode="tex_linestyle">
		<xsl:variable name="filename" select="concat('example',id,'.tex')"/>
		<xsl:text>\input{</xsl:text>
		<xsl:value-of select="$filename"/>
		<xsl:text>}\\</xsl:text>
		<xsl:result-document href="{$filename}">
			<xsl:text>
				\noindent
				$</xsl:text>  
			<xsl:apply-templates select="T-rule|tT-rule|TT-rule|tt-rule" mode="tex"/>			
			<xsl:text>$ \\</xsl:text>

		</xsl:result-document>
	</xsl:template>

	<xsl:template match="T-conclusion" mode="tex">
		<xsl:message>in T-conclustion</xsl:message>
		<xsl:text>\isT{</xsl:text>
		<xsl:apply-templates select="type/*" mode="tex"/>
		<xsl:text>}</xsl:text>
	</xsl:template>

	<xsl:template match="tT-conclusion" mode="tex">
		<xsl:text>\ofT{</xsl:text>
		<xsl:apply-templates select="term/*" mode="tex"/>  
		<xsl:text>}{</xsl:text>
		<xsl:apply-templates select="type/*" mode="tex"/>
		<xsl:text>}</xsl:text>
	</xsl:template>

	<xsl:template match="TT-conclusion" mode="tex">
		<xsl:apply-templates select="lhs/*" mode="tex"/>  
		<xsl:text>=</xsl:text>
		<xsl:apply-templates select="rhs/*" mode="tex"/>
	</xsl:template>

	<xsl:template match="tt-conclusion" mode="tex">
		<xsl:variable name="lhstypetex">
			<xsl:apply-templates select="lhs/*/gat:type/*" mode="tex"/>
		</xsl:variable>
		<xsl:variable name="rhstypetex">
			<xsl:apply-templates select="rhs/*/gat:type/*" mode="tex"/>
		</xsl:variable>
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
		<xsl:choose>
			<xsl:when test="ancestor::rewriteRule">
				<xsl:text>\Rightarrow </xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text> = </xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="rhs/*/gat:type/*">
				<xsl:text>\ofT{</xsl:text>
				<xsl:apply-templates select="rhs/*" mode="tex"/>
				<xsl:text>}{</xsl:text>
				<xsl:value-of select="$rhstypetex"/>
				<xsl:text>}</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="rhs/*" mode="tex"/>
			</xsl:otherwise> 
		</xsl:choose>
	</xsl:template>
	
		<xsl:template match="T-conclusion" mode="tex.short">
		<xsl:message>in T-conclustion</xsl:message>
		<xsl:text>\isT{</xsl:text>
		<xsl:apply-templates select="type/*" mode="tex"/>
		<xsl:text>}</xsl:text>
	</xsl:template>

	<xsl:template match="tT-conclusion" mode="tex.short">
		<xsl:text>\ofT{</xsl:text>
		<xsl:apply-templates select="term/*" mode="tex"/>  
		<xsl:text>}{</xsl:text>
		<xsl:apply-templates select="type/*" mode="tex"/>
		<xsl:text>}</xsl:text>
	</xsl:template>

	<xsl:template match="TT-conclusion" mode="tex.short">
		<xsl:apply-templates select="lhs/*" mode="tex"/>  
		<xsl:text>=</xsl:text>
		<xsl:apply-templates select="rhs/*" mode="tex"/>
	</xsl:template>


	<xsl:template match="tt-conclusion" mode="tex.short">
		<xsl:variable name="lhstypetex">
			<xsl:apply-templates select="lhs/*/gat:type/*" mode="tex"/>
		</xsl:variable>
		<xsl:variable name="rhstypetex">
			<xsl:apply-templates select="rhs/*/gat:type/*" mode="tex"/>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$lhstypetex=$rhstypetex">
				<xsl:apply-templates select="lhs/*" mode="tex.short"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>\ofT{</xsl:text>
				<xsl:apply-templates select="lhs/*" mode="tex"/>
				<xsl:text>}{</xsl:text>
				<xsl:value-of select="$lhstypetex"/>
				<xsl:text>}</xsl:text>
			</xsl:otherwise>
		</xsl:choose>			     
		<xsl:choose>
			<xsl:when test="ancestor::rewriteRule">
				<xsl:text>\Rightarrow </xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text> = </xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="rhs/*/gat:type/*">
				<xsl:text>\ofT{</xsl:text>
				<xsl:apply-templates select="rhs/*" mode="tex.short"/>
				<xsl:text>}{</xsl:text>
				<xsl:value-of select="$rhstypetex"/>
				<xsl:text>}</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="rhs/*" mode="tex"/>
			</xsl:otherwise> 
		</xsl:choose>
	</xsl:template>


	<xsl:template match="gat:*" mode="tex">
		<xsl:message>Passing over element gat:name() <xsl:value-of select="name()"/>
		</xsl:message>
	</xsl:template>

	<xsl:template match="gat:type_error" mode="tex">

	</xsl:template>

	<xsl:template match="algebra" mode="tex">
		<xsl:apply-templates mode="tex"/>
	</xsl:template>

	<xsl:template match="context" mode="tex">
		<xsl:for-each select="decl|sequence">
			<xsl:apply-templates select="." mode ="tex"/>
			<xsl:if test="following-sibling::decl | following-sibling::sequence">
				<xsl:text>,\, </xsl:text>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="context" mode="tex.short">
		<xsl:for-each select="decl|sequence">
			<xsl:apply-templates select="." mode ="tex.short"/>
			<xsl:if test="following-sibling::decl | following-sibling::sequence">
				<xsl:text>,\, </xsl:text>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>


	<xsl:template match="decl[not(gat:term)]" mode="tex">
		<xsl:text>\ofT{</xsl:text>
		<xsl:value-of select="name"/>
		<xsl:text>}{</xsl:text>
		<xsl:apply-templates select="type" mode="tex"/>
		<xsl:text>}</xsl:text>
		<xsl:if test="gat:term">
			<xsl:text>=_{def}</xsl:text>
			<xsl:apply-templates select="gat:term" mode="tex"/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="decl[gat:term]" mode="tex">
		<xsl:value-of select="name"/>
		<xsl:text> \buildrel \text{d{}ef}\over = </xsl:text>
		<xsl:apply-templates select="gat:term" mode="tex"/>
		<xsl:apply-templates select="type" mode="tex"/>
	</xsl:template>

	<xsl:template match="decl[not(gat:term)]" mode="tex.short">
		<xsl:text>\ofT{</xsl:text>
		<xsl:value-of select="name"/>
		<xsl:text>}{</xsl:text>
		<xsl:apply-templates select="type" mode="tex.short"/>
		<xsl:text>}</xsl:text>
		<xsl:if test="gat:term">
			<xsl:text>=_{def}</xsl:text>
			<xsl:apply-templates select="gat:term" mode="tex.short"/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="decl[gat:term]" mode="tex.short">
		<xsl:value-of select="name"/>
		<xsl:text> \buildrel \text{d{}ef}\over = </xsl:text>
		<xsl:apply-templates select="gat:term" mode="tex.short"/>
		<xsl:apply-templates select="type" mode="tex.short"/>
	</xsl:template>


	<xsl:template match="sequence" mode="tex">
		<xsl:text>\ofT{\vec{</xsl:text>
		<xsl:value-of select="name"/>
		<xsl:text>}}{</xsl:text>
		<xsl:apply-templates select="type" mode="tex"/>
		<xsl:text>}</xsl:text>
	</xsl:template>

	<xsl:template match="sequence" mode="tex.short">
		<xsl:text>\ofT{\vec{</xsl:text>
		<xsl:value-of select="name"/>
		<xsl:text>}}{</xsl:text>
		<xsl:apply-templates select="type" mode="tex.short"/>
		<xsl:text>}</xsl:text>
	</xsl:template>


	<xsl:template match="type" mode="tex">
		<xsl:apply-templates mode="tex"/> 
	</xsl:template>

	<xsl:template match="type" mode="tex.short">
		<xsl:apply-templates mode="tex.short"/> 
	</xsl:template>

	<xsl:template match="*:var" mode="tex.short">
		<xsl:value-of select="name"/>
	</xsl:template>

	<xsl:template match="*:var" mode="tex">
		<xsl:value-of select="name"/>
	</xsl:template>


	<xsl:template match="*:seq" mode="tex">
		<xsl:text>\vec{</xsl:text>
		<xsl:value-of select="name"/>
		<xsl:text>}</xsl:text>
	</xsl:template>


	<xsl:template match="*:seq" mode="tex.short">
		<xsl:text>\vec{</xsl:text>
		<xsl:value-of select="name"/>
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

	<xsl:template match="*" mode="tex_report_errors">    
		<xsl:apply-templates select="*" mode="tex_report_errors"/>	 	
	</xsl:template>

	<xsl:template match="*[parent::T-rule|parent::tT-rule|parent::tt-rule|parent::TT-rule][self::lhs|self::rhs|self::term|self::type][descendant::type_error]" mode="tex_report_errors">
		<xsl:value-of select="name()"/> 
		<xsl:text> has error(s):
		</xsl:text>
		<xsl:apply-templates select="*" mode="tex_report_errors"/>
	</xsl:template>


	<xsl:template match="gat:type_error" mode="tex_report_errors">
		<xsl:apply-templates select="*" mode="tex_report_errors"/>
		<xsl:text>\\
		</xsl:text>
	</xsl:template>

	<xsl:template match="gat:description/gat:text" mode="tex_report_errors">
		<xsl:value-of select="."/>
	</xsl:template>

	<xsl:template match="gat:description/gat:term" mode="tex_report_errors">
		<xsl:text>$</xsl:text>
		<xsl:apply-templates select="*" mode="tex"/>
		<xsl:text>$</xsl:text>
	</xsl:template>

	<!-- end of tex -->


</xsl:transform>

