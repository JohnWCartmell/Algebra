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
    <xsl:param name="substitutions" as="element()"/>
    <xsl:message>substituting recursively</xsl:message>
    <xsl:copy>
      <xsl:apply-templates mode="substitution">
        <xsl:with-param name="substitutions" select="$substitutions"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*:decl" mode="substitution">  
    <xsl:param name="substitutions" as="element()"/>
    <xsl:choose>
      <xsl:when test="some $var in $substitutions/substitute/*:var satisfies $var/name = ./name">
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates mode="copy"/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="*:sequence" mode="substitution">  
    <xsl:param name="substitutions" as="element()"/>
    <xsl:choose>
      <xsl:when test="some $seq in $substitutions/substitute/*:seq satisfies $seq/name = ./name">
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates mode="copy"/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="*:var" mode="substitution">  
    <xsl:param name="substitutions" as="element()"/>
    <xsl:choose>
      <xsl:when test="some $var in $substitutions/substitute/*:var satisfies $var/name = ./name">
        <xsl:apply-templates select="$substitutions/substitute[*:var/name = current()/name]/term/*" 
            mode="copy"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates mode="copy"/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
  <xsl:template match="substitute/*:var" mode="substitution">
    <xsl:param name="substitutions"/>
    <xsl:message>substituting into substitute/*:var</xsl:message>
    <xsl:if test="some $var in $substitutions/substitute/*:var satisfies $var/name = ./name">
      <xsl:message terminate="yes">OUT OF SPEC when applying a substitution to a substitution substitute of a var </xsl:message>
    </xsl:if>
    <xsl:copy>
      <xsl:apply-templates mode="substitution">
        <xsl:with-param name="substitutions" select="$substitutions"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>
  -->

  <xsl:template match="*:seq" mode="substitution">  
    <xsl:param name="substitutions" as="element()"/>
    <xsl:message>substituting into *:seq</xsl:message>
    <xsl:choose>
      <xsl:when test="some $seq in $substitutions/substitute/*:seq satisfies $seq/name = ./name">
        <xsl:apply-templates select="$substitutions/substitute[*:seq/name = current()/name]/term/*" 
            mode="copy"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates mode="copy"/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="substitute" mode="substitution">
    <xsl:param name="substitutions" as="element()"/>
    <xsl:message>substituting <xsl:value-of select="$substitutions/name()"/> <xsl:apply-templates select="$substitutions" mode="text"/>
    into substitute of <xsl:value-of select="(*:seq|*:var)/name()"/> <xsl:value-of select="(*:seq|*:var)/name"/> 
    which is <xsl:apply-templates select="." mode="text"/></xsl:message>
    
    <xsl:if test="some $varlike in $substitutions/substitute/(*:var|*:seq) satisfies  (    ($varlike/name = (*:seq|*:var)/name) 
                                                                                       and 
                                                                                           ($varlike/name()=(*:seq|*:var)/name())  
                                                                                       )">
      <xsl:message><xsl:value-of select="$substitutions/substitute/*:seq [name = current()/(*:seq|*:var)/name]/name"/></xsl:message>
      <xsl:message >OUTxxx OF SPEC when applying a substitution to a substitution substitute of a seq </xsl:message>
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
    <xsl:message> Inserting - subject sub recursively</xsl:message>
    <xsl:copy>
      <xsl:apply-templates mode="insert_subject_substitute">
        <xsl:with-param name="substitute" select="$substitute"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="subject" mode="insert_subject_substitute">
    <xsl:param name="substitute" as="element(substitute)"/> 
    <xsl:message> Inserting - subject sub into subject</xsl:message>
    <xsl:copy>
      <!-- was
    <xsl:apply-templates mode="insert_subject_substitute">
      <xsl:with-param name="seq" select="$seq"/>
      <xsl:with-param name="terms" select="$terms"/>
    </xsl:apply-templates>
    now-->
      <xsl:variable name="subject_sub" as="element(subject)">
        <subject>
          <xsl:copy-of select="$substitute"/>
        </subject>
      </xsl:variable>
      <xsl:apply-templates mode="substitution">
        <xsl:with-param name="substitutions" select="$subject_sub"/>
      </xsl:apply-templates>
      <xsl:copy-of select="$substitute"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="target" mode="insert_subject_substitute">
    <xsl:param name="substitute" as="element(substitute)"/> 
    <xsl:message> Inserting - subject sub into target</xsl:message>
    <xsl:copy>
      <xsl:variable name="subject_sub" as="element(subject)">
        <subject>
          <xsl:copy-of select="$substitute"/>
        </subject>
      </xsl:variable>
      <xsl:apply-templates mode="substitution">
        <xsl:with-param name="substitutions" select="$subject_sub"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*" mode="insert_target_substitute">
    <xsl:param name="substitute" as="element(substitute)"/> 
    <xsl:message> Inserting - target sub recursively</xsl:message>
    <xsl:copy>
      <xsl:apply-templates mode="insert_target_substitute">
        <xsl:with-param name="substitute" select="$substitute"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="target" mode="insert_target_substitute">
    <xsl:param name="substitute" as="element(substitute)"/> 
    <xsl:message> Inserting - target sub into target</xsl:message>
    <xsl:copy>
      <!-- was
    <xsl:apply-templates mode="insert_target_substitute">
      <xsl:with-param name="seq" select="$seq"/>
      <xsl:with-param name="terms" select="$terms"/>
    </xsl:apply-templates>
    but now is -->
      <xsl:variable name="target_sub" as="element(target)">
        <target>
          <xsl:copy-of select="$substitute"/>
        </target>
      </xsl:variable>
      <xsl:apply-templates mode="substitution">
        <xsl:with-param name="substitutions" select="$target_sub"/>
      </xsl:apply-templates>
      <xsl:copy-of select="$substitute"/>
    </xsl:copy>
  </xsl:template>


  <xsl:template match="subject" mode="insert_target_substitute">
    <xsl:param name="substitute" as="element(substitute)"/> 
    <xsl:message> Inserting - target sub into subject</xsl:message>
    <xsl:copy>
      <xsl:variable name="target_sub" as="element(target)">
        <target>
          <xsl:copy-of select="$substitute"/>
        </target>
      </xsl:variable>
      <xsl:apply-templates mode="substitution">
        <xsl:with-param name="substitutions" select="$target_sub"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>


  <xsl:template match="substitution" mode="compose_substitutions">
    <xsl:param name="head_substitution" as="element(substitution)"/> <!-- changed param name to head_substitution because not symetric -->
    <xsl:message> Composing substitutions</xsl:message>
    <xsl:copy>
    <!-- was
      <xsl:apply-templates mode="compose_substitutions">
        <xsl:with-param name="substitution" select="$substitution"/>
      </xsl:apply-templates>
      now is -->
      <xsl:apply-templates select="$head_substitution" mode="compose_substitutionsxxxx">
        <xsl:with-param name="substitution" select="."/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="subject" mode="compose_substitutionsxxxx">
    <xsl:param name="substitution" as="element(substitution)"/> 
    <xsl:message> Composing substitution subjects</xsl:message>
    <xsl:message>  subject substitutes is <xsl:apply-templates select="." mode="text"/></xsl:message>
    <xsl:message>  substitution is <xsl:apply-templates select="$substitution/*" mode="text"/></xsl:message>
    <xsl:copy>
      <!-- was
      <xsl:apply-templates mode="copy"/>
      is now -->
      <xsl:variable name="all_substitutes" as="element(any)">
        <any>
          <xsl:copy-of select="$substitution/(subject|target)/*"/>
        </any>
      </xsl:variable>
      <xsl:apply-templates mode="substitution">
        <xsl:with-param name="substitutions" select="$all_substitutes"/>
      </xsl:apply-templates>
      <xsl:copy-of select="$substitution/subject/*"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="target" mode="compose_substitutionsxxxx">
    <xsl:param name="substitution" as="element(substitution)"/> 
    <xsl:message> Composing substitution targets</xsl:message>
    <xsl:copy>
    <!-- was 
      <xsl:apply-templates mode="copy"/>
            is now -->
      <xsl:variable name="all_substitutes" as="element(any)">
        <any>
          <xsl:copy-of select="$substitution/(subject|target)/*"/>
        </any>
      </xsl:variable>
      <xsl:apply-templates mode="substitution">
        <xsl:with-param name="substitutions" select="$all_substitutes"/>
      </xsl:apply-templates>    
      <xsl:copy-of select="$substitution/target/*"/>
    </xsl:copy>
  </xsl:template>


  <xsl:template match="*" mode="copy">
    <xsl:copy>
      <xsl:apply-templates mode="copy"/>
    </xsl:copy>
  </xsl:template>
  <!-- end substitutions -->


</xsl:transform>

