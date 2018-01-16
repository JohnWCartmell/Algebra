<xsl:transform version="2.0" 
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xs="http://www.w3.org/2001/XMLSchema">

  <xsl:strip-space elements="*"/> 
  
  
  <xsl:include href="specialisation.module.xslt"/>

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
  
  <xsl:template match="var" mode="text">
    <xsl:value-of select="."/>
  </xsl:template>

  <xsl:template match="seq" mode="text">
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
  
  
  <xsl:template match="/" mode="tex" >
    <xsl:text>
\documentclass[10pt,a4paper]{article}
\usepackage{mathtools}
\usepackage{alltt}
\usepackage{mnsymbol}
\renewcommand{\ttdefault}{txtt}
\begin{document}
\title{ccseq Rules}
\maketitle
    </xsl:text>
    <xsl:apply-templates mode="tex"/>
      <xsl:text>
\end{document}
&#xA;
      </xsl:text>
    </xsl:template>

  <xsl:template match="*" >
        <xsl:apply-templates mode="tex"/>
  </xsl:template>
    
       
  <xsl:template match="algebra/name" mode="tex">
  </xsl:template>
    
  <xsl:template match="term" mode="tex"> 
    <xsl:apply-templates mode="tex"/>	   
  </xsl:template>

  <xsl:template match="rewriteRule|equation" mode="tex">
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
    <xsl:choose>
        <xsl:when test="self::equation">
            <xsl:text> = </xsl:text>
        </xsl:when>
        <xsl:when test="self::rewriteRule">
              <xsl:text>\Rightarrow </xsl:text>
        </xsl:when>
    </xsl:choose>
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
    
    
  <!-- A specialisation of a term is a substitutional instance -->
  
  <xsl:template match="/" mode="annotate_with_type">
    <xsl:for-each select="test/term">
      <example>
        <term>
          <xsl:apply-templates select="./*" mode="text"/>
        </term>
        <type>
            <xsl:apply-templates  mode="type">
                  <xsl:with-param name="context" select="'hom'"/>
            </xsl:apply-templates>
        </type>
      </example>
    </xsl:for-each>
  </xsl:template>
  
   <xsl:template match="/" mode="testspecialisation">
    <xsl:for-each select="test/termpair">
      <example>
        <super>
          <xsl:apply-templates select="super/*" mode="text"/>
        </super>
        <target>
          <xsl:message> target <xsl:apply-templates select="target/*" mode="text"/>
          </xsl:message>
          <xsl:apply-templates select= "target/*" mode="text"/>
        </target>
        <xsl:variable name="specialisations">
          <xsl:for-each select="super/*">
            <xsl:call-template name="specialiseTerm">
              <xsl:with-param name="targetTerm" select="../../target/*"/>
            </xsl:call-template>
          </xsl:for-each>
        </xsl:variable>
        <results>
          <xsl:variable name="super" select="super"/>
          <xsl:variable name="target" select="target"/>
          <xsl:for-each select="$specialisations/substitution">
            <xsl:variable name="substitution" select="."/>
            <xsl:message> substitution name <xsl:value-of select="$substitution/name()"/>
            </xsl:message> 
            <result>
              <xsl:copy-of select="."/>
              <specialisedTerm>
                <xsl:for-each select="$super"> 
                  <xsl:message>DOT name <xsl:value-of select="name()"/>
                  </xsl:message>
                  <xsl:message>count $substitution/* <xsl:value-of select="count($substitution/*)"/>
                  </xsl:message>
                  <xsl:apply-templates mode="substitution">
                    <xsl:with-param name="substitutions" select="$substitution"/>
                  </xsl:apply-templates>
                </xsl:for-each>
              </specialisedTerm>
              <specialisedTarget>
                <xsl:for-each select="$target/*">
                  <xsl:call-template name="applyTargetSubstitutions">
                    <xsl:with-param name="substitution" select="$substitution"/>
                  </xsl:call-template>
                </xsl:for-each>
              </specialisedTarget>
            </result>
          </xsl:for-each>
        </results>
      </example>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="*" mode="rewrite">
    <xsl:copy>
      <xsl:apply-templates mode="rewrite"/>
    </xsl:copy>
  </xsl:template>
      

  <xsl:template name="execute_specialisation" >
    <xsl:for-each select= "algebra/termSpecialisation">
      <xsl:message>specialising: <xsl:apply-templates select="upperTerm" mode="text"/> to: <xsl:apply-templates select="lowerTerm" mode="text"/>
      </xsl:message>
      <specialise>
        <upperTerm>
          <xsl:apply-templates select="upperTerm" mode="text"/>
        </upperTerm>
        <lowerTerm>
          <xsl:apply-templates select="lowerTerm" mode="text"/>
        </lowerTerm>
        <by>
          <xsl:for-each select="upperTerm/*">
            <xsl:call-template name="specialiseTerm">
              <xsl:with-param name="targetTerm" select="../../lowerTerm/*"/>
            </xsl:call-template>
          </xsl:for-each>
        </by>
      </specialise>
      <xsl:message/>
      <xsl:message/>
    </xsl:for-each>
  </xsl:template>





  <xsl:template name="execute_substitutions">
    <xsl:for-each select= "algebra/termSubstitution">
      <xsl:message>substitution in term: <xsl:apply-templates select="term" mode="text"/>
      </xsl:message>
      <xsl:copy>
        <xsl:apply-templates select="term" mode="substitution">
          <xsl:with-param name="substitutions" select="substitutions"/>
        </xsl:apply-templates>
      </xsl:copy>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="*" mode="copy">
    <xsl:copy>
      <xsl:apply-templates mode="copy"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template name="applyTargetSubstitutions">
    <xsl:param name="substitution"/>
    <xsl:variable name="targetSubstitution">
      <substitution>
        <xsl:for-each select="$substitution/targetSubstitute">
          <substitute>
            <xsl:copy-of select="*"/>
          </substitute>
        </xsl:for-each>
      </substitution>
    </xsl:variable>
    <xsl:apply-templates select="." mode="substitution">
        <xsl:with-param name="substitutions" select="$targetSubstitution/*"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="*" mode="substitution">
    <xsl:param name="substitutions"/>
    <xsl:copy>
      <xsl:apply-templates mode="substitution">
        <xsl:with-param name="substitutions" select="$substitutions"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>


  <xsl:template match="var" mode="substitution">  
    <xsl:param name="substitutions"/>
    <xsl:choose>
      <xsl:when test="some $var in $substitutions/substitute/var satisfies $var = .">
        <xsl:apply-templates select="$substitutions/substitute[var = current()/.]/term/*" 
                             mode="copy"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates mode="copy"/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="seq" mode="substitution">  
    <xsl:param name="substitutions"/>
    <xsl:message>Firing at seq count <xsl:value-of select="count($substitutions/*)"/>
    </xsl:message>

    <xsl:choose>
      <xsl:when test="some $seq in $substitutions/substitute/seq satisfies $seq = .">
        <xsl:message>Firing IN seq </xsl:message>
        <xsl:apply-templates select="$substitutions/substitute[seq = current()/.]/term/*" 
                             mode="copy"/>

      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates mode="copy"/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:transform>

