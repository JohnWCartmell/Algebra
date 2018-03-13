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
    <xsl:message> Normalising <xsl:apply-templates select="." mode="text"/></xsl:message>
    <xsl:copy>
      <xsl:call-template name="recursive_rewrite">
        <xsl:with-param name="document" select="*"/> <!-- 6th March 2018 -->
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
      <xsl:for-each select="rewriteRule/tt-rule"> 
        <xsl:variable name="inner_rule_id" select="concat($algebra_name,../id)"/>
        <xsl:message>Inner rule <xsl:value-of select="$inner_rule_id"/> </xsl:message>  
        <xsl:variable name="innerRuleWithVblsChanged" as="element(tt-rule)">
          <xsl:apply-templates select="." mode="postfix_variable_names"/>
        </xsl:variable>
        <xsl:variable name="innerTerm" as="element()" select="$innerRuleWithVblsChanged/tt-conclusion/lhs/*"/>       
        <xsl:variable name="innerTermPurified" as="element()">
          <xsl:apply-templates select="$innerTerm" mode="remove_gat_annotations"/>
        </xsl:variable>
        <xsl:variable name="innerContext" as="element(context)" select="$innerRuleWithVblsChanged/context"/>

        <xsl:for-each select="//rewriteRule/tt-rule/tt-conclusion/lhs/*">  <!-- consider each possible outer rewrite rule -->
          <xsl:variable name="lhs" as="element(lhs)" select=".."/>
          <xsl:variable name="outerContext" as="element(context)" select="../../../context"/>
          <xsl:variable name="outer_rule_id" select="concat($algebra_name,../../../../id)"/>
          <!--
					<xsl:variable name="outerTerm" as="element()" select="."/>
          -->
          <xsl:variable name="outerTerm" as="element()">
            <!-- id attributes are added to outerTerm which then go forward into
                   outerTermPurified. This is so that the point of application 
                   of the inner rule (in outerTermPurified) can be identified as 
                   a point in outerTerm.
              -->                   
            <xsl:apply-templates select="." mode="assign_ids"/>
          </xsl:variable>
          <xsl:variable name="outerTermPurified" as="element()">
            <xsl:apply-templates select="$outerTerm" mode="remove_gat_annotations"/>
          </xsl:variable>
          <xsl:message>outer term <xsl:copy-of select="$outerTerm"/></xsl:message>
          <xsl:variable name="results" as="element(result)*">
            <xsl:apply-templates select="$outerTermPurified" mode="get_instances_of">
              <xsl:with-param name="targetTerm" select="$innerTermPurified"/>
            </xsl:apply-templates>
          </xsl:variable>
          <xsl:for-each select="$results">
            <xsl:variable name="innerContextSubstituted" as="element(context)">
              <xsl:apply-templates select="$innerContext" mode="substitution">
                <xsl:with-param name="substitutions" select="substitution"/>  
              </xsl:apply-templates>
            </xsl:variable>             
            <xsl:variable name="outerContextSubstituted" as="element(context)">
              <xsl:apply-templates select="$outerContext" mode="substitution">
                <xsl:with-param name="substitutions" select="substitution"/>
              </xsl:apply-templates>
            </xsl:variable>
            <xsl:variable name="innerTermSpecialised" as="element()">
              <xsl:apply-templates select="$innerTerm" mode="substitution">  
                <xsl:with-param name="substitutions" select="substitution"/> 
              </xsl:apply-templates>
            </xsl:variable>
            <xsl:variable name="innerTermSpecialisedText">
              <xsl:apply-templates select="$innerTermSpecialised" mode="text"/>
            </xsl:variable>

            <xsl:if test="not($outerTermPurified[@id])"><xsl:message terminate="yes">Out of spec: outerTermPurified does not have @id annotation(s)</xsl:message></xsl:if>
            <xsl:variable name="outerTermSpecialised" as="element()">
              <xsl:apply-templates select="$outerTermPurified" mode="substitution"> <!-- changed to purified because need to annotate with types after substitution -->
                <xsl:with-param name="substitutions" select="substitution"/> 
              </xsl:apply-templates>
            </xsl:variable>
            <xsl:variable name="outerTermSpecialisedText">
              <xsl:apply-templates select="$outerTermSpecialised" mode="text"/>
            </xsl:variable>
            <!-- diagnostics only -->
            <xsl:variable name="outerTerm_as_pointed_term" as="element()" >
              <xsl:apply-templates select="$outerTermPurified" mode="insert_point">                                                                               
                <xsl:with-param name="point_id" select="point_id" />
              </xsl:apply-templates>
            </xsl:variable>
            <xsl:message> outerTerm_as_pointed_term <xsl:copy-of select="$outerTerm_as_pointed_term"/></xsl:message>     
            <xsl:variable name="pointed_outerTerm_specialised" as="element()">
              <xsl:apply-templates select="$outerTerm_as_pointed_term" mode="substitution">
                <xsl:with-param name="substitutions" select="substitution"/>
              </xsl:apply-templates>
            </xsl:variable>     
            <xsl:variable name="innerSubtermOfOuterTermSpecialised" as="element()">
              <xsl:apply-templates select="$pointed_outerTerm_specialised" mode="extract_subterm_at_point"/>
            </xsl:variable>  
            <xsl:variable name="innerSubtermOfOuterTermSpecialised_text">
              <xsl:apply-templates select="$innerSubtermOfOuterTermSpecialised" mode="text"/>
            </xsl:variable>             
            <xsl:variable name="diamondContext" as="element(context)">
              <context>
                <xsl:call-template name="merge_declarations">
                  <xsl:with-param name="result_declarations_so_far" select="()"/>
                  <xsl:with-param name="lhs_declarations" select="$outerContextSubstituted/*[(some $var_or_seq 
                      in $pointed_outerTerm_specialised/descendant::*[self::*:var|self::*:seq]
                      satisfies $var_or_seq/name = ./name)]"/>
                  <xsl:with-param name="rhs_declarations" select="$innerContextSubstituted/*[(some $var_or_seq 
                      in $pointed_outerTerm_specialised/descendant::*[self::*:var|self::*:seq] 
                      satisfies $var_or_seq/name = ./name)]"/>
                </xsl:call-template>
              </context>
            </xsl:variable>

            <xsl:if test="not($outerTermSpecialised[@id])"><xsl:message terminate="yes">Out of spec: outerTermSpecialised does not have @id annotation(s)</xsl:message></xsl:if>
            <xsl:variable name="topOfDiamondRule" as="element(tT-rule)">
              <tT-rule>
                <xsl:copy-of select="$diamondContext"/>
                <tT-conclusion>
                  <term>
                    <xsl:copy-of select="$outerTermSpecialised"/>
                  </term>
                </tT-conclusion>							
              </tT-rule>
            </xsl:variable>

            <xsl:variable name="typeCorrectedDiamondRuleTypeEnriched" as="element(tT-rule)">
              <xsl:call-template name="specialise_to_correct_typing">
                <xsl:with-param name="tT-rule" select="$topOfDiamondRule"/>
              </xsl:call-template>
            </xsl:variable> 

            <xsl:variable name="topOfDiamond" as="element()" select="$typeCorrectedDiamondRuleTypeEnriched/tT-conclusion/term/*"/>
            <xsl:if test="not($topOfDiamond[@id])"><xsl:message terminate="yes">Out of spec: topOfDiamond does not have @id annotation(s)</xsl:message></xsl:if>

            <xsl:variable name="topOfDiamondPointed" as="element()">
              <xsl:apply-templates select="$topOfDiamond" mode="insert_point">
                <xsl:with-param name="point_id" select="point_id"/>
              </xsl:apply-templates>
            </xsl:variable>           
            <xsl:if test="not($topOfDiamondPointed/descendant-or-self::point)"><xsl:message terminate="yes">Out of spec: topOfDiamondPointed does not have a point</xsl:message></xsl:if>

            <!-- OUTPUT -->
            <gat:diamond xmlns="http://www.entitymodelling.org/theory/contextualcategory/sequence">
              <gat:from>
                <gat:outer>
                  <gat:id><xsl:value-of select="$outer_rule_id"/></gat:id>
                  <gat:term>
                    <!--<xsl:copy-of select="$outerTerm" />-->
                    <xsl:apply-templates select="$outerTerm" mode="text"/>
                  </gat:term>
                  <gat:context>
                    <!-- <xsl:copy-of select="$outerContext"/> -->
                    <xsl:apply-templates select="$outerContext" mode="text"/>
                  </gat:context>
                  <gat:substitution> 
                    <xsl:apply-templates  select="substitution/subject/substitute" mode="text"/>
                  </gat:substitution>
                  <gat:contextsubstituted>
                    <!--<xsl:copy-of select="$outerContextSubstituted"/>-->  <!-- MAKE INTO FIRST PASS XML. SECOND PASS TEXT OR EVEN tex -->
                    <xsl:apply-templates select="$outerContextSubstituted" mode="text"/>  
                  </gat:contextsubstituted>
                  <gat:term_specialised>
                    <!--<xsl:copy-of select="$outerTermSpecialised"/>-->
                    <xsl:apply-templates select="$outerTermSpecialised" mode="text"/>
                  </gat:term_specialised>
                  <gat:pointed_term_specialised>
                    <!--<xsl:copy-of select="$pointed_outerTerm_specialised"/>-->
                    <xsl:apply-templates select="$pointed_outerTerm_specialised" mode="text"/>
                  </gat:pointed_term_specialised>
                  <gat:point_subterm>
                    <xsl:value-of select="$innerSubtermOfOuterTermSpecialised_text"/>
                  </gat:point_subterm>
                </gat:outer>
                <gat:inner>
                  <gat:id><xsl:value-of select="$inner_rule_id"/></gat:id>
                  <gat:term><xsl:apply-templates select="$innerTerm" mode="text"/></gat:term>                   
                  <gat:context>
                    <!-- <xsl:copy-of select="$innerContext"/> -->
                    <xsl:apply-templates select="$innerContext" mode="text"/>
                  </gat:context>
                  <gat:substitution>
                    <xsl:apply-templates  select="substitution/target/substitute" mode="text"/>
                  </gat:substitution>
                  <gat:contextsubstituted>
                    <!--<xsl:copy-of select="$innerContextSubstituted"/>-->
                    <xsl:apply-templates select="$innerContextSubstituted" mode="text"/>
                  </gat:contextsubstituted>
                  <gat:term_specialised>
                    <!--<xsl:copy-of select="$innerTermSpecialised"/>-->
                    <xsl:apply-templates select="$innerTermSpecialised" mode="text"/>
                  </gat:term_specialised>
                </gat:inner>
                <gat:number><xsl:value-of select="position()"/></gat:number>
                <xsl:if test="not($innerTermSpecialisedText = $innerSubtermOfOuterTermSpecialised_text)">
                  <gat:ERROR> OUT OF SPEC </gat:ERROR>
                  <xsl:copy-of select="."/> <!-- for diagnostic purposes -->
                </xsl:if>              
              </gat:from>
              <xsl:choose>
                <xsl:when test="$typeCorrectedDiamondRuleTypeEnriched">
                  <xsl:variable name="left_reduction" as="element(term)">
                    <gat:term>
                      <xsl:for-each select="$topOfDiamond">  
                      <xsl:message>Apply named rule  <xsl:value-of select="$outer_rule_id"/>
                        </xsl:message>
                        <xsl:call-template name="apply_named_rule">
                          <xsl:with-param name="ruleid" select="$outer_rule_id"/>
                        </xsl:call-template> 
                      </xsl:for-each>
                    </gat:term>
                  </xsl:variable>

                  <!-- inner Term -->
                  <xsl:variable name="right_reduction" as="element(term)">
                    <gat:term>
                      <xsl:for-each select="$topOfDiamondPointed">
                        <xsl:message>Inner rule is <xsl:value-of select="$inner_rule_id"/>
                        </xsl:message>
                        <xsl:apply-templates select="." mode="innerReduction">
                          <xsl:with-param name="rule_id" select="$inner_rule_id"/>
                        </xsl:apply-templates> 
                      </xsl:for-each>
                    </gat:term>
                  </xsl:variable>

                  <!-- Normalise left hand side -->
                  <xsl:message> Normalise the left reduction </xsl:message>
                  <xsl:variable name="leftReductionNormalised" as="element(term)">
                    <xsl:call-template name="recursive_rewrite">
                      <xsl:with-param name="document" select="$left_reduction" />
                    </xsl:call-template>
                  </xsl:variable>
                  <xsl:variable name="leftReductionNormalisedText">
                    <xsl:apply-templates select="$leftReductionNormalised" mode="text"/>
                  </xsl:variable>								
                  <xsl:variable name="lhscost" as="xs:double">
                    <xsl:apply-templates select="$leftReductionNormalised" mode="number"/>
                  </xsl:variable>
                  <!-- Normalise right hand side -->
                  <xsl:message> Normalise the right reduction </xsl:message>
                  <xsl:variable name="rightReductionNormalised" as="element(term)">
                    <xsl:call-template name="recursive_rewrite">
                      <xsl:with-param name="document" select="$right_reduction"/>
                    </xsl:call-template>
                  </xsl:variable>
                  <xsl:variable name="rightReductionNormalisedText">
                    <xsl:apply-templates select="$rightReductionNormalised" mode="text"/>
                  </xsl:variable>							
                  <xsl:message><xsl:value-of select="$rightReductionNormalisedText"/></xsl:message>
                  <xsl:variable name="rhscost" as="xs:double">
                    <xsl:apply-templates select="$rightReductionNormalised" mode="number"/>
                  </xsl:variable>
                  <!-- OUTPUT -->
                  <gat:first_pass_diamond_context>
                    <xsl:apply-templates select="$diamondContext" mode="text"/> 
                  </gat:first_pass_diamond_context>     
                  <gat:first_pass_top_of_diamond>
                    <xsl:apply-templates select="$outerTermSpecialised" mode="text"/>
                  </gat:first_pass_top_of_diamond>
                  <!--
                  <gat:first_pass_diamond_type_errors>
                    <xsl:apply-templates select="$topOfDiamondInitial" mode="text_report_errors"/>
                  </gat:first_pass_diamond_type_errors>
                  -->
                  <!-- second pass -->
                  <gat:diamond_context>
                    <xsl:apply-templates select="$typeCorrectedDiamondRuleTypeEnriched/context" mode="text"/> 
                  </gat:diamond_context>

                  <!--COPY the ancestor term with the result substitutions and mark application_node_id -->
                  <gat:top_of_diamond>
                    <!-- <xsl:copy-of select="$topOfDiamond"/> -->
                    <xsl:apply-templates select="$topOfDiamond" mode="text"/>
                  </gat:top_of_diamond>
                  <gat:top_of_diamond_pointed>
                    <!-- <xsl:copy-of select="$topOfDiamondPointed"/> -->
                    <xsl:apply-templates select="$topOfDiamondPointed" mode="text"/>
                  </gat:top_of_diamond_pointed>

                  <gat:top_of_diamond_type_errors>							     
                    <!--<xsl:copy-of select="$topOfDiamondRuleTypeEnriched/tT-conclusion/term"/>-->
                    <xsl:apply-templates select="$topOfDiamond" mode="text_report_errors"/>
                  </gat:top_of_diamond_type_errors>

                  <gat:leftreduction>
                    <!--<xsl:copy-of select="$left_reduction" />-->
                    <xsl:apply-templates select="$left_reduction" mode="text"/>
                  </gat:leftreduction>
                  <gat:rightreduction>
                    <!--<xsl:copy-of select="$right_reduction" />-->
                    <xsl:apply-templates select="$right_reduction" mode="text"/>
                  </gat:rightreduction>
                  <gat:leftReductionNormalised>
                    <!--
									<xsl:if test="not($leftReductionNormalisedText=$rightReductionNormalisedText)">
										<xsl:copy-of select="$leftReductionNormalised"/>
									</xsl:if>
                  -->
                    <gat:text>
                      <xsl:value-of select="$leftReductionNormalisedText"/>
                      <xsl:text>{</xsl:text>
                      <xsl:value-of select="$lhscost"/>
                      <xsl:text>}</xsl:text>
                    </gat:text>
                  </gat:leftReductionNormalised>
                  <gat:rightReductionNormalised>
                    <!--
									<xsl:if test="not($leftReductionNormalisedText = $rightReductionNormalisedText)">
										<xsl:copy-of select="$rightReductionNormalised"/>
									</xsl:if>
                  -->                  
                    <gat:text>
                      <xsl:value-of select="$rightReductionNormalisedText"/>
                      <xsl:text>{</xsl:text>
                      <xsl:value-of select="$rhscost"/>
                      <xsl:text>}</xsl:text>
                    </gat:text>
                  </gat:rightReductionNormalised>
                  <xsl:if test="not($leftReductionNormalisedText=$rightReductionNormalisedText)">
                    <gat:NON-CONFLUENT/>
                    <xsl:if test="$lhscost=$rhscost">
                      <gat:STALEMATE/>
                    </xsl:if>
                    <xsl:if test="$lhscost &lt; $rhscost">
                      <gat:RIGHT-TO-LEFT/>
                    </xsl:if>
                    <xsl:if test="$rhscost &lt; $lhscost">
                      <gat:LEFT-TO-RIGHT/>
                    </xsl:if>
                    <xsl:message>*************  NON CONFLUENT ************</xsl:message>
                  </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                  <ABANDONED_DUE_TO_TYPE_ERRORS/>
                </xsl:otherwise>
              </xsl:choose>
            </gat:diamond>
          </xsl:for-each> <!-- end outer term -->
        </xsl:for-each> <!-- end inner term -->
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>

  <xsl:template name="specialise_to_correct_typing">
    <xsl:param name="tT-rule" as="element(tT-rule)"/>
    <!--
    <xsl:variable name="tT-rulePurified" as="element(tT-rule)">
            <xsl:apply-templates select="$tT-rule" mode="remove_gat_annotations"/>
    </xsl:variable>
	-->
    <xsl:variable name="tT-ruleTypeEnriched" as="element(tT-rule)">
      <xsl:apply-templates select="$tT-rule" mode="type_enrich"/>
    </xsl:variable>
    <xsl:variable name="termInitial" as="element()" select="$tT-ruleTypeEnriched/tT-conclusion/term/*"/>
    <xsl:variable name="first_type_error" select="$termInitial/descendant::type_error[1]" as="element(type_error)?"/>
    <xsl:choose>
      <xsl:when test="$first_type_error and not($termInitial/descendant::illformed)">
        <xsl:message> Found type error <xsl:value-of select="$first_type_error/description"/> </xsl:message>
        <xsl:variable name="lhs" as="element()">
          <xsl:apply-templates select="$first_type_error/need-equal/lhs" mode="remove_gat_annotations"/>
        </xsl:variable>
        <xsl:variable name="rhs" as="element()">
          <xsl:apply-templates select="$first_type_error/need-equal/rhs" mode="remove_gat_annotations"/>
        </xsl:variable>
        <xsl:for-each select="$lhs/*"> 
          <xsl:variable name="specialisation_results" as="element()*">
            <xsl:call-template name="specialiseTerm">
              <xsl:with-param name="targetTerm" select="$rhs/*"/>
            </xsl:call-template>
          </xsl:variable>        
          <xsl:choose>
            <xsl:when test="not($specialisation_results) or $specialisation_results[self::INCOMPATIBLE]">
              <xsl:message>Cannot specialise diamond to be well-typed</xsl:message>
              <xsl:copy-of select="$tT-rule"/> 
            </xsl:when>
            <xsl:otherwise>
              <xsl:message>Applying type correction substitution</xsl:message>
              <xsl:variable name="typeImprovedtT-rule" as="element(tT-rule)">   
                <xsl:apply-templates select="$tT-rule" mode="substitution">
                  <xsl:with-param name="substitutions" select="$specialisation_results[1]"/> <!-- just do the first one -->
                </xsl:apply-templates>  
              </xsl:variable>
              <xsl:call-template name="specialise_to_correct_typing">
                <xsl:with-param name="tT-rule" select="$typeImprovedtT-rule"/>
              </xsl:call-template>         
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="$tT-rule" mode="type_enrich"/>
      </xsl:otherwise>
    </xsl:choose>  
    <!--      
    </xsl:variable>
    <xsl:if test="$type_correction_substitution">
      <xsl:variable name="typeCorrectedDiamondRule" as="element(tT-rule)">
        <xsl:apply-templates select="$topOfDiamondRule" mode="substitution">
          <xsl:with-param name="substitutions" select="$type_correction_substitution"/>
        </xsl:apply-templates>
      </xsl:variable>

      <xsl:variable name="typeCorrectedDiamondRuleTypeEnriched" as="element(tT-rule)">
        <xsl:apply-templates select="$typeCorrectedDiamondRule" mode="type_enrich"/>
      </xsl:variable>

      <xsl:variable name="topOfDiamond" as="element()" select="$typeCorrectedDiamondRuleTypeEnriched/tT-conclusion/term/*"/>
      <xsl:variable name="topOfDiamondPointed" as="element()">
        <xsl:apply-templates select="$topOfDiamond" mode="insert_point">
          <xsl:with-param name="point_id" select="point_id"/>
        </xsl:apply-templates>
      </xsl:variable>
    </xsl:if>
    -->

  </xsl:template>

  <xsl:template match="*" mode="remove_gat_annotations">
    <!-- need to keeep gat:name however -->
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:copy-of select="gat:name"/> <!-- only applicable to var's and seq's -->
      <xsl:apply-templates select="*[not(self::gat:*)]" mode="remove_gat_annotations"/>
    </xsl:copy>
  </xsl:template>


  <xsl:template match="gat:*" mode="assign_ids">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates  mode="assign_ids"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*[not(self::gat:*)][@id]" mode="assign_ids">
    <!-- need to keeep gat:name however -->
    <xsl:message>No need to add an id</xsl:message>
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates  mode="assign_ids"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*[not(self::gat:*)][not(@id)]" mode="assign_ids">
    <!-- need to keeep gat:name however -->
    <xsl:message>aDDING AN ID </xsl:message>
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="id" select="generate-id()"/>
      <xsl:apply-templates  mode="assign_ids"/>
    </xsl:copy>
  </xsl:template>


  <xsl:template name="merge_declarations">
    <xsl:param name="result_declarations_so_far" as="element()*"/>
    <xsl:param name="lhs_declarations" as="element()*"/>
    <xsl:param name="rhs_declarations" as="element()*"/>
    <xsl:variable name="next_from_lhs" as="element()?">
      <xsl:copy-of select="$lhs_declarations[not(some $var_or_seq in ($lhs_declarations|$rhs_declarations)/type satisfies $var_or_seq/name = ./name)][1]"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$next_from_lhs">
        <xsl:variable name="result_next" as="element()*">
          <xsl:copy-of select="$result_declarations_so_far"/>
          <xsl:copy-of select="$next_from_lhs"/>
        </xsl:variable>
        <xsl:call-template name="merge_declarations">
          <xsl:with-param name="result_declarations_so_far" select="$result_next"/>
          <xsl:with-param name="lhs_declarations" select="$lhs_declarations[not(name=$next_from_lhs/name)]"/>
          <xsl:with-param name="rhs_declarations" select="$rhs_declarations"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="next_from_rhs" as="element()?">
          <xsl:copy-of select="$rhs_declarations[not(some $var_or_seq in ($lhs_declarations|$rhs_declarations)/type satisfies $var_or_seq/name = ./name)][1]"/>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$next_from_rhs">
            <xsl:variable name="result_next" as="element()*">
              <xsl:copy-of select="$result_declarations_so_far"/>
              <xsl:copy-of select="$next_from_rhs"/>
            </xsl:variable>
            <xsl:call-template name="merge_declarations">
              <xsl:with-param name="result_declarations_so_far" select="$result_next"/>
              <xsl:with-param name="lhs_declarations" select="$lhs_declarations"/>
              <xsl:with-param name="rhs_declarations" select="$rhs_declarations[not(name=$next_from_rhs/name)]"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="$result_declarations_so_far"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
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
    <!--    <xsl:param name="point_id"/> -->
    <xsl:param name="rule_id"/>
    <!--
    <xsl:if test="not(@id)">
      <xsl:message terminate="yes">Out of spec.:innerReduction of a term without @id annotations.</xsl:message>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="@id=$point_id">
        <xsl:call-template select="." name="apply_named_rule">
          <xsl:with-param name="ruleid" select="$rule_id"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
      -->
    <xsl:copy>
      <xsl:apply-templates mode="innerReduction">
        <xsl:with-param name="rule_id" select="$rule_id"/>
      </xsl:apply-templates>
    </xsl:copy>
    <!--
      </xsl:otherwise>
    </xsl:choose>
    -->
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
    <xsl:param name="document" as="element()"/>
    <xsl:message>
      entering recursive_rewrite <xsl:apply-templates select ="$document" mode="text"/>
    </xsl:message>
    <xsl:variable name ="next" as="element()">
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
    <xsl:variable name="substitutions" as="element()*">
      <xsl:call-template name="specialiseTerm">
        <xsl:with-param name="targetTerm" select="$targetTerm"/>
      </xsl:call-template>
    </xsl:variable> 

    <xsl:variable name="point_id" select="@id"/>  
    <!--
    <xsl:variable name="ancestor_lhs" select="ancestor-or-self::lhs/*[1]"/>
    -->
    <!-- If found then add to the output stream -->
    <xsl:for-each select="$substitutions">
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
      <xsl:when test="@id=$point_id">
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

