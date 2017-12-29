<!--
rules2xslt.xslt
**********************

DESCRIPTION

-->

<xsl:transform version="2.0" 
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform">


  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

  <xsl:template match="/algebra">
    <xsl:element name="xsl:transform">
      <xsl:attribute name="version" select="'2.0'"/>
      <xsl:call-template name="generate_apply_named_rule"/>
      <xsl:apply-templates select="rewriteRule" mode="generate_rewrite"/>
      <xsl:call-template name="generate_test_named_rule_applies"/>
      <xsl:apply-templates select="rewriteRule" mode="generate_testlhsOfRule"/>
    </xsl:element>
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
        <xsl:apply-templates select="lhs/*" mode="lhs"/>
      </xsl:attribute>
      <xsl:attribute name="mode" select="'rewrite'"/>
      <xsl:element name="xsl:message">
        <xsl:value-of select="../name"/>
        <xsl:value-of select="id"/>
      </xsl:element>
      <xsl:apply-templates select="rhs/*" mode="rhs"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="rewriteRule" mode="generate_testlhsOfRule">
    <xsl:element name="xsl:template">
      <xsl:attribute name="name">
        <xsl:value-of select="concat('test_rule_',../name,id,'_applies')"/>
      </xsl:attribute>

      <xsl:element name="xsl:choose">
        <xsl:element name="xsl:when">
          <xsl:attribute name="test">
            <xsl:apply-templates select="lhs/*" mode="lhs"/>
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



  <xsl:template match="*" mode="lhs">
    <xsl:if test="not(../self::lhs)">
      <xsl:text>self::</xsl:text>
    </xsl:if>
    <xsl:value-of select="name()"/>
    <xsl:if test="*[not(self::var)]">
      <xsl:text>[</xsl:text>
    </xsl:if>
    <xsl:for-each select="*[not(self::var)]"> 
      <xsl:message>At <xsl:value-of select="name()"/>
      </xsl:message>
      <xsl:if test="position()!= 1">
        <xsl:text> and </xsl:text>
      </xsl:if>
      <xsl:text>*[</xsl:text>
      <xsl:value-of select="count(preceding-sibling::*)+1"/>
      <xsl:text>]</xsl:text>
      <xsl:text>[</xsl:text>
      <xsl:apply-templates select="." mode="lhs"/>
      <xsl:text>]</xsl:text>
    </xsl:for-each>
    <xsl:if test="*[not(self::var)]">
      <xsl:text>]</xsl:text>
    </xsl:if>
    <xsl:for-each select="*/self::var">
      <xsl:if test="preceding::var[(.=current()/.) and (generate-id(ancestor::lhs) = generate-id(current()/ancestor::lhs))]">
        <xsl:text> and deep-equal(</xsl:text>
        <xsl:text>ancestor::term/</xsl:text>
        <xsl:call-template name="index"/>
        <xsl:text>,ancestor::term/</xsl:text>
        <xsl:for-each select="preceding::var[.=current()/.][1]">
          <xsl:call-template name="index"/>
        </xsl:for-each>
        <xsl:text>)</xsl:text>               
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="var" mode="lhs">
    <xsl:for-each select="preceding::var[.=current()/.][1]">
      <duplicateOf>
        <xsl:call-template name="index"/>
      </duplicateOf>
    </xsl:for-each>
  </xsl:template>


  <xsl:template match="var" mode="rhs">
    <!--
        <xsl:copy>
            <xsl:apply-templates mode="rhs"/>
            <index>
                <xsl:call-template name="index"/>
            </index>
            <varno><xsl:value-of select="count(preceding::var)"/></varno>
            <xsl:if test="exists(preceding::var[.=current()/.])">
                <duplicateOf>
                    <xsl:for-each select="preceding::var[.=current()/.][1]">
                        <xsl:call-template name="index"/>
                    </xsl:for-each>
                </duplicateOf>
    -->
    <xsl:element name="xsl:apply-templates">
      <xsl:attribute name="select">
        <xsl:for-each select="ancestor::rewriteRule/lhs/descendant-or-self::var[.=current()/.][1]">
          <xsl:call-template name="selectindex"/>
        </xsl:for-each>
      </xsl:attribute>
      <xsl:attribute name="mode" select="'rewrite'"/>
    </xsl:element>
    <!--
            </xsl:if>
        </xsl:copy>
    -->
  </xsl:template>

  <xsl:template match="*" mode="rhs">
    <xsl:copy>
      <xsl:apply-templates mode="rhs"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template name="index">
    <xsl:if test="not(parent::lhs | parent::rhs)">
      <xsl:for-each select="..">
        <xsl:call-template name="index"/>
      </xsl:for-each>
      <xsl:text>/</xsl:text>
    </xsl:if>
    <xsl:text>*[</xsl:text>
    <xsl:value-of select="count(preceding-sibling::*) + 1"/>
    <xsl:text>]</xsl:text>
  </xsl:template>

  <xsl:template name="selectindex">
    <xsl:if test="not(../parent::lhs)">
      <xsl:for-each select="..">
        <xsl:call-template name="selectindex"/>
      </xsl:for-each>
      <xsl:text>/</xsl:text>
    </xsl:if>
    <xsl:text>*[</xsl:text>
    <xsl:value-of select="count(preceding-sibling::*) + 1"/>
    <xsl:text>]</xsl:text>
  </xsl:template>


</xsl:transform>
