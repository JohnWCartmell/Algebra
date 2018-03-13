<xsl:transform version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:gat              ="http://www.entitymodelling.org/theory/generalisedalgebraictheory"
    xpath-default-namespace="http://www.entitymodelling.org/theory/generalisedalgebraictheory"	   
    xmlns="http://www.entitymodelling.org/theory/generalisedalgebraictheory">

  <!-- The entry point to these templates is "specialiseTerm". -->

  <!-- Terminological Remark: specialiseTerm is invoked with a *subject* term as the 
                            current context and is passed a *target* term parameter. 
   -->                         
  <!-- 21 Feb 2018 Improve the structure of the code by replacing as=node() for xslt
       variables by as="element(<name>)" whereever it is possible.
    -->
  <!-- 21 Feb 2018 Separate all the subject and target substitutions into
              <substitution>
                       <subject>SUBSTITUTE*</subject>
                       <target>SUBSTITUTE*</target>
              </substitution>
      where
              SUBSTITUTE ::= <substitute>
                                  <var>|<seq>
                                       <gat:name>cccc</gat:name>
                                  <gat:term>
                                       ...
                                  </gat:term>
                             </substitute> 
   -->                             

  <!-- 
     specialiseTerm 
     ==============
     Find a substitutional instance of a given term that
     matches a target term.
     Returns either <INCOMPATIBLE/> if none possible
     or one or more <substitution> elements.
     A <substitution> element contains one or more <substitute> elements each 
     specifying a variable <var>  and a <term> to be substituted for it
     or a <seq> and zero, one or more <term> elements to be substituted for it.          
  -->

  <!-- Call Graph -->
  <!-- "specialiseTerm"                           calls "proceedFromAllTargetSequenceBackMappings"
                                                  and   "specialiseSubTermsFrom"
       "proceedFromAllTargetSequenceBackMappings" calls "specialiseSubTermsFrom"
       "specialiseSubTermsFrom"                   calls "head_substitutions"
                                                  and   "specialiseSubTermsFrom"
                                                  and   "applyTargetSubstitutions"
       "head_substitutions"                       calls "specialiseTerm"
                                                  and   "leading_subterm_specialisations"
       "leading_subterm_specialisations"          calls "specialiseTerm"
                                                  and   "leading_subterm_specialisations"
     -->

  <xsl:template name="specialiseTerm">
    <xsl:param name="targetTerm" as="element()"/>
    <xsl:message>specialiseTerm subjectTerm: <xsl:apply-templates select="." mode="text"/>
    </xsl:message>
    <xsl:message>specialiseTerm  targetTerm: <xsl:apply-templates select="$targetTerm" mode="text"/>
    </xsl:message>
    <xsl:if test="self::seq"><xsl:message terminate="yes">Assertion failure: specialiseTerm called with seq as subject</xsl:message></xsl:if>
    <xsl:choose>
      <!-- 15 Feb 2017 switched order of these when branches -->
      <!-- to avoid proof that f=g -->
      <xsl:when test=".[self::*:var]">
        <!--  BELIEVE THAT WE NEED THE self::seq CASE for engulfing target seq-->
        <xsl:choose>
          <xsl:when test="$targetTerm[self::*:var] and ./name=$targetTerm/name">
            <xsl:message>new empty substitution for var </xsl:message>
            <substitution>
              <subject/>
              <target/>
            </substitution>
          </xsl:when>
          <xsl:when test="$targetTerm[self::*:seq] and ./name=$targetTerm/name">
            <xsl:message>new empty substitution for seq </xsl:message>
            <substitution>
              <subject/>
              <target/>
            </substitution>
          </xsl:when>
          <xsl:otherwise>
            <xsl:choose>
              <xsl:when test="self::*:var and (some $targetvar in $targetTerm/descendant::*:var satisfies $targetvar/name=name)">
                <INCOMPATIBLE/>
              </xsl:when>
              <xsl:when test="self::*:seq and (some $targetseq in $targetTerm/descendant::*:seq satisfies $targetseq/name=name)">
                <INCOMPATIBLE/>
              </xsl:when>
              <xsl:otherwise>
                <substitution>
                  <subject>
                    <substitute>
                      <xsl:copy>
                        <xsl:apply-templates mode="copy"/>
                      </xsl:copy>
                      <term>
                        <xsl:copy-of select="$targetTerm"/>
                      </term>
                    </substitute>
                  </subject>
                  <target>
                  </target>
                </substitution>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="$targetTerm[self::*:var]">
        <xsl:choose>
          <xsl:when test="some $subjectvar in ./descendant::* satisfies $subjectvar/name = $targetTerm/name">
            <INCOMPATIBLE/>
          </xsl:when>
          <xsl:otherwise>
            <substitution>
              <subject>
              </subject>
              <target>
                <substitute>
                  <placeone/>
                  <xsl:copy-of select="$targetTerm"/>
                  <term>
                    <xsl:copy-of select="."/>
                  </term>
                </substitute>
              </target>
            </substitution>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="name(.) != name($targetTerm)">
        <INCOMPATIBLE/>
      </xsl:when>
      <xsl:otherwise> 
        <!-- descend -->
        <xsl:choose>
          <xsl:when test="count(./*)=0"> <!-- zero subterms -->
            <xsl:choose>
              <xsl:when test="count($targetTerm/*)=0">   <!-- add not seq ??? -->
                <substitution><subject/><target/></substitution>
              </xsl:when>
              <xsl:otherwise>
                <INCOMPATIBLE/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="count($targetTerm/*)=0"> <!-- if get here then  count(./*) != 0 -->
            <INCOMPATIBLE/>
          </xsl:when>
          <xsl:when test="$targetTerm/*[1][self::*:seq]">
            <xsl:call-template name="proceedFromAllTargetSequenceBackMappings">
              <xsl:with-param name="targetTerm" select="$targetTerm"/>
              <xsl:with-param name="targetIndex" select="1"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:message>specialiseTerm to specialiseSubTermsFrom</xsl:message>
            <xsl:call-template name="specialiseSubTermsFrom">
              <xsl:with-param name="targetTerm" select="$targetTerm"/>
              <xsl:with-param name="targetIndex" select="1"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:message>Exit specialiseTerm</xsl:message>
  </xsl:template>

  <!-- proceedFromAllTargetSequenceBackMappings -->
  <xsl:template name="proceedFromAllTargetSequenceBackMappings">
    <xsl:param name="targetTerm" as="element()"/>
    <xsl:param name="targetIndex" as="xs:integer" />
    <xsl:message>pFATSBM dotTerm <xsl:apply-templates select="." mode="text"/>
    </xsl:message>
    <xsl:message> pFATSBM targetTerm <xsl:apply-templates select="$targetTerm" mode="text"/>
    </xsl:message>
    <xsl:variable name="subject" as="element()" select="."/> <!-- added for diagnostics -->
    <xsl:if test="not($targetTerm/*[$targetIndex]/name()='seq')"><xsl:message terminate="yes"/></xsl:if>
    <xsl:if test="not($targetIndex=1)"><xsl:message terminate="yes"/></xsl:if>
    <xsl:variable name="seq" select="$targetTerm/*[$targetIndex]"/>
    <!-- full case    check that targetIndex is final?  -->
    <xsl:if test="$targetIndex = count($targetTerm/*)"> <!-- I am not sure that this test is needed but it does avoid unnecssary computation followed by backtracking -->
      <xsl:if test="not(some $subjectseq in ./descendant::*:seq satisfies $subjectseq/name=$seq/name)">
        <substitution>
          <subject>
          </subject>
          <target>
            <substitute>
              <placenine/>
              <xsl:copy-of select="$seq"/>
              <xsl:for-each select="*">
                <term>
                  <xsl:copy-of select="."/>
                </term>
              </xsl:for-each>
            </substitute>
          </target>
        </substitution>
      </xsl:if>
    </xsl:if>

    <!--remainder cases -->
    <xsl:for-each select="*">
      <xsl:if test=" (count(preceding-sibling::*) = 1 and preceding-sibling::*:seq)
          or not(some $subjectseq in preceding-sibling::*/descendant-or-self::*:seq satisfies $subjectseq/name=$seq/name)">
        <xsl:variable name="subjectTail" as="element(tail)">  
          <tail> 
            <xsl:copy-of  select="self::*|following-sibling::*"/>
          </tail>
        </xsl:variable>
        <xsl:variable name="substitution" as="element(substitution)">
          <substitution>
            <subject></subject>
            <target>
              <substitute>
                <xsl:copy-of select="$seq"/>
                <xsl:for-each select="preceding-sibling::*">
                  <term>
                    <xsl:copy-of select="."/>
                  </term>
                </xsl:for-each>
              </substitute>
            </target>
          </substitution>
        </xsl:variable>

        <xsl:variable name="subjectTail_specialised" as="element(tail)">
          <xsl:apply-templates select="$subjectTail" mode="substitution">
            <xsl:with-param name="substitutions" select="$substitution"/>
          </xsl:apply-templates>
        </xsl:variable>   

        <xsl:variable name="tail_substitutions" as="element(substitution)*">
          <!-- Specialise Targetterm also because the seq might occur more than once in target term -->
          <xsl:choose>
            <xsl:when test="$targetIndex+1 &lt; count($targetTerm/*)+1">   
              <xsl:variable name="targetTermTail" as="element(tail)">
                <tail>
                  <xsl:copy-of select="$targetTerm/*[count(preceding-sibling::*)+1 &gt; $targetIndex]"/> 
                </tail>
              </xsl:variable>
              <xsl:message> length of target tail <xsl:value-of select="count($targetTermTail/*)"/></xsl:message>
              <xsl:variable name="targetTermTail_specialised" as="element(tail)">
                <xsl:apply-templates select="$targetTermTail" mode="substitution">
                  <xsl:with-param name="substitutions" select="$substitution"/>
                </xsl:apply-templates>
              </xsl:variable>
              <xsl:message> length of target tail specialised<xsl:value-of select="count($targetTermTail_specialised/*)"/></xsl:message>

              <xsl:for-each select="$subjectTail_specialised">  
                <xsl:message>pFATSBM call to specialiseSubTermsFrom</xsl:message>
                <xsl:call-template name="specialiseSubTermsFrom">
                  <xsl:with-param name="targetTerm" select="$targetTermTail_specialised"/>
                  <xsl:with-param name="targetIndex" select="1"/>
                </xsl:call-template> 
              </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
              <!-- check if tail is empty? -->
              <xsl:if test="count($subjectTail/*) = 0">
                <!-- late addition -->
                <substitution>
                  <subject/>
                  <target/>
                </substitution>
              </xsl:if>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:message> pFATSBM intmdt subject <xsl:apply-templates select="$subject" mode="text"/></xsl:message>
        <xsl:message> pFATSBM targetTerm <xsl:apply-templates select="$targetTerm" mode="text"/></xsl:message>
        <xsl:message> pFATSBM targetIndex <xsl:value-of select="$targetIndex"/></xsl:message>
        <xsl:message> pFATSBM Loop <xsl:value-of select="position()"/> </xsl:message>
        <xsl:message> pFATSBM count($subjectTail/*) <xsl:value-of select="count($subjectTail/*)"/> </xsl:message>
        <xsl:message> pFATSBMNumber of tail_substitutions <xsl:value-of select="count($tail_substitutions)"/> </xsl:message>

        <xsl:apply-templates select="$tail_substitutions" mode="compose_substitutions">
          <xsl:with-param name="head_substitution" select="$substitution"/>
        </xsl:apply-templates>
      </xsl:if>
    </xsl:for-each>
    <xsl:message>pFATSBM exiting</xsl:message>
  </xsl:template>


  <!-- specialiseSubTermsFrom
       ======================
       Iterate along subterms of a given term establishing 
       and appplying successive substitutions to specialise 
       each subterm to match a correspondingly positioned subterm 
       of a target term.
       Returms either <INCOMPATIBLE/> or zero, one or more 
       <substitution> elements.
  -->
  <xsl:template name="specialiseSubTermsFrom">
    <xsl:param name="targetTerm" as="element()"/>
    <xsl:param name="targetIndex" as="xs:integer"/>
    <xsl:message>   sSTF specialise subterms from subject: <xsl:apply-templates select="." mode="text"/>
    </xsl:message>
    <xsl:message>   sSTF                        to target: <xsl:apply-templates select="$targetTerm" mode="text"/>
    </xsl:message>
    <xsl:message>   sSTF targetIndex <xsl:value-of select="$targetIndex"/>
    </xsl:message>
    <xsl:variable name="subjectTerm" as="element()" select="." />
    <xsl:if test="($targetIndex &gt; count($targetTerm/*)) and not(*[1][self::*:seq])"><xsl:message terminate="yes">Out of Spec $targetIndex beyond subterm count </xsl:message></xsl:if>

    <xsl:variable name="headsubstitutions" as="element(head_substitution)*">
      <xsl:call-template name="head_substitutions">
        <xsl:with-param name="targetTerm" select="$targetTerm"/>
        <xsl:with-param name="targetIndex" select="$targetIndex"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:message>   sSTF Will now iterate through each of <xsl:value-of select="count($headsubstitutions)"/>
    </xsl:message>
    <xsl:for-each select="$headsubstitutions">
      <xsl:variable name="head_substitution" select="." as="element(head_substitution)"/>
      <xsl:message>   sSFT iteration               subjectTerm <xsl:apply-templates select="$subjectTerm" mode="text"/> </xsl:message>
      <xsl:message>                                targetTerm <xsl:apply-templates select="$targetTerm" mode="text"/> </xsl:message>
      <xsl:message>                                targetIndex <xsl:value-of select="$targetIndex"/>                  </xsl:message>
      <xsl:message>                                substitution subject <xsl:apply-templates select="$head_substitution/substitution/subject" mode="text"/> </xsl:message>
      <xsl:message>                                substitution target <xsl:apply-templates select="$head_substitution/substitution/target" mode="text"/> </xsl:message>
      <xsl:message><xsl:copy-of select="substitution/traceback"/></xsl:message>
      <xsl:if test="not($head_substitution/tail)">
        <xsl:message terminate="yes">   sSTF **** type error - tail assertion fails </xsl:message>
      </xsl:if>
      <xsl:variable name="numberOfTargetChildrenConsumed" as="xs:integer" select="numberOfTargetChildrenConsumed"/>
      <xsl:message>                                number of target children consumed  <xsl:value-of select="$numberOfTargetChildrenConsumed" /> </xsl:message>
      <xsl:choose>
        <xsl:when test="count($head_substitution/tail/*) = 0">
          <!-- BANBURY -->
          <xsl:if test="not($head_substitution/substitution[self::substitution])">
            <xsl:message terminate="yes"> ***** return type assertion fails at BANBURY </xsl:message>
          </xsl:if>
          <xsl:choose>
            <xsl:when test="($targetIndex + $numberOfTargetChildrenConsumed &gt; count($targetTerm/* ))">
              <xsl:message>   sSTF finished consumption branch one</xsl:message>
              <xsl:copy-of select="$head_substitution/substitution"/>  
            </xsl:when>
            <xsl:when test="($targetIndex + $numberOfTargetChildrenConsumed + 1 &gt; count($targetTerm/* ) )
                and ($targetTerm/*[$targetIndex + $numberOfTargetChildrenConsumed][self::*:seq])
                ">
              <xsl:message>   sSTF finished consumption branch two - insert targetSubstitution</xsl:message>

              <xsl:message>   sSTF About to insert empty seq </xsl:message>
              <xsl:variable name="substitute" as="element(substitute)">
                <substitute>
                  <xsl:copy-of select="$targetTerm/*[$targetIndex + $numberOfTargetChildrenConsumed]"/>
                  <!-- empty set of term -->
                </substitute>
              </xsl:variable>
              <xsl:apply-templates select="$head_substitution/substitution" mode="insert_target_substitute">          
                <xsl:with-param name="substitute" select="$substitute"/>
              </xsl:apply-templates>               
            </xsl:when>
          </xsl:choose>
        </xsl:when >
        <xsl:when test="count($head_substitution/tail/*) &gt; 0">  
          <xsl:variable name="targetTail" as="element(tail)">
            <tail>
              <xsl:copy-of select="$targetTerm/*[position() &gt; $targetIndex + $numberOfTargetChildrenConsumed - 1]"/>
            </tail>
          </xsl:variable>            
          <xsl:variable name="targetTailSpecialised" as="element()">
            <xsl:message>   sSTF about to sub into targetTail <xsl:apply-templates select="$targetTail" mode="text"/> </xsl:message>
            <xsl:apply-templates select="$targetTail" mode="substitution">
              <xsl:with-param name="substitutions" select="$head_substitution/substitution"/>
            </xsl:apply-templates>
          </xsl:variable> 
          <xsl:message>   sSTF target tail specialised <xsl:apply-templates select="$targetTailSpecialised" mode="text"/>
          </xsl:message>
          <xsl:variable name="subjectTailSpecialised" as="element(tail)">
            <xsl:for-each select="$head_substitution/tail">
              <xsl:apply-templates select="." mode="substitution">
                <xsl:with-param name="substitutions" select="$head_substitution/substitution"/>  
              </xsl:apply-templates>
            </xsl:for-each>
          </xsl:variable>
          <xsl:message>   sSTF subject tail specialised <xsl:apply-templates select="$subjectTailSpecialised" mode="text"/>
          </xsl:message>

          <xsl:choose>
            <!-- was before 12 March 2018 21:36
            <xsl:when test="($targetIndex + $numberOfTargetChildrenConsumed &lt; count($targetTerm/* ) + 1)
                or ( count($head_substitution/tail/*) = 1 and  $head_substitution/tail/*[self::*:seq]  )"> 
                now -->
            <xsl:when test="(count($targetTailSpecialised/*) &gt; 0)
                or (count($subjectTailSpecialised/*) = 1 and  $subjectTailSpecialised/*[self::*:seq]  )"> <!-- I NEED to RECONSIDER WHETER SHOULD BE subjecttail or subject tailspecialised here -->

              <!-- moved up ouside of choice 
              <xsl:variable name="subjectTailSpecialised" as="element(tail)">
                <xsl:for-each select="$head_substitution/tail">
                  <xsl:apply-templates select="." mode="substitution">
                    <xsl:with-param name="substitutions" select="$head_substitution/substitution"/>  
                </xsl:for-each>
              </xsl:variable>
              <xsl:message>   sSTF subject tail specialised <xsl:apply-templates select="$subjectTailSpecialised" mode="text"/>
              </xsl:message>
              -->

              <!-- moved up ouside choose 
              <xsl:variable name="targetTail" as="element(tail)">
                  <tail>
                     <xsl:copy-of select="$targetTerm/*[position() &gt; $targetIndex + $numberOfTargetChildrenConsumed - 1]"/>
                  </tail>
              </xsl:variable>            
              <xsl:variable name="targetTailSpecialised" as="element()">
                <xsl:message>   sSTF about to sub into targetTail <xsl:apply-templates select="$targetTail" mode="text"/> </xsl:message>
                <xsl:apply-templates select="$targetTail" mode="substitution">
                  <xsl:with-param name="substitutions" select="$head_substitution/substitution"/>
                </xsl:apply-templates>
              </xsl:variable> 
              <xsl:message>   sSTF target tail specialised <xsl:apply-templates select="$targetTailSpecialised" mode="text"/>
              </xsl:message>
              -->

              <xsl:variable name="tail_substitutions" as="element(substitution)*">
                <xsl:for-each select="$subjectTailSpecialised">
                  <xsl:message>   sSTF call to itself (specialiseSubTermsFrom) recursively</xsl:message>
                  <xsl:call-template name="specialiseSubTermsFrom">   
                    <xsl:with-param name="targetTerm" select="$targetTailSpecialised"/>  <!-- 13 April 2017 -->
                    <xsl:with-param name="targetIndex" select="1"/>  
                  </xsl:call-template>
                </xsl:for-each>
              </xsl:variable>
              <!-- was
              <xsl:for-each select="$tail_substitutions">
                <xsl:if test="not(self::substitution)">
                  <xsl:message terminate="yes"> ***** type assertion substitution fails on tail </xsl:message>
                </xsl:if>
                <substitution>              
                   REMARK 22 Feb 2018 Shouldn't the tail substitution be applied to the head 
                     substitutions in a compose substitutions operation? 
                  <xsl:copy-of select="$head_substitution/substitution/*"/>
                  <xsl:copy-of select="./*"/>
                </substitution>
              </xsl:for-each>
              <xsl:message>   sSTF call compose of<xsl:apply-templates  select="$tail_substitutions" mode="text"/>
                and <xsl:apply-templates  select="$head_substitution/substitution" mode="text"/>
              </xsl:message>
                but now -->
              <xsl:apply-templates select="$tail_substitutions" mode="compose_substitutions">
                <xsl:with-param name="head_substitution" select="$head_substitution/substitution"/>
              </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
              <xsl:message>   sSTF iteration leg with no solution</xsl:message>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message terminate="yes">***** UNexpectedly got HERE </xsl:message>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
    <xsl:message>Exiting sSTF</xsl:message>
  </xsl:template>


  <!-- head_substitutions
     ==================
     A head subterm of a term is the first subterm 
     plus, if the first subterm is a sequence, the second subterm also.
     "head_substitutions" finds all substitutions that can be made into
     the head subterms of the current term to bring them to match some
     sequence of subterms of the target term commencing from the target index.
     
     Returns zero one or more <head_substitution> elements.
     each <head_substitution> element contains
     a <substitution> element and a <tail> element and a <numberOfTargetChildrenConsumed> element.
     The <tail> element contains remaining subterms of the current term.
     
     21 Feb 2018 Add a postcondition:
            <numberOfTargetChildrenConsumed>=count(<substitution>/<substitute>/<term>)
-->

  <xsl:template name="head_substitutions">
    <xsl:param name="targetTerm" as="element()"/>
    <xsl:param name="targetIndex" as="xs:integer"/>
    <xsl:variable name="head_substitution_entry_number" select="generate-id()"/>
    <xsl:variable name="subjectTerm_text"><xsl:apply-templates select="." mode="text"/></xsl:variable>
    <xsl:variable name="targetTerm_text"><xsl:apply-templates select="$targetTerm" mode="text"/></xsl:variable>
    <xsl:message>      hS  head_substitution entry number: <xsl:value-of select="$head_substitution_entry_number"/>
    </xsl:message>
    <xsl:message>      hS  subjectTerm   <xsl:apply-templates select="." mode="text"/>
    </xsl:message>
    <xsl:message>      hS  targetTerm  <xsl:apply-templates select="$targetTerm" mode="text"/>
    </xsl:message>
    <xsl:message>      hS targetIndex  <xsl:value-of select="$targetIndex"/>
    </xsl:message>
    <xsl:variable name="head_substitutions" as="element(head_substitution)*">
      <xsl:choose>
        <xsl:when test="not(./*[1][self::*:seq]) and not($targetTerm/*[$targetIndex][self::*:seq])">
          <xsl:message> hS branch 1 </xsl:message>
          <!-- source is not  target is not seq -->
          <xsl:variable name="substitutions" as="element()*">  <!--  one or more (<substitution> or <INCOMPATIBLE/>) -->
            <xsl:for-each select="./*[1]">  
              <xsl:call-template name="specialiseTerm">
                <xsl:with-param name="targetTerm" select="$targetTerm/*[$targetIndex]"/>
              </xsl:call-template>
            </xsl:for-each>
          </xsl:variable>

          <xsl:variable name="tailTerms" as="element()*" select="./*[position() &gt; 1]"/>
          <xsl:message>      hS branch 1 tailTerms are <xsl:apply-templates select="$tailTerms" mode="text"/> 
          </xsl:message>
          <xsl:for-each select="$substitutions">
            <xsl:if test="not(self::INCOMPATIBLE)">
              <head_substitution>
                <xsl:message>      hS name of DOT in constructor of head substitution (require 'substitution') is <xsl:value-of select="name()"/>
                </xsl:message>
                <xsl:copy-of select="."/>
                <tail>
                  <xsl:copy-of select="$tailTerms"/>  <!-- xxx should this be specialised????-->
                </tail>
                <numberOfTargetChildrenConsumed>1</numberOfTargetChildrenConsumed>
              </head_substitution>
            </xsl:if>
          </xsl:for-each>
        </xsl:when>

        <xsl:when test="not(./*[1][self::*:seq]) and $targetTerm/*[$targetIndex][self::*:seq]">
          <xsl:message>      hS branch 2 - target subterm is a seq</xsl:message>  
          <xsl:variable name="targetseq" as="element()" select="$targetTerm/*[$targetIndex]"/>
          <xsl:for-each select="./*[not(some $subjectsubterm 
              in (descendant-or-self::*:seq | preceding-sibling::*/descendant-or-self::*:seq) 
              satisfies $subjectsubterm/name=$targetseq/name
              )
              ]
              ">
            <head_substitution>
              <substitution>
                <subject>
                </subject>
                <target>
                  <substitute>
                    <placethree/>
                    <xsl:copy-of select="$targetseq"/>
                    <xsl:for-each select="self::* | preceding-sibling::*">
                      <term>
                        <xsl:copy-of select="."/>
                      </term>
                    </xsl:for-each>
                  </substitute>
                </target>
              </substitution>
              <tail>
                <xsl:copy-of  select="following-sibling::*"/>
              </tail>
              <numberOfTargetChildrenConsumed>
                <xsl:value-of select="1"/>
              </numberOfTargetChildrenConsumed>
            </head_substitution>
          </xsl:for-each>
        </xsl:when>

        <!-- XXXX
         if there is a later seq in target we will reach it
         therefore there will be lots of possibilities iterate through then all
         calculating the substitution forward mapping and back mapping returning the head substitution
         that we get lots of matches is not the question - the question is how many and what is left at the end
         both can be returned from here         
         separate out the when clauses
         else if not
         -->
        <!-- current seq can map to any upto end of target-->


        <xsl:when test="(./*[1][self::*:seq]) and count(./*) &gt; 1">
          <xsl:message>      Hs branch 3 </xsl:message>
          <xsl:variable name="seq" as="element()" select="./*[1]"/> <!-- actually a seq element but I don't know how to specify a ccseq namespace -->
          <xsl:variable name="seq_sub_options" as="element(match)*">
            <xsl:message>      hS branch 3 about to call leading_subterm_specialisations</xsl:message>
            <xsl:for-each select="./*[2]">
              <xsl:call-template name="leading_subterm_specialisations">
                <xsl:with-param name="targetTerm" select="$targetTerm"/>
                <xsl:with-param name="targetIndex" select="$targetIndex"/>
                <xsl:with-param name="skipped" select="(())" />
                <xsl:with-param name="seq_name_to_avoid" select="$seq/name"/>
              </xsl:call-template>
            </xsl:for-each>
          </xsl:variable>
          <xsl:variable name="tailTerms" as="element()*" select="./*[position() &gt; 2]"/>
          <xsl:message>     hS branch 3 tailTerms are <xsl:apply-templates select="$tailTerms" mode="text"/> 
          </xsl:message>
          <xsl:message>     hS branch 3 number of matches: <xsl:value-of select="count($seq_sub_options)"/></xsl:message>
          <xsl:for-each select="$seq_sub_options">   
            <xsl:message>     hS branch 3 match name() is <xsl:value-of select="name()"/>
            </xsl:message>

            <head_substitution>
              <xsl:variable name="reqd_substitute" as="element(substitution)"> <!-- <changed to type substitition and wrapped -->
                <substitution>
                  <subject>
                    <substitute>
                      <xsl:copy-of select="$seq"/>
                      <xsl:for-each select="skipped/*">
                        <term>
                          <xsl:copy-of select="."/>
                        </term>
                      </xsl:for-each>
                    </substitute>
                  </subject>
                  <target/>
                </substitution>
              </xsl:variable>
              <xsl:message>      hS about to INSERT  seq <xsl:value-of select="$seq"/> </xsl:message>
              <!-- was
							<xsl:apply-templates select="substitution" mode="insert_subject_substitute">
						
								<xsl:with-param name="substitute" select="$reqd_substitute"/>
							</xsl:apply-templates>
														
							now -->
              <xsl:apply-templates select="substitution" mode="compose_substitutions">
                <xsl:with-param name="head_substitution" select="$reqd_substitute"/>
              </xsl:apply-templates>
              <tail>
                <xsl:copy-of select="$tailTerms"/>
              </tail>
              <numberOfTargetChildrenConsumed>
                <xsl:value-of select="count(skipped/*)+1"/>
              </numberOfTargetChildrenConsumed>
            </head_substitution>
          </xsl:for-each>
        </xsl:when>
        <xsl:when test="(./*[1][self::*:seq]) and count(./*) = 1">
          <xsl:message>      hS TAIL seq found</xsl:message>
          <xsl:variable name="seq" select="./*[1]" as="element()"/>
          <xsl:if test="count($targetTerm/*[position() &gt; $targetIndex -1])=1 
              or not(some $targetseq in $targetTerm/*[position() &gt; $targetIndex -1]/descendant-or-self::*:seq satisfies $targetseq/name = $seq/name)">
            <head_substitution>
              <substitution>
                <subject>
                  <substitute>     
                    <xsl:copy-of select="./*[1]"/>
                    <xsl:for-each select="$targetTerm/*[position() &gt; $targetIndex -1]">
                      <term>
                        <xsl:copy-of select="."/>
                      </term>
                    </xsl:for-each>
                  </substitute>
                </subject>
                <target>
                </target>
              </substitution>
              <tail>
              </tail>
              <numberOfTargetChildrenConsumed>
                <xsl:value-of select="count($targetTerm/*[position() &gt; $targetIndex -1])"/>
              </numberOfTargetChildrenConsumed>
            </head_substitution>
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message terminate="yes"> ***** hS A FOURTH CASE ERROR </xsl:message>
        </xsl:otherwise>
      </xsl:choose> 

      <xsl:if test="./*[1][self::*:seq] and count(./*) &gt; 2 and $targetTerm/*[$targetIndex]/following-sibling::*:seq">
        <xsl:message>      hS final case </xsl:message> 
        <xsl:variable name="indexofTargetSeq" 
            as="xs:integer"
            select = "count($targetTerm/*[$targetIndex]/following-sibling::*:seq[1]/preceding-sibling::*)+1"  
            />         

        <xsl:message>      hS indexofTargetSeq <xsl:value-of select="$indexofTargetSeq"/>
        </xsl:message> 
        <xsl:variable name="seq" as="element()"> <!-- actually a *:seq -->
          <xsl:copy-of select="./*[1]"/>
        </xsl:variable>      
        <xsl:for-each select="./*[position() &gt; 1]">
          <xsl:if test="count($targetTerm/*[(position() &gt; $targetIndex - 1)and (position() &lt; $indexofTargetSeq)]) = 1
              or not(some $targetseq in $targetTerm/*[position() &gt; $targetIndex -1 and (position() &lt; $indexofTargetSeq)]/descendant-or-self::*:seq satisfies $targetseq/name = $seq/name)" >
            <head_substitution>
              <substitution>   <!-- REMARK 21 Feb 2018 Could these forward and backward substitutes be interlinked - might one be applied to the other -->
                <!-- Could add defensive code to discover whether this is ever the case in practice -->
                <subject>
                  <substitute>
                    <xsl:copy-of select="$seq"/>
                    <xsl:for-each select ="$targetTerm/*[(position() &gt; $targetIndex - 1)and (position() &lt; $indexofTargetSeq)]">
                      <term>
                        <xsl:copy-of select="."/>
                      </term>
                    </xsl:for-each>
                  </substitute>
                </subject>
                <target>
                  <substitute>
                    <placefive/>
                    <xsl:copy-of select="$targetTerm/*[$targetIndex]/following-sibling::*:seq[1]"/>
                    <xsl:for-each select="self::* | preceding-sibling::*[count(preceding-sibling::*) &gt; 0]"> 
                      <term>
                        <xsl:copy-of select="."/>
                      </term>
                    </xsl:for-each>
                  </substitute>
                </target>
              </substitution>
              <tail>
                <xsl:copy-of  select="following-sibling::*"/>
              </tail>
              <numberOfTargetChildrenConsumed>
                <xsl:value-of select="$indexofTargetSeq - $targetIndex + 1 "/> <!-- changed from +1 to + 2 on 21 Feb 2018 WHYYYYYYY???????????? changed back to +1 on 12 March 2018-->
              </numberOfTargetChildrenConsumed>
            </head_substitution>
          </xsl:if>
        </xsl:for-each>
      </xsl:if>
    </xsl:variable>
    <!-- having gathered the results we will inspect then and apply post conditions before returning them -->
    <xsl:message>      hS head substitution entry number: <xsl:value-of select="$head_substitution_entry_number"/>
    </xsl:message>
    <xsl:message>      hS head substitution subject term: <xsl:apply-templates select="." mode="text"/>
    </xsl:message>
    <xsl:message>      hS head substitution  targetTerm:  <xsl:apply-templates select="$targetTerm" mode="text"/>
    </xsl:message>
    <xsl:message>      hS head substitution targetIndex:  <xsl:value-of select="$targetIndex"/>
    </xsl:message>
    <xsl:for-each select="$head_substitutions"> 
      <xsl:variable name="result_no" as="xs:integer" select="position()"/>
      <xsl:variable name="subjectTail_text" as="text()*">
        <xsl:apply-templates select="tail" mode="text"/>
      </xsl:variable>
      <xsl:message>     hS head substitution result number:<xsl:value-of select="$result_no"/> </xsl:message>
      <xsl:message>     hS countOfVariablesSubstituted:<xsl:value-of select="count(substitution/*/substitute)"/></xsl:message>
      <xsl:message>     hS countOfTargetTermsSubstitutedIntoOuter:<xsl:value-of select="count(substitution/*/substitute/term)"/></xsl:message>  
      <xsl:message>     hS numberOfTargetChildrenConsumed:<xsl:value-of select="numberOfTargetChildrenConsumed"/></xsl:message>
      <xsl:message>     hS subjectTail:<xsl:value-of select="$subjectTail_text"/></xsl:message>
      <xsl:variable name="traceback" as="element(gat:traceback)">
        <traceback>
          <head_substitution_entry_number><xsl:value-of select="$head_substitution_entry_number"/></head_substitution_entry_number>
          <subjectTerm><xsl:value-of select="$subjectTerm_text"/></subjectTerm>
          <targetTerm><xsl:value-of select="$targetTerm_text"/></targetTerm>
          <targetIndex><xsl:value-of select="$targetIndex"/></targetIndex>
          <result_number><xsl:value-of select="$result_no"/></result_number>
          <countOfVariablesSubstituted><xsl:value-of select="count(substitution/*/substitute/term)"/></countOfVariablesSubstituted>
          <countOfTargetTermsSubstitutedIntoOuter><xsl:value-of select="count(substitution/*/substitute/term)"/></countOfTargetTermsSubstitutedIntoOuter>
          <numberOfTargetChildrenConsumed><xsl:value-of select="numberOfTargetChildrenConsumed"/></numberOfTargetChildrenConsumed>
          <subjectTail><xsl:value-of select="$subjectTail_text"/></subjectTail>
        </traceback>
      </xsl:variable>
      <head_substitution>
        <!-- inject traceback for diagnostic purposes - can trace back to this place from the resulting substitutions -->
        <xsl:for-each select="substitution"> 
          <substitution>
            <xsl:copy-of select="$traceback"/>
            <substitution_text><xsl:apply-templates select="subject/substitute" mode="text"/></substitution_text>
            <xsl:message>   subject substitution <xsl:apply-templates select="subject/substitute" mode="text"/> </xsl:message>
            <xsl:message>   target substitution <xsl:apply-templates select="target/substitute" mode="text"/> </xsl:message>
            <targetSubstitution_text><xsl:apply-templates select="target/substitute" mode="text"/></targetSubstitution_text>
            <xsl:copy-of select="*"/>
          </substitution>
        </xsl:for-each>
        <xsl:copy-of select="*[not(self::substitution)]"/>
      </head_substitution>
    </xsl:for-each>
  </xsl:template>

  <!-- leading_subterm_specialisations
     ===============================
     Iterates through subterms of a target term commencing at the targetIndex
     to try and find those which the current term specialises to.
     Returns a sequence of zero, one or more <match> elements.
     Each <match> consists of a <skipped> having a sequence of skipped terms
     from the target and a <substitution>.
     The parameter seq_name_to_avoid is the name of a sequence variable 
     the algorithm must not consume target terms conatining this seq variable
     (otherwsie circuarity results)	 
     -->

  <xsl:template name="leading_subterm_specialisations">
    <xsl:param name="targetTerm" as="element()"/>
    <xsl:param name="targetIndex" as="xs:integer"/>
    <xsl:param name="skipped" as="element()*"/>
    <xsl:param name="seq_name_to_avoid"/>
    <xsl:message>         lSS subject term <xsl:apply-templates select="." mode="text"/>
    </xsl:message>
    <xsl:message>         lSS targetTerm  <xsl:apply-templates select="$targetTerm" mode="text"/>
    </xsl:message>
    <xsl:message>         lSS targetIndex  <xsl:value-of select="$targetIndex"/>
    </xsl:message>
    <xsl:message>         lSS skipped/name()<xsl:value-of select="$skipped/name()"/></xsl:message>

    <!-- The following condition needs to be beefed up to conditionally use -or-self NOT CLEAR that reqd info for test is present though 
          or is it length of skippped that we use ? -->
    <xsl:if test="not(some $targetseq in $targetTerm/*[$targetIndex]/descendant-or-self::*:seq satisfies $targetseq/name=$seq_name_to_avoid)"> 
      <xsl:variable name="headSpecialisations" as="element()*">   <!--  one or more (<substitution> or <INCOMPATIBLE/>) -->
        <xsl:call-template name="specialiseTerm">
          <xsl:with-param name="targetTerm" select="$targetTerm/*[$targetIndex]"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:if test="not($headSpecialisations[self::INCOMPATIBLE])">
        <xsl:for-each select="$headSpecialisations">
          <match>
            <skipped>
              <xsl:copy-of select="$skipped"/>
            </skipped>
            <xsl:if test="not(name()='substitution')">
              <xsl:message terminate="yes"> ****** Failed assert at 'substitutecheck' with <xsl:value-of select="name()"/>
              </xsl:message>
            </xsl:if>
            <xsl:copy-of select="."/>
          </match>
        </xsl:for-each>
      </xsl:if>
      <xsl:if test="$targetIndex &lt; count($targetTerm/*)">
        <xsl:message>         lSS About to recurse into leading_subterm_specialisations</xsl:message>
        <xsl:call-template name="leading_subterm_specialisations">
          <xsl:with-param name="targetTerm"  select="$targetTerm"/>
          <xsl:with-param name="targetIndex" select="$targetIndex + 1"/>
          <xsl:with-param name="skipped" select="($skipped,($targetTerm/*[$targetIndex]))"/>
          <xsl:with-param name="seq_name_to_avoid" select="$seq_name_to_avoid"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:if>
  </xsl:template>

</xsl:transform>