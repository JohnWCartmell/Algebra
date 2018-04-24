<xsl:transform version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:gat              ="http://www.entitymodelling.org/theory/generalisedalgebraictheory"
    xpath-default-namespace="http://www.entitymodelling.org/theory/generalisedalgebraictheory"	   
    xmlns="http://www.entitymodelling.org/theory/generalisedalgebraictheory">

  <xsl:strip-space elements="*"/> 

  <!-- gat.substitution.module.xslt-->

  <!-- mode="substitution" applies a substitution -->
  <!-- primarily a substitution is applied to a term but
       equally it can be applied to a substitution or a context
    -->

  <xsl:template match="*" mode="substitution">
    <xsl:param name="substitutions" as="element(substitution)"/>
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates  mode="substitution">
        <xsl:with-param name="substitutions" select="$substitutions"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="type_error" mode="substitution">
    <xsl:param name="substitutions" as="element(substitution)"/>
    <!-- no action -->
  </xsl:template>


  <xsl:template match="*:decl" mode="substitution">  
    <xsl:param name="substitutions" as="element(substitution)"/>
    <xsl:choose>
      <xsl:when test="some $var in $substitutions/(subject|target)/substitute/*:var satisfies $var/name = ./name">
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:copy-of select="name"/>
          <xsl:apply-templates select="type" mode="substitution">
            <xsl:with-param name="substitutions" select="$substitutions"/>
          </xsl:apply-templates>          
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="*:sequence" mode="substitution">  
    <xsl:param name="substitutions" as="element(substitution)"/>
    <xsl:choose>
      <xsl:when test="some $seq in $substitutions/(subject|target)/substitute/*:seq satisfies $seq/name = ./name">
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:copy-of select="name"/>
          <xsl:apply-templates select="type" mode="substitution">
            <xsl:with-param name="substitutions" select="$substitutions"/>
          </xsl:apply-templates>          
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="*:var" mode="substitution">  
    <xsl:param name="substitutions" as="element(substitution)"/>
    <xsl:choose>
      <xsl:when test="some $var in $substitutions/(subject|target)/substitute/*:var satisfies $var/name = ./name">
        <xsl:apply-templates select="$substitutions/(subject|target)/substitute[*:var/name = current()/name]/term/*" 
            mode="copy"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates mode="substitution">
            <xsl:with-param name="substitutions" select="$substitutions"/>
          </xsl:apply-templates> 
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template match="*:seq" mode="substitution">  
    <xsl:param name="substitutions" as="element(substitution)"/>
    <xsl:choose>
      <xsl:when test="some $seq in $substitutions/(subject|target)/substitute/*:seq satisfies $seq/name = ./name">
        <xsl:apply-templates select="$substitutions/(subject|target)/substitute[*:seq/name = current()/name]/term/*" 
            mode="copy"/>  
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates mode="substitution">
            <xsl:with-param name="substitutions" select="$substitutions"/>
          </xsl:apply-templates> 
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="substitute" mode="substitution">
    <xsl:param name="substitutions" as="element(substitution)"/>
    <xsl:if test="some $varlike in $substitutions/(subject|target)/substitute/(*:var|*:seq) satisfies  (    ($varlike/name = (*:seq|*:var)/name) 
        and 
        ($varlike/name()=(*:seq|*:var)/name())  
        )">
	  <xsl:message>OUT OF SPEC context <xsl:copy-of select="."/></xsl:message>
	  <xsl:message>OUT OF SPEC substitutions <xsl:copy-of select="$substitutions"/> </xsl:message>
      <xsl:message terminate="yes">OUT OF SPEC when applying a substitution to a substitution substitute of a var or seq </xsl:message>
    </xsl:if>
    <xsl:copy>
      <xsl:copy-of select="*:seq|*:var"/>
      <xsl:apply-templates select="term"  mode="substitution">
        <xsl:with-param name="substitutions" select="$substitutions"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>


  <!-- mode="insert_subject_substitute" -->
  <!-- used to add a subject substitute to a substitution -->
  <!-- must apply the substitution along the way -to both subject and target substitutions -->
  <xsl:template match="*" mode="insert_subject_substitute">
    <xsl:param name="substitute" as="element(substitute)"/> 
    <xsl:if test="$substitute/*:seq/name ='h1'">	   
      <xsl:message>Bingo: Inserting subject h1 
        term <xsl:apply-templates select="$substitute/term/*"/> 
        in context <xsl:value-of select="name()"/> 
      </xsl:message>
    </xsl:if>
    <xsl:copy>
      <xsl:apply-templates mode="insert_subject_substitute">
        <xsl:with-param name="substitute" select="$substitute"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="subject" mode="insert_subject_substitute">
    <xsl:param name="substitute" as="element(substitute)"/> 
    <xsl:copy>
      <xsl:variable name="subject_sub" as="element(substitution)">
        <gat:substitution>
          <subject>
            <xsl:copy-of select="$substitute"/>
          </subject>
        </gat:substitution>
      </xsl:variable>
      <xsl:apply-templates mode="substitution">
        <xsl:with-param name="substitutions" select="$subject_sub"/>
      </xsl:apply-templates>
      <xsl:copy-of select="$substitute"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="target" mode="insert_subject_substitute">
    <xsl:param name="substitute" as="element(substitute)"/> 
    <xsl:copy>
      <xsl:variable name="subject_sub" as="element(substitution)">
        <gat:substitution>
          <subject>
            <xsl:copy-of select="$substitute"/>
          </subject>
        </gat:substitution>
      </xsl:variable>
      <xsl:apply-templates mode="substitution">
        <xsl:with-param name="substitutions" select="$subject_sub"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*" mode="insert_target_substitute">
    <xsl:param name="substitute" as="element(substitute)"/>
	<xsl:if test="$substitute/substitution">
	    <xsl:message terminate="yes">Out OF SPEC - Nested substitution!</xsl:message>
	</xsl:if>
    <xsl:copy>
      <xsl:apply-templates mode="insert_target_substitute">
        <xsl:with-param name="substitute" select="$substitute"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="target" mode="insert_target_substitute">
    <xsl:param name="substitute" as="element(substitute)"/> 
    <xsl:copy>
      <xsl:variable name="target_sub" as="element(substitution)">
        <gat:substitution>
          <target>
            <xsl:copy-of select="$substitute"/>
          </target>
        </gat:substitution>
      </xsl:variable>
      <xsl:apply-templates mode="substitution">
        <xsl:with-param name="substitutions" select="$target_sub"/>
      </xsl:apply-templates>
      <xsl:copy-of select="$substitute"/>
    </xsl:copy>
  </xsl:template>


  <xsl:template match="subject" mode="insert_target_substitute">
    <xsl:param name="substitute" as="element(substitute)"/> 

    <xsl:copy>
      <xsl:variable name="target_sub" as="element(substitution)">
        <gat:substitution>
          <target>
            <xsl:copy-of select="$substitute"/>
          </target>
        </gat:substitution>
      </xsl:variable>
      <xsl:apply-templates mode="substitution">
        <xsl:with-param name="substitutions" select="$target_sub"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>


  <xsl:template match="substitution" mode="compose_substitutions">
    <xsl:param name="head_substitution" as="element(substitution)"/> <!-- changed param name to head_substitution because not symetric -->
	<!--
    <xsl:message>              Composing substitutions </xsl:message>
    <xsl:message>              dot substitution subject  <xsl:apply-templates select="./subject" mode="text"/></xsl:message>
    <xsl:message>              dot substitution target  <xsl:apply-templates select="./target" mode="text"/></xsl:message>
    <xsl:message>              head substitution subject <xsl:apply-templates select="$head_substitution/subject" mode="text"/></xsl:message>
    <xsl:message>              head substitution target <xsl:apply-templates select="$head_substitution/target" mode="text"/></xsl:message>
	-->
	<xsl:if test="$head_substitution/*/substitute/substitution">
	    <xsl:message terminate="yes">Out OF SPEC - Nested substitution!</xsl:message>
	</xsl:if>
	<xsl:if test="./*/substitute/substitution">
	    <xsl:message terminate="yes">Out OF SPEC - Nested substitution!</xsl:message>
	</xsl:if>
    <xsl:variable name="result_substitution" as="element(substitution)">
      <xsl:copy>
        <xsl:apply-templates select="$head_substitution" mode="compose_substitutionsxxxx">
          <xsl:with-param name="substitution" select="."/>
        </xsl:apply-templates>
      </xsl:copy>
    </xsl:variable>
    <xsl:message>              Result composed substitution </xsl:message>
    <xsl:message>                   subject: <xsl:apply-templates select="$result_substitution/subject" mode="text"/> </xsl:message>
    <xsl:message>                  target: <xsl:apply-templates select="$result_substitution/target" mode="text"/> </xsl:message>
    <xsl:copy-of select="$result_substitution"/>
  </xsl:template>


  <xsl:template match="subject" mode="compose_substitutionsxxxx">
    <xsl:param name="substitution" as="element(substitution)"/> 

    <xsl:copy>
      <xsl:apply-templates mode="substitution">
        <xsl:with-param name="substitutions" select="$substitution"/>
      </xsl:apply-templates>
      <xsl:copy-of select="$substitution/subject/*"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="target" mode="compose_substitutionsxxxx">
    <xsl:param name="substitution" as="element(substitution)"/> 

    <xsl:copy>
      <xsl:apply-templates mode="substitution">
        <xsl:with-param name="substitutions" select="$substitution"/>
      </xsl:apply-templates>    
      <xsl:copy-of select="$substitution/target/*"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*" mode="copy">
    <xsl:copy>
      <xsl:apply-templates mode="copy"/>
    </xsl:copy>
  </xsl:template>

</xsl:transform>

