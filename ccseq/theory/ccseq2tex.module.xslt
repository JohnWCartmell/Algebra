<!--
algebratext.module.xslt
**********************

DESCRIPTION

-->

<xsl:transform version="2.0" 
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xs="http://www.w3.org/2001/XMLSchema">


  <xsl:template match="term" mode="tex"> 
    <xsl:apply-templates mode="tex"/>	   
  </xsl:template>

  <xsl:template match="rewriteRule" mode="tex">
    <xsl:text>
\begin{equation}
    </xsl:text>
    <xsl:text>\tag{</xsl:text>
    <xsl:value-of select="id"/> 
    <xsl:text>}</xsl:text>   
    <xsl:text>&#xA;</xsl:text>
    <xsl:for-each select="lhs">
      <xsl:apply-templates mode="tex"/>
    </xsl:for-each>
    <!--
    <xsl:text>\left\{</xsl:text>
    <xsl:for-each select="lhs">
      <xsl:apply-templates mode="number"/>
    </xsl:for-each>
    <xsl:text>\right\}</xsl:text>
    -->
    <xsl:text>\Rightarrow </xsl:text>
    <xsl:for-each select="rhs">
      <xsl:apply-templates mode="tex"/>
    </xsl:for-each>
    <!--
    <xsl:text>\left\{</xsl:text>
    <xsl:for-each select="rhs">
      <xsl:apply-templates mode="number"/>
    </xsl:for-each>
    <xsl:text>\right\}</xsl:text>
    -->
    <xsl:text>
\end{equation}
    </xsl:text>
  </xsl:template>


  <xsl:template match="var" mode="tex">
    <!-- assume alpha optionally followed by digits -->

    <xsl:variable name="stem" select="replace(., '[\d]', '')"/>
    <xsl:variable name="subscript" select="replace(., '[^\d]', '')"/>
    <xsl:value-of select="concat($stem,if (string-length($subscript)=0) then '' else concat('_',$subscript))"/>
  </xsl:template>

  <xsl:template match="seq" mode="tex">
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

  <xsl:template match="p|id|a|b|c|d|e" mode="tex">
    <xsl:value-of select="name()"/>
  </xsl:template>

</xsl:transform>
