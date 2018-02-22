<xsl:transform version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:gat              ="http://www.entitymodelling.org/theory/generalisedalgebraictheory"
    xpath-default-namespace="http://www.entitymodelling.org/theory/generalisedalgebraictheory"	   
    xmlns="http://www.entitymodelling.org/theory/generalisedalgebraictheory"
    exclude-result-prefixes="xs">

  <xsl:strip-space elements="*"/> 



  <xsl:template match="*" mode="normalise">
    <!--  <xsl:message>copying <xsl:value-of select="name()"/> </xsl:message>-->
    <xsl:copy>
      <xsl:copy-of select="namespace::*"/>
      <xsl:apply-templates mode="normalise"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="term" mode="normalise">
    <xsl:message> Normalising <xsl:value-of select="name()"/> . <xsl:value-of select="*/name()"/></xsl:message>
    <xsl:copy>
      <xsl:call-template name="recursive_rewrite">
        <xsl:with-param name="document">
          <xsl:apply-templates select="*" mode="rewrite"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:copy>
  </xsl:template>

  <xsl:template match = "/" mode="prepare_diamonds">
    <xsl:apply-templates mode="prepare_diamonds"/>
  </xsl:template>

  <xsl:template match="algebra" mode="prepare_diamonds">
    <xsl:copy>
      <xsl:copy-of select="namespace::*"/>
      <xsl:variable name="algebra_name" select="name"/>
      <xsl:for-each select="rewriteRule"> 
        <xsl:variable name="inner_rule_id" select="concat($algebra_name,id)"/>
        <xsl:message>Inner rule <xsl:value-of select="$inner_rule_id"/> </xsl:message>  
        <xsl:variable name="innerRuleWithVblsChanged">
          <xsl:apply-templates select="." mode="postfix_variable_names"/>
        </xsl:variable>
        <xsl:variable name="innerTerm" as="node()" select="$innerRuleWithVblsChanged/rewriteRule/tt-conclusion/lhs/*"/>       
        <xsl:variable name="innerTermPurified" as="node()">
          <xsl:apply-templates select="$innerTerm" mode="remove_gat_annotations"/>
        </xsl:variable>
        <xsl:variable name="innerContext" as="node()" select="$innerRuleWithVblsChanged/rewriteRule/context"/>

        <xsl:for-each select="../rewriteRule/tt-conclusion/lhs/*">  <!-- consider each possible outer rewrite rule -->
          <xsl:variable name="lhs" as="node()" select=".."/>
          <xsl:variable name="outerContext" as="node()" select="../../../context"/>
          <xsl:variable name="outer_rule_id" select="concat($algebra_name,../../../id)"/>
          <xsl:variable name="outerTerm" as="node()" select="."/>
          <xsl:variable name="outerTermPurified" as="node()">
            <xsl:apply-templates select="$outerTerm" mode="remove_gat_annotations"/>
          </xsl:variable>
          <xsl:variable name="results">
            <xsl:apply-templates select="$outerTermPurified" mode="get_instances_of">
              <xsl:with-param name="targetTerm" select="$innerTermPurified"/>
            </xsl:apply-templates>
          </xsl:variable>
          <xsl:if test="count($results/*) != 0">
            <xsl:for-each select="$results/result">
              <xsl:variable as="node()" name="targetSubstitution">
                <substitution>
                  <xsl:for-each select="substitution/targetSubstitute">
                    <substitute>
                      <xsl:copy-of select="*"/>
                    </substitute>
                  </xsl:for-each>
                </substitution>
              </xsl:variable>
              <xsl:variable name="result" as="node()" select="."/>
              <xsl:variable name="innerContextSubstituted" as="node()">
                <xsl:for-each select="$innerContext">       <!-- SIMPLIFY -->
                  <xsl:apply-templates select="." mode="substitution">
                    <xsl:with-param name="substitutions" select="$targetSubstitution"/>
                  </xsl:apply-templates>
                </xsl:for-each>
              </xsl:variable>             
              <xsl:variable name="outerContextSubstituted" as="node()">
                <xsl:for-each select="$outerContext">
                  <xsl:apply-templates select="." mode="substitution">
                    <xsl:with-param name="substitutions" select="$result/substitution"/>
                  </xsl:apply-templates>
                </xsl:for-each>
              </xsl:variable>
              <xsl:variable name="innerTermSpecialised">
                <xsl:apply-templates select="$innerTerm" mode="substitution">  <!--,EXTRA NAV ? -->
                  <xsl:with-param name="substitutions" select="$targetSubstitution"/> 
                </xsl:apply-templates>
              </xsl:variable>
              <xsl:variable name="innerTermSpecialisedText">
                <xsl:apply-templates select="$innerTermSpecialised" mode="text"/>
              </xsl:variable>
              <xsl:variable name="outerTermSpecialised">
                <xsl:apply-templates select="$outerTerm" mode="substitution">  <!--,EXTRA NAV ? -->
                  <xsl:with-param name="substitutions" select="$result/substitution"/> 
                </xsl:apply-templates>
              </xsl:variable>
              <xsl:variable name="outerTermSpecialisedText">
                <xsl:apply-templates select="$outerTermSpecialised" mode="text"/>
              </xsl:variable>
              <xsl:message> $result/point_id <xsl:value-of select="$result/point_id"/> </xsl:message>
              <xsl:variable name="outerTerm_as_pointed_term">
                <xsl:apply-templates select="$outerTermPurified" mode="insert_point">
                  <xsl:with-param name="point_id" select="$result/point_id" />
                </xsl:apply-templates>
              </xsl:variable>
              <xsl:message>outerTerm_as_pointed_term <xsl:copy-of select="$outerTerm_as_pointed_term"/>
              </xsl:message>
              <xsl:variable name="pointed_outerTerm_specialised" as="node()">
                <xsl:apply-templates select="$outerTerm_as_pointed_term" mode="substitution">
                  <xsl:with-param name="substitutions" select="$result/substitution"/>
                </xsl:apply-templates>
              </xsl:variable>
              <xsl:variable name="innerSubtermOfOuterTermSpecialised" as="node()">
                <xsl:apply-templates select="$pointed_outerTerm_specialised" mode="extract_subterm_at_point"/>
              </xsl:variable>  
              <xsl:variable name="innerSubtermOfOuterTermSpecialised_text">
                <xsl:apply-templates select="$innerSubtermOfOuterTermSpecialised" mode="text"/>
              </xsl:variable>              
              <gat:diamond xmlns="http://www.entitymodelling.org/theory/contextualcategory/sequence">
                <from>
                  <outer>
                    <id><xsl:value-of select="$outer_rule_id"/></id>
                    <term><xsl:apply-templates select="$outerTerm" mode="text"/></term>
                    <context>
                      <!-- <xsl:copy-of select="$outerContext"/> -->
                      <xsl:apply-templates select="$outerContext" mode="text"/>
                    </context>
                    <substitution> 
                      <xsl:apply-templates  select="substitution/substitute" mode="text"/>
                    </substitution>
                    <contextsubstituted>
                      <!--<xsl:copy-of select="$outerContextSubstituted"/>-->  <!-- MAKE INTO FIRST PASS XML. SECOND PASS TEXT OR EVEN tex -->
                      <xsl:apply-templates select="$outerContextSubstituted" mode="text"/>  
                    </contextsubstituted>
                    <term_specialised>
                      <!--<xsl:copy-of select="$outerTermSpecialised"/>-->
                      <xsl:apply-templates select="$outerTermSpecialised" mode="text"/>
                    </term_specialised>
                    <pointed_term_specialised>
                      <!--<xsl:copy-of select="$pointed_outerTerm_specialised"/>-->
                      <xsl:apply-templates select="$pointed_outerTerm_specialised" mode="text"/>
                    </pointed_term_specialised>
                    <point_subterm>
                         <xsl:value-of select="$innerSubtermOfOuterTermSpecialised_text"/>
                    </point_subterm>
                  </outer>
                  <inner>
                    <id><xsl:value-of select="$inner_rule_id"/></id>
                    <term><xsl:apply-templates select="$innerTerm" mode="text"/></term>                   
                    <context>
                      <!-- <xsl:copy-of select="$innerContext"/> -->
                      <xsl:apply-templates select="$innerContext" mode="text"/>
                    </context>
                    <substitution>
                      <xsl:apply-templates  select="substitution/targetSubstitute" mode="text"/>
                    </substitution>
                    <contextsubstituted>
                      <!--<xsl:copy-of select="$innerContextSubstituted"/>-->
                      <xsl:apply-templates select="$innerContextSubstituted" mode="text"/>
                    </contextsubstituted>
                    <term_specialised>
                      <!--<xsl:copy-of select="$innerTermSpecialised"/>-->
                      <xsl:apply-templates select="$innerTermSpecialised" mode="text"/>
                    </term_specialised>
                  </inner>
                  <number><xsl:value-of select="position()"/></number>
                  <xsl:if test="not($innerTermSpecialisedText = $innerSubtermOfOuterTermSpecialised_text)">
                    <ERROR> OUT OF SPEC </ERROR>
                    <xsl:copy-of select="$result"/>
                  </xsl:if>              
                </from>
                <context>
                  <xsl:value-of select="context"/> <!-- THIS IS TWO PART CONTEXTS PUT TOGETHER AND, MAYBE, SORTED. -->
                </context>

                <!--COPY the ancestor term with the result substitutions and mark application_node_id -->
                <top_of_diamond>
                  <!--<xsl:copy-of select="$pointed_outerTerm_specialised"/>-->
                  <xsl:apply-templates select="$pointed_outerTerm_specialised" mode="text"/>
                </top_of_diamond>
                <xsl:message> Top of diamond <xsl:copy-of select="$pointed_outerTerm_specialised"/>
                </xsl:message>
                <xsl:if test="false()" >
                  <!--outerTerm-->
                  <xsl:variable name="left_reduction">
                    <term>
                      <xsl:for-each select="lhs_specialised/*">
                        <xsl:call-template name="apply_named_rule">
                          <xsl:with-param name="ruleid" select="$outer_rule_id"/>
                        </xsl:call-template> 
                      </xsl:for-each>
                    </term>
                  </xsl:variable>
                  <leftreduction>
                    <xsl:apply-templates select="$left_reduction" mode="text"/>
                  </leftreduction>
                  <!-- inner Term -->
                  <xsl:variable name="right_reduction">
                    <term>
                      <xsl:for-each select="pointed_lhs_specialised">
                        <xsl:message>Inner rule is <xsl:value-of select="$inner_rule_id"/>
                        </xsl:message>
                        <xsl:apply-templates mode="innerReduction">
                          <xsl:with-param name="rule_id" select="$inner_rule_id"/>
                        </xsl:apply-templates> 
                      </xsl:for-each>
                    </term>
                  </xsl:variable>
                  <rightreduction>
                    <xsl:apply-templates select="$right_reduction" mode="text"/>
                  </rightreduction>
                  <!-- Normalise left hand side -->
                  <xsl:variable name="leftReductionNormalised">
                    <xsl:call-template name="recursive_rewrite">
                      <xsl:with-param name="document">
                        <xsl:apply-templates select="$left_reduction" mode="rewrite"/>
                      </xsl:with-param>
                    </xsl:call-template>
                  </xsl:variable>
                  <xsl:variable name="leftReductionNormalisedText">
                    <xsl:apply-templates select="$leftReductionNormalised" mode="text"/>
                  </xsl:variable>
                  <xsl:variable name="lhscost" as="xs:double">
                    <xsl:apply-templates select="$leftReductionNormalised" mode="number"/>
                  </xsl:variable>
                  <!-- Normailise right hand side -->
                  <xsl:message>normalise rhs reduction</xsl:message>
                  <xsl:variable name="rightReductionNormalised">
                    <xsl:call-template name="recursive_rewrite">
                      <xsl:with-param name="document">
                        <xsl:apply-templates select="$right_reduction" mode="rewrite"/>
                      </xsl:with-param>
                    </xsl:call-template>
                  </xsl:variable>
                  <xsl:variable name="rightReductionNormalisedText">
                    <xsl:apply-templates select="$rightReductionNormalised" mode="text"/>
                  </xsl:variable>
                  <xsl:variable name="rhscost" as="xs:double">
                    <xsl:apply-templates select="$rightReductionNormalised" mode="number"/>
                  </xsl:variable>
                  <!-- OUTPUT -->
                  <leftReductionNormalised>
                    <xsl:if test="not($leftReductionNormalisedText=$rightReductionNormalisedText)">
                      <xsl:copy-of select="$leftReductionNormalised"/>
                    </xsl:if>
                    <gat:text>
                      <xsl:value-of select="$leftReductionNormalisedText"/>
                      <xsl:text>{</xsl:text>
                      <xsl:value-of select="$lhscost"/>
                      <xsl:text>}</xsl:text>
                    </gat:text>
                  </leftReductionNormalised>
                  <rightReductionNormalised>
                    <xsl:if test="not($leftReductionNormalisedText = $rightReductionNormalisedText)">
                      <xsl:copy-of select="$rightReductionNormalised"/>
                    </xsl:if>                    
                    <gat:text>
                      <xsl:value-of select="$rightReductionNormalisedText"/>
                      <xsl:text>{</xsl:text>
                      <xsl:value-of select="$rhscost"/>
                      <xsl:text>}</xsl:text>
                    </gat:text>
                  </rightReductionNormalised>
                  <xsl:if test="not($leftReductionNormalisedText=$rightReductionNormalisedText)">
                    <NON-CONFLUENT/>
                    <xsl:if test="$lhscost=$rhscost">
                      <STALEMATE/>
                    </xsl:if>
                    <xsl:if test="$lhscost &lt; $rhscost">
                      <RIGHT-TO-LEFT/>
                    </xsl:if>
                    <xsl:if test="$rhscost &lt; $lhscost">
                      <LEFT-TO-RIGHT/>
                    </xsl:if>
                    <xsl:message>*************  NON CONFLUENT ************</xsl:message>
                  </xsl:if>
                </xsl:if>
              </gat:diamond>
            </xsl:for-each> <!-- end outer term -->
          </xsl:if>
        </xsl:for-each> <!-- end inner term -->
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*" mode="remove_gat_annotations">
    <!-- need to keeep gat:name however -->
    <xsl:copy>
      <xsl:copy-of select="gat:name"/> <!-- only applicable to var's and seq's -->
      <xsl:apply-templates select="*[not(self::gat:*)]" mode="remove_gat_annotations"/>
    </xsl:copy>
  </xsl:template>


  <xsl:template match="*" mode="postfix_variable_names">
    <xsl:copy>
      <xsl:apply-templates mode="postfix_variable_names"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*:var|*:seq|gat:sequence|gat:decl" mode="postfix_variable_names">
    <xsl:copy>
      <gat:name><xsl:value-of select="gat:name"/>'</gat:name>
      <xsl:apply-templates select="*[not(self::gat:name)]" mode="postfix_variable_names"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="point" mode="innerReduction">
    <xsl:param name="rule_id"/>
    <xsl:message> innerReduction using rule <xsl:value-of select="$rule_id"/>
    </xsl:message>
    <xsl:for-each select="*[1]">
      <xsl:call-template name="apply_named_rule">
        <xsl:with-param name="ruleid" select="$rule_id"/>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="*" mode="innerReduction">
    <xsl:param name="rule_id"/>
    <xsl:copy>
      <xsl:apply-templates mode="innerReduction">
        <xsl:with-param name="rule_id" select="$rule_id"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*:var" mode="innerReduction">
    <xsl:param name="rule_id"/>
    <xsl:copy>
      <xsl:apply-templates mode="copy"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*" mode="rewrite">
    <xsl:copy>
      <xsl:apply-templates mode="rewrite"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template name="recursive_rewrite">
    <xsl:param name="document"/>
    <xsl:message>
      entering recursive_rewrite <xsl:apply-templates select ="$document" mode="text"/>
    </xsl:message>
    <xsl:variable name ="next">
      <xsl:for-each select="$document">
        <xsl:apply-templates select="." mode="rewrite"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="not(deep-equal($document,$next))">
        <xsl:message>rewritten</xsl:message>
        <xsl:call-template name="recursive_rewrite">
          <xsl:with-param name="document" select="$next"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>no further rewrites found 
          <xsl:apply-templates select ="$document" mode="text"/>
        </xsl:message>
        <xsl:copy-of select="$document"/>					
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <!-- "get_instances_of" is an abbreviation of 
       "get all matching subtitutional instances of this and its a proper subterms"
       This template returns zero or more <result> elements.
       Each <result> contains  a pointed version of the given term <pointed_lhs_specialised>
       and a substititution <substitutions> which when applied at the subterm at the point yields a match 
       to the target term.       
       Modified 19 Feb 2018. 
           Now is invoked within context of a rewrite rule to which we wish to find
              all matching subtitutional instances of its lhs term and its a proper subterms.
           Now is passed a targetRule whose lhs is the target term.
  -->
  <xsl:template match="*" mode="get_instances_of">
    <xsl:param name="targetTerm"/>
    <!-- First look for specialisations (i.e. substuituitional instances) of the current term -->
    <xsl:variable name="substitutions">
      <xsl:call-template name="specialiseTerm">
        <xsl:with-param name="targetTerm" select="$targetTerm"/>
      </xsl:call-template>
    </xsl:variable> 
    <xsl:variable name="point_id" select="generate-id()"/>
    <!--
    <xsl:variable name="ancestor_lhs" select="ancestor-or-self::lhs/*[1]"/>
    -->
    <!-- If found then add to the output stream -->
    <xsl:for-each select="$substitutions/substitution">
      <xsl:message> AT HERE </xsl:message>
      <xsl:if test="not(self::INCOMPATIBLE)">
        <result>
          <xsl:copy-of select="."/>
          <point_id>
            <xsl:value-of select="$point_id"/>
          </point_id>
        </result>
      </xsl:if>
    </xsl:for-each>
    <!-- Next do the same for all subterms (recursively) -->
    <xsl:apply-templates select="*[not(gat:*)]" mode="get_instances_of">
      <xsl:with-param name="targetTerm" select="$targetTerm"/>
    </xsl:apply-templates>
  </xsl:template>  

  <xsl:template match="*" mode="insert_point">
    <xsl:param name="point_id"/>
    <xsl:choose>
      <xsl:when test="generate-id()=$point_id">
        <xsl:message>INSERTING point in node name() <xsl:value-of select="name()"/></xsl:message>
        <point>
          <xsl:copy-of select="."/>
        </point>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates mode="insert_point">
            <xsl:with-param name="point_id" select="$point_id"/>
          </xsl:apply-templates>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="*" mode="extract_subterm_at_point">
    <xsl:apply-templates select="*[not(self::*:var|self::*:seq)]" mode="extract_subterm_at_point"/>
  </xsl:template>
  
   <xsl:template match="point" mode="extract_subterm_at_point">
    <xsl:copy-of select="*"/>
  </xsl:template>


  <xsl:template match="point" mode="remove_point">
    <xsl:apply-templates mode="copy"/>
  </xsl:template>

  <xsl:template match="*:var|*:seq" mode="get_instances_of">
    <!-- don't want a result from a variable or sequence matching whole lhs term-->
  </xsl:template>     


</xsl:transform>

