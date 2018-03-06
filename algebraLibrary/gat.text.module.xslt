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
		<xsl:for-each select="tt-rule/tt-conclusion/lhs">
			<xsl:apply-templates mode="text"/>
		</xsl:for-each>
		<xsl:text>{</xsl:text>
		<xsl:for-each select="tt-rule/tt-conclusion/lhs">
			<xsl:apply-templates mode="number"/>
		</xsl:for-each>
		<xsl:text>}</xsl:text>
		<xsl:text disable-output-escaping="yes"> => </xsl:text>
	<xsl:for-each select="tt-rule/tt-conclusion/rhs">
		<xsl:apply-templates mode="text"/>
	</xsl:for-each>
	<xsl:text>{</xsl:text>
	<xsl:for-each select="tt-rule/tt-conclusion/rhs">
		<xsl:apply-templates mode="number"/>
	</xsl:for-each>
	<xsl:text>}</xsl:text>
	<xsl:text>&#xA;</xsl:text>
</xsl:template>

<xsl:template match="equation" mode="text">
	<xsl:text>&#xA;</xsl:text>
	<xsl:value-of select="id"/> 
	<xsl:text>.  </xsl:text>    
	<xsl:for-each select="tt-rule/tt-conclusion/lhs">
		<xsl:apply-templates mode="text"/>
	</xsl:for-each>
	<xsl:text> = </xsl:text>
	<xsl:for-each select="tt-rule/tt-conclusion/rhs">
		<xsl:apply-templates mode="text"/>
	</xsl:for-each>
	<xsl:text>&#xA;</xsl:text>
</xsl:template>


<xsl:template match="context" mode="text">
  <xsl:text> </xsl:text>
  <xsl:for-each select="*:decl | *:sequence">
	   <xsl:apply-templates  select="." mode="text"/>
     <xsl:if test="following-sibling::*:decl|following-sibling::*:sequence">
         <xsl:text>, </xsl:text>
     </xsl:if>
  </xsl:for-each>
</xsl:template>

<xsl:template match="*[self::*:decl|self::*:sequence]" mode="text">
	<xsl:value-of select="gat:name"/>
  <xsl:text>:</xsl:text>
  <xsl:apply-templates select="gat:type/*" mode="text"/>
</xsl:template>


<xsl:template match="*:var" mode="text">
	<xsl:value-of select="gat:name"/>
</xsl:template>

<xsl:template match="*:seq" mode="text">
	<xsl:text>.</xsl:text>
	<xsl:value-of select="gat:name"/>
	<xsl:text>.</xsl:text>
</xsl:template>

<xsl:template match="*:point" mode="text">
	<xsl:text>[</xsl:text>
	<xsl:apply-templates select="*" mode="text"/>
	<xsl:text>]</xsl:text>
</xsl:template>

<xsl:template match="substitution" mode="text">
  <xsl:text>&#xA;</xsl:text>
	<xsl:text>subject  SUBSTITUTIONS:</xsl:text>
	<xsl:apply-templates  select="subject/substitute" mode="text"/>
	<xsl:text></xsl:text>
  	<xsl:text>&#xA;</xsl:text>
  <xsl:text>target SUBSTITUTIONS:</xsl:text>
	<xsl:apply-templates  select="target/substitute" mode="text"/>
	<xsl:text></xsl:text>
</xsl:template>


<xsl:template match="substitute[child::*:var]" mode="text">
  <xsl:text> (</xsl:text>
  <xsl:apply-templates  select="*:var" mode="text"/>
	<xsl:text disable-output-escaping="yes">-></xsl:text>
	<xsl:apply-templates  select="gat:term/*" mode="text"/>
  <xsl:text>) </xsl:text>
</xsl:template>

<xsl:template match="substitute[child::*:seq]" mode="text">
  <xsl:text> (</xsl:text>
  <xsl:apply-templates  select="*:seq" mode="text"/>
	<xsl:text disable-output-escaping="yes">-> [</xsl:text>
  <xsl:for-each select="gat:term">
	   <xsl:apply-templates  mode="text"/>
     <xsl:if test="following-sibling::gat:term">
         <xsl:text>, </xsl:text>
     </xsl:if>
  </xsl:for-each>
  <xsl:text>]) </xsl:text>
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

	<xsl:template match="*" mode="text_report_errors">    
		<xsl:apply-templates select="*" mode="text_report_errors"/>	 	
	</xsl:template>

	<xsl:template match="*[parent::T-rule|parent::tT-rule|parent::tt-rule|parent::TT-rule][self::lhs|self::rhs|self::term|self::type][descendant::type_error]" 
	              mode="text_report_errors">
		<xsl:value-of select="name()"/> 
		<xsl:text> has error(s):
		</xsl:text>
		<xsl:apply-templates select="*" mode="text_report_errors"/>
	</xsl:template>
	
	<xsl:template match="gat:type_error" mode="text_report_errors">
		<xsl:value-of select="."/> 
		<xsl:text>

		</xsl:text>
	</xsl:template>


</xsl:transform>

