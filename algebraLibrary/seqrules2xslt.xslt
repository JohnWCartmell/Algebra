<!--
rules2xslt.xslt
**********************

DESCRIPTION

-->


<xsl:transform version="2.0" 
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:gat              ="http://www.entitymodelling.org/theory/generalisedalgebraictheory"
		xpath-default-namespace="http://www.entitymodelling.org/theory/generalisedalgebraictheory"	>   


  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

  <xsl:template match="/algebra">
    <xsl:element name="xsl:transform">
      <xsl:attribute name="version" select="'2.0'"/>
	  <xsl:attribute name="xpath-default-namespace" select="gat:namespace"/>
	  <xsl:copy-of select="namespace::*"/>
      <xsl:call-template name="generate_apply_named_rule"/>
      <xsl:apply-templates select="rewriteRule" mode="generate_rewrite"/>

    </xsl:element>
  </xsl:template>

  <xsl:variable name="blanks">
    <xsl:text>                                                                                                 </xsl:text>
  </xsl:variable>


  <xsl:template name="newline">
    <xsl:param name="level"/>
    <!--
    <xsl:text>xxx</xsl:text>
    <xsl:value-of select="substring($blanks,1,20+$level*3)"/>
-->
  </xsl:template>

  <xsl:template name="generate_apply_named_rule" match="algebra">
    <xsl:element name="xsl:template">
      <xsl:attribute name="name" select="'apply_named_rule'"/>
      <xsl:element name="xsl:param">					
        <xsl:attribute name="name" select="'ruleid'"/>
      </xsl:element>
      <xsl:element name="xsl:choose">
        <xsl:for-each select="rewriteRule">
          <xsl:element name="xsl:when">			
            <xsl:attribute name="test" select="concat('$ruleid=''',../name,id,'''')"/>
            <xsl:element name="xsl:call-template">
              <xsl:attribute name="name" select="concat(../name,id)"/>
            </xsl:element>
          </xsl:element>
        </xsl:for-each>
        <xsl:element name="xsl:otherwise">
          <xsl:element name="xsl:message">
						   **************** No such rule as '<xsl:element name="xsl:value-of">
              <xsl:attribute name="select" select="'$ruleid'"/>
            </xsl:element>'******************
          </xsl:element>
        </xsl:element>
      </xsl:element>
    </xsl:element>
  </xsl:template>

  <xsl:template name="generate_test_named_rule_applies" match="algebra">
    <xsl:element name="xsl:template">
      <xsl:attribute name="name" select="'test_named_rule_applies'"/>
      <xsl:element name="xsl:param">					
        <xsl:attribute name="name" select="'ruleid'"/>
      </xsl:element>
      <xsl:element name="xsl:choose">
        <xsl:for-each select="rewriteRule">
          <xsl:element name="xsl:when">			
            <xsl:attribute name="test" select="concat('$ruleid=''',../name,id,'''')"/>
            <xsl:element name="xsl:call-template">
              <xsl:attribute name="name" select="concat('test_rule_',../name,id,'_applies')"/>
            </xsl:element>
          </xsl:element>
        </xsl:for-each>
        <xsl:element name="xsl:otherwise">
          <xsl:element name="xsl:message">
						   **************** No such rule as '<xsl:element name="xsl:value-of">
              <xsl:attribute name="select" select="'$ruleid'"/>
            </xsl:element>'******************
          </xsl:element>
        </xsl:element>
      </xsl:element>
    </xsl:element>
  </xsl:template>

  <xsl:template match="*" >
    <xsl:message>Generic rule firing for <xsl:value-of select="name()"/>
    </xsl:message>
    <xsl:copy>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="rewriteRule" mode="generate_rewrite">
    <xsl:element name="xsl:template">
      <xsl:attribute name="name">
        <xsl:value-of select="concat(../name,id)"/>
      </xsl:attribute>
      <xsl:attribute name="match">
        <xsl:call-template name="newline">
          <xsl:with-param name="level" select="0"/>
        </xsl:call-template> 
        <xsl:value-of select="tt-rule/tt-conclusion/lhs/*/name()"/>  
        <xsl:text>[ some </xsl:text>
        <xsl:apply-templates select="tt-rule/tt-conclusion/lhs/*" mode="lhs"/>
        <xsl:text>$unit in ((1)) satisfies true()</xsl:text>
        <xsl:for-each select="tt-rule/tt-conclusion/lhs/*">
          <xsl:call-template name="generate_var_deep_equals_tests"/>
          <xsl:call-template name="generate_seq_deep_equals_tests"/>
        </xsl:for-each>
        <xsl:text>]</xsl:text>
      </xsl:attribute>
      <xsl:attribute name="mode" select="'rewrite'"/>
      <xsl:element name="xsl:message">
        <xsl:value-of select="../name"/>
        <xsl:value-of select="id"/>
      </xsl:element>
      <xsl:for-each select="tt-rule/tt-conclusion/lhs/*[1]">
        <xsl:apply-templates select="." mode="lhs_generate_variables"/>
      </xsl:for-each>
      <xsl:apply-templates select="tt-rule/tt-conclusion/rhs/*" mode="rhs"/>
    </xsl:element>
  </xsl:template>

<!--
  <xsl:template match="*[not(self::*:seq)]" mode="lhs">
  -->
    <xsl:template match="*[not(self::*:seq)][not(self::gat:name)]" mode="lhs">
  <xsl:if test="not(@id)">
  <xsl:message>***************************Something wrong no id atribute in element name(): <xsl:value-of select="name()"/></xsl:message>
  </xsl:if>
    <xsl:text>$</xsl:text>
    <xsl:value-of select="@id"/>
    <xsl:text> in </xsl:text>
    <xsl:value-of select="@context"/>
    <xsl:text>,</xsl:text>
    <xsl:apply-templates select="*[not(self::gat:*)]" mode="lhs"/>
  </xsl:template>

  <xsl:template match="*:seq" mode="lhs">
    <!--<xsl:message>skipping seq in lhs</xsl:message>-->
  </xsl:template>

  <xsl:template match="*[not(self::*:seq)][not(self::gat:type)]" mode="lhs_generate_variables">
    <xsl:element name="xsl:variable">
      <xsl:attribute name="name" select="@id"/>
      <xsl:attribute name="select">
        <xsl:choose>
          <xsl:when test="parent::lhs">
            <xsl:text>self::*</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="@context"/> 
            <xsl:text>[ some $</xsl:text>
            <xsl:value-of select="@id"/>
            <xsl:text> in self::*, </xsl:text>
            <xsl:apply-templates select="child::* [not(self::gat:*)] | following-sibling::* [not(self::gat:required)]" 
                            mode="lhs"/>
            <xsl:text>$unit in ((1)) satisfies true()</xsl:text>

            <xsl:call-template name="generate_var_deep_equals_tests"/>
            <xsl:call-template name="generate_seq_deep_equals_tests"/>
            <xsl:text>][1]</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
    </xsl:element>
    <xsl:apply-templates select="*[not(self::gat:*)]" mode="lhs_generate_variables"/>
	<xsl:apply-templates select= "gat:type[gat:required]" mode="lhs_generate_variables"/>
  </xsl:template>
  
  <xsl:template match="gat:type" mode="lhs_generate_variables">
    <xsl:element name="xsl:variable">
      <xsl:attribute name="name" select="@id"/>
      <xsl:attribute name="select">      
            <xsl:value-of select="@context"/> 
      </xsl:attribute>
    </xsl:element>
    <xsl:apply-templates select="*[not(self::gat:*)]" mode="lhs_generate_variables"/>
  </xsl:template>
  

  <xsl:template match="*:seq" mode="lhs_generate_variables">
  </xsl:template>

  <xsl:template match="*:var" mode="rhs">
    <xsl:element name="xsl:apply-templates">
      <xsl:attribute name="select">
        <xsl:for-each select="ancestor::rewriteRule/tt-rule/tt-conclusion/lhs/descendant-or-self::*:var[name=current()/name][1]">
         <!-- <xsl:value-of  select="@context"/>  16 Feb 2018 -->
         <xsl:value-of select="concat('$',@id)"/>
        </xsl:for-each>
      </xsl:attribute>
      <xsl:attribute name="mode" select="'rewrite'"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="*:seq" mode="rhs">
    <xsl:element name="xsl:apply-templates">
      <xsl:attribute name="select">
        <xsl:for-each select="ancestor::rewriteRule/tt-rule/tt-conclusion/lhs/descendant-or-self::*:seq[current()/name=name][1]">
          <xsl:value-of  select="@xpath"/>
        </xsl:for-each>
      </xsl:attribute>
      <xsl:attribute name="mode" select="'rewrite'"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="*" mode="rhs">
    <xsl:copy>
      <xsl:apply-templates mode="rhs"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template name="generate_var_deep_equals_tests">
    <!--<xsl:message>Entering generate_var_deep_equals_tests at a '<xsl:value-of select="name()"/>' element </xsl:message> -->
    <xsl:for-each select="(self::*|following-sibling::*)/descendant-or-self::*:var">
	  <xsl:if test="not(ancestor::gat:type)"> <!-- added when gat:type added to source in some cases 14 Feb 2018 -->
      <xsl:if test="preceding::*:var[not(ancestor::gat:type)]
	                                [(name=current()/name) and (generate-id(ancestor::lhs) = generate-id(current()/ancestor::lhs))]">
        <xsl:call-template name="newline">
          <xsl:with-param name="level" select="0"/>
        </xsl:call-template> 
        <xsl:text> and deep-equal($</xsl:text>
        <xsl:value-of select="@id"/>
        <xsl:text>, $</xsl:text>
        <xsl:for-each select="preceding::*:var[name=current()/name][1]">
          <xsl:value-of select="@id"/>
        </xsl:for-each>
        <xsl:text>)</xsl:text>               
      </xsl:if>
	  </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="generate_seq_deep_equals_tests">
    <xsl:for-each select="(self::*|following-sibling::*)/descendant-or-self::*:seq">
      <xsl:if test="preceding::*:seq [not(ancestor::gat:type)]
	                                 [(name=current()/name) and (generate-id(ancestor::lhs) = generate-id(current()/ancestor::lhs))]">
        <xsl:call-template name="newline">
          <xsl:with-param name="level" select="0"/>
        </xsl:call-template> 
        <xsl:text> and deep-equal(</xsl:text>
        <xsl:value-of select="@xpath"/>
        <xsl:text>, </xsl:text>
        <xsl:for-each select="preceding::*:seq[name=current()/name][1]">
          <xsl:value-of select="@xpath"/>
        </xsl:for-each>
        <xsl:text>)</xsl:text>               
      </xsl:if>
    </xsl:for-each>
  </xsl:template>


  <!-- ================= THE LINE =======================================-->


  <xsl:template match="rewriteRule" mode="generate_testlhsOfRule">
    <xsl:element name="xsl:template">
      <xsl:attribute name="name">
        <xsl:value-of select="concat('test_rule_',../name,id,'_applies')"/>
      </xsl:attribute>

      <xsl:element name="xsl:choose">
        <xsl:element name="xsl:when">
          <xsl:attribute name="test">
            <!-- XXX 11 April 2017 -->
            <xsl:if test="not(self::*:var)"> 
              <xsl:value-of select="tt-rule/tt-conclusion/lhs/*/name()"/>  
            </xsl:if>
            <xsl:apply-templates select="tt-rule/tt-conclusion/lhs/*" mode="lhs">
              <xsl:with-param name="level" select="0"/>
            </xsl:apply-templates>
          </xsl:attribute>
          <xsl:element name="xsl:value-of">
            <xsl:attribute name="select" select="'''PASS'''"/>
          </xsl:element>
        </xsl:element>
        <xsl:element name="xsl:otherwise">
          <xsl:element name="xsl:value-of">
            <xsl:attribute name="select" select="'''FAIL'''"/>
          </xsl:element>
        </xsl:element>
      </xsl:element>
    </xsl:element>
  </xsl:template>


</xsl:transform>
