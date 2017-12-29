<xsl:transform version="2.0" 
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xs="http://www.w3.org/2001/XMLSchema">

  <xsl:template match="s" mode="type">
    <xsl:param name="absolute"/>
    <xsl:param name="context"/>
    <xsl:message> s context: <xsl:value-of select="$context"/>
    </xsl:message>
    <xsl:choose>
      <xsl:when test="count(child::*)=1">
        <xsl:variable name="argtype">
          <xsl:apply-templates mode="type">
            <xsl:with-param name="absolute" select="$absolute"/>
            <xsl:with-param name="context" select="'hom'"/>
          </xsl:apply-templates>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$argtype/*[self::hom]">
            <hom>
              <xsl:copy-of select="$argtype/*/child::*[1]"/>
              <star>
                <o>
                  <xsl:copy-of select="child::*"/>
                  <p/>
                </o>
                <xsl:copy-of select="$argtype/*/child::*[2]"/>
              </star>
            </hom>
          </xsl:when>
          <xsl:otherwise>
            <xsl:message>S applied to argument that is not a morphism </xsl:message>
            <error>S applied to argument that is not a morphism</error>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>S requires one argument but given 
          <xsl:value-of select="count(child::*)"/>
        </xsl:message>
        <error>S requires one argument but given 
          <xsl:value-of select="count(child::*)"/>
        </error>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="o" mode="type">
    <xsl:param name="absolute"/>
    <xsl:param name="context"/>
    <xsl:choose>
      <xsl:when test="count(child::*)=0">
        <hom>
          <var>
            <xsl:value-of select="concat('x',generate-id())"/>
          </var>
          <var>
            <xsl:value-of select="concat('x',generate-id())"/>
          </var>
        </hom>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="argtype1">
          <xsl:apply-templates mode="type" select="child::*[1]">
            <xsl:with-param name="absolute" select="$absolute"/>
            <xsl:with-param name="context" select="'hom'"/>
          </xsl:apply-templates>
        </xsl:variable>
        <xsl:variable name="argtype2">
          <xsl:apply-templates mode="type" select="child::*[last()]">
            <xsl:with-param name="absolute" select="$absolute"/>
            <xsl:with-param name="context" select="'hom'"/>
          </xsl:apply-templates>
        </xsl:variable>
        <hom>
          <xsl:copy-of select="$argtype1/*/child::*[1]"/>
          <xsl:copy-of select="$argtype2/*/child::*[2]"/>
        </hom>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="q" mode="type">
    <xsl:param name="absolute"/>
    <xsl:param name="context"/>
    <xsl:choose>
      <xsl:when test="count(child::*)=2">
        <xsl:variable name="argtype1">
          <xsl:apply-templates mode="type" select="child::*[1]">
            <xsl:with-param name="absolute" select="$absolute"/>
            <xsl:with-param name="context" select="'hom'"/>
          </xsl:apply-templates>
        </xsl:variable>
        <hom>
          <star>
            <xsl:copy-of select="$argtype1/*/child::*[1]"/>
            <xsl:copy-of select="child::*[2]"/>
          </star>
          <xsl:copy-of select="child::*[2]"/>
        </hom>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>q requires two arguments but given 
          <xsl:value-of select="count(child::*)"/>
        </xsl:message>
        <error>q requires two arguments but given 
          <xsl:value-of select="count(child::*)"/>
        </error>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="var|seq" mode="type">
    <xsl:param name="absolute"/>
    <xsl:param name="context"/>
    <xsl:choose>
      <xsl:when test="$context='ob'">
        <ob/>
      </xsl:when>
      <xsl:when test="$context='hom'">
        <xsl:for-each select="$absolute/(descendant-or-self::seq|descendant-or-self::var)[.=current()/.][1]">
        <hom>
          <var>
            <xsl:value-of select="concat('x',generate-id())"/>
          </var>
          <var>
            <xsl:value-of select="concat('y',generate-id())"/>
          </var>
        </hom>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>invalid context: <xsl:value-of select="$context"/>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="star" mode="type">
    <xsl:param name="absolute"/>
    <xsl:param name="context"/>
    <ob/>
  </xsl:template>

  <xsl:template match="p" mode="type">
    <xsl:param name="absolute"/>
    <xsl:param name="context"/>
    <!-- something strange here because cannot enforce constraint that 2nd arg parent of first -->
    <!-- neeed remainder of variables for ob - AND THEN seq(ob) !!! -->
    <hom>
      <var>
        <xsl:value-of select="concat('x',generate-id())"/>
      </var>
      <var>
        <xsl:value-of select="concat('y',generate-id())"/>
      </var>
    </hom>
  </xsl:template>

</xsl:transform>
