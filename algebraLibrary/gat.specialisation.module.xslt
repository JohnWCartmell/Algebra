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
                                       <gat:name>xxx</gat:name>
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
    <xsl:message>specialiseTerm <xsl:apply-templates select="." mode="text"/>
    </xsl:message>
    <xsl:message>specialiseTerm/name() <xsl:value-of select="name()" />
    </xsl:message>
    <xsl:message> targetTerm <xsl:apply-templates select="$targetTerm" mode="text"/>
    </xsl:message>
    <xsl:message> targetTerm/name() <xsl:value-of select="$targetTerm/name()" />
    </xsl:message>
    <xsl:choose>
      <!-- 15 Feb 2017 switched order of these when branches -->
      <!-- to avoid proof that f=g -->
      <xsl:when test=".[self::*:var|self::*:seq]">
        <!--  BELIEVE THAT WE NEED THE self::seq CASE for engulfing target seq-->
        <substitution>
          <substitute>
            <xsl:copy>
              <xsl:apply-templates mode="copy"/>
            </xsl:copy>
            <term>
              <xsl:copy-of select="$targetTerm"/>
            </term>
          </substitute>
        </substitution>
      </xsl:when>
      <xsl:when test="$targetTerm[self::*:var]">
        <!-- removed then included |self:seq previously 16 Mar 2017 -->
        <substitution>
          <targetSubstitute>
            <placeone/>
            <xsl:copy-of select="$targetTerm"/>
            <term>
              <xsl:copy-of select="."/>
            </term>
          </targetSubstitute>
        </substitution>
      </xsl:when>
      <xsl:when test="name(.) != name($targetTerm)">
        <INCOMPATIBLE/>
      </xsl:when>
      <xsl:otherwise> 
        <!-- descend -->
        <xsl:choose>
          <xsl:when test="count(./*)=0"> 
            <xsl:choose>
              <xsl:when test="count($targetTerm/*)=0">   <!-- add not seq ??? -->
                <substitution/>
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
            <xsl:call-template name="specialiseSubTermsFrom">
              <xsl:with-param name="targetTerm" select="$targetTerm"/>
              <xsl:with-param name="targetIndex" select="1"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- proceedFromAllTargetSequenceBackMappings -->
  <xsl:template name="proceedFromAllTargetSequenceBackMappings">
    <xsl:param name="targetTerm" as="element()"/>
    <xsl:param name="targetIndex" as="xs:integer" />
    <xsl:message>pFATSBM dotTerm <xsl:apply-templates select="." mode="text"/>
    </xsl:message>
    <xsl:message> pFATSBM targetTerm <xsl:apply-templates select="$targetTerm" mode="text"/>
    </xsl:message>
    <!-- full case   maybe reinstate with check that targetIndex is final? sounds right? -->
    <xsl:if test="$targetIndex = count($targetTerm/*)">
      <substitution>
        <targetSubstitute>
          <placenine/>
          <xsl:copy-of select="$targetTerm/*[$targetIndex]"/>
          <xsl:for-each select="*">
            <term>
              <xsl:copy-of select="."/>
            </term>
          </xsl:for-each>
        </targetSubstitute>
      </substitution>
    </xsl:if>
    <!--remainder cases -->
    <xsl:for-each select="*">
      <xsl:variable name="tail">
        <tail> 
          <xsl:copy-of  select="self::*|following-sibling::*"/>
        </tail>
      </xsl:variable>
      <xsl:variable name="backMapping">
        <targetSubstitute>
          <place2/>
          <xsl:copy-of select="$targetTerm/*[$targetIndex]"/>
          <xsl:for-each select="preceding-sibling::*">
            <term>
              <xsl:copy-of select="."/>
            </term>
          </xsl:for-each>
        </targetSubstitute>
      </xsl:variable>
      <xsl:variable name="continuation">
        <xsl:choose>
          <xsl:when test="$targetIndex+1 &lt; count($targetTerm/*)">
            <xsl:for-each select="$tail/*">
              <xsl:message>pFATSBM proceeding</xsl:message>
              <xsl:call-template name="specialiseSubTermsFrom">
                <xsl:with-param name="targetTerm" select="$targetTerm"/>
                <xsl:with-param name="targetIndex" select="$targetIndex+1"/>
              </xsl:call-template> 
            </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>
            <!-- check if tail is empty? -->
            <xsl:if test="count($tail/*) = 0">
              <!-- late addition -->
              <substitution>
              </substitution>
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:if test="not(self::INCOMPATIBLE)">
        <!-- insert back mapping -->
        <xsl:for-each select="$continuation/substitution">
          <substitution>
            <reinforce/>
            <xsl:copy-of select="*"/>
            <xsl:copy-of select="$backMapping/targetSubstitute"/>
          </substitution>
        </xsl:for-each>
      </xsl:if>
    </xsl:for-each>
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
    <xsl:message>   sSTF specialise subterms from outer: <xsl:apply-templates select="." mode="text"/>
    </xsl:message>
    <xsl:message>   sSTF outer tail /name()<xsl:value-of select="name()" />
    </xsl:message>
    <xsl:message>   sSTF target <xsl:apply-templates select="$targetTerm" mode="text"/>
    </xsl:message>
    <xsl:message>   sSTF target /name() <xsl:value-of select="$targetTerm/name()" />
    </xsl:message>
       <xsl:message>   sSTF target/* /name() <xsl:value-of select="$targetTerm/*/name()" />
    </xsl:message>
    <xsl:message>   sSTF targetIndex <xsl:value-of select="$targetIndex"/>
    </xsl:message>

    <xsl:variable name="headsubstitutions">
      <xsl:call-template name="head_substitutions">
        <xsl:with-param name="targetTerm" select="$targetTerm"/>
        <xsl:with-param name="targetIndex" select="$targetIndex"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:message>sSTF Will now iterate through each of <xsl:value-of select="count($headsubstitutions/head_substitution)"/>
    </xsl:message>
    <xsl:for-each select="$headsubstitutions/head_substitution">
      <xsl:message> sSTF length of head substitution substitutions <xsl:value-of select="count(./substitution/*)"/>
      </xsl:message>
      <xsl:message> sSTF length of head substitution tail <xsl:value-of select="count(./tail/*)"/>
      </xsl:message>
      <xsl:variable name="head_substitution" select="."/>
      <xsl:if test="not($head_substitution/tail)">
        <xsl:message terminate="yes"> sSTF **** type error - tail assertion fails </xsl:message>
      </xsl:if>
      <xsl:variable name="numberOfTargetChildrenConsumed" as="xs:integer" select="numberOfTargetChildrenConsumed"/>
      <xsl:message>sSTF numberOfTargetChildrenConsumed <xsl:value-of select="$numberOfTargetChildrenConsumed"/>
      </xsl:message>
      <xsl:choose>
        <xsl:when test="count($head_substitution/tail/*) = 0">
          <!-- BANBURY -->
          <xsl:message> sSTF BANBURY: targetIndex <xsl:value-of select="$targetIndex"/> 
            target child count <xsl:value-of select="count($targetTerm/*)"/>
          </xsl:message>

          <xsl:if test="not($head_substitution/substitution[self::substitution])">
            <xsl:message terminate="yes"> ***** return type assertion fails at BANBURY </xsl:message>
          </xsl:if>
          <xsl:choose>
            <xsl:when test="($targetIndex + $numberOfTargetChildrenConsumed &gt; count($targetTerm/* ))">
              <xsl:message> sSTF finished consumption branch one</xsl:message>
              <xsl:copy-of select="$head_substitution/substitution"/>  
            </xsl:when>
            <xsl:when test="($targetIndex + $numberOfTargetChildrenConsumed + 1 &gt; count($targetTerm/* ) )
                and ($targetTerm/*[$targetIndex + $numberOfTargetChildrenConsumed][self::*:seq])
                ">
              <xsl:message> sSTF finished consumption branch two - insert targetSubstitution</xsl:message>
              <xsl:for-each select="$head_substitution/substitution">  <!-- added 21 Feb 2018 -->
                <substitution>
                  <xsl:copy-of select="*"/>
                  <targetSubstitute>
                       <xsl:copy-of select="$targetTerm/*[$targetIndex + $numberOfTargetChildrenConsumed]"/>
                       <!-- empty set of terms -->
                  </targetSubstitute>
                </substitution>
              </xsl:for-each>            
            </xsl:when>
          </xsl:choose>
        </xsl:when >
        <xsl:when test="count($head_substitution/tail/*) &gt; 0">  
          <xsl:choose>
            <xsl:when test="($targetIndex + $numberOfTargetChildrenConsumed &lt; count($targetTerm/* ) + 1)
                or ( count($head_substitution/tail/*) = 1 and  $head_substitution/tail/*[self::*:seq]  )"> 
              <!-- xxxxxxx  -->
              <xsl:variable name="tailspecialised">
                <xsl:for-each select="$head_substitution/tail"> 
                  <xsl:apply-templates mode="substitution">
                    <xsl:with-param name="substitutions" select="$head_substitution/substitution/*"/>
                    <!-- check this -->
                  </xsl:apply-templates>
                </xsl:for-each>
              </xsl:variable>
              <xsl:message> sSTF tail specialised <xsl:apply-templates select="$tailspecialised/*" mode="text"/>
              </xsl:message>

              <xsl:variable name="targetTermSpecialised" as="element()">
                <xsl:for-each select="$targetTerm">  <!-- 21 Feb 2018 Remove /* -->
                  <xsl:call-template name="applyTargetSubstitutions">
                    <xsl:with-param name="substitution" select="$head_substitution/substitution"/>  <!-- 13 April 2017 ??? add a * ??-->
                  </xsl:call-template>
                </xsl:for-each>
              </xsl:variable>

              <xsl:variable name="tail_substitutions">
                <xsl:for-each select="$tailspecialised">
                  <xsl:call-template name="specialiseSubTermsFrom">   
                    <xsl:with-param name="targetTerm" select="$targetTermSpecialised"/>  <!-- 13 April 2017 -->
                    <xsl:with-param name="targetIndex" select="$targetIndex+$numberOfTargetChildrenConsumed"/>
                  </xsl:call-template>
                </xsl:for-each>
              </xsl:variable>
              <xsl:for-each select="$tail_substitutions/*">
                <xsl:if test="not(self::substitution)">
                  <xsl:message terminate="yes"> ***** type assertion substitution fails on tail </xsl:message>
                </xsl:if>
                <substitution>               <!-- REMARK 22 Feb 2018 Shouldn't the tail substitution be applied to the head substitutions in a compose substitutions operation? -->
                  <xsl:copy-of select="$head_substitution/substitution/*"/>
                  <xsl:copy-of select="./*"/>
                </substitution>
              </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
              <xsl:message>SHOULD WE BE WORRIED?</xsl:message>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message terminate="yes">***** UNexpectedly got HERE </xsl:message>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
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
    <xsl:message>  hS  head_substitution entry number: <xsl:value-of select="$head_substitution_entry_number"/>
    </xsl:message>
    <xsl:message>  hS  subjectTerm   <xsl:apply-templates select="." mode="text"/>
    </xsl:message>
    <xsl:message>  hS  targetTerm  <xsl:apply-templates select="$targetTerm" mode="text"/>
    </xsl:message>
    <xsl:message>  hS targetIndex  <xsl:value-of select="$targetIndex"/>
    </xsl:message>
    <xsl:variable name="head_substitutions" as="element(head_substitution)*">
      <xsl:choose>
        <xsl:when test="not(./*[1][self::*:seq]) and not($targetTerm/*[$targetIndex][self::*:seq])">
          <xsl:message> hS branch 1 </xsl:message>
          <!-- source is not  target is not seq -->
          <xsl:variable name="substitutions">
            <xsl:for-each select="./*[1]">  
              <xsl:call-template name="specialiseTerm">
                <xsl:with-param name="targetTerm" select="$targetTerm/*[$targetIndex]"/>
              </xsl:call-template>
            </xsl:for-each>
          </xsl:variable>
          <xsl:variable name="tail" select="./*[position() &gt; 1]"/>
          <xsl:message>  hS branch 1 tail is <xsl:apply-templates select="$tail" mode="text"/> 
          </xsl:message>
          <xsl:for-each select="$substitutions/*">
            <xsl:if test="not(self::INCOMPATIBLE)">
              <head_substitution>
                <xsl:message>  hS name of DOT in constructor of head substitution (require 'substitution') is <xsl:value-of select="name()"/>
                </xsl:message>
                <xsl:copy-of select="."/>
                <tail>
                  <xsl:copy-of select="$tail"/>
                </tail>
                <numberOfTargetChildrenConsumed>1</numberOfTargetChildrenConsumed>
              </head_substitution>
            </xsl:if>
          </xsl:for-each>
        </xsl:when>

        <xsl:when test="not(./*[1][self::*:seq]) and $targetTerm/*[$targetIndex][self::*:seq]">
          <xsl:message> hS branch 2 </xsl:message>     
          <xsl:for-each select="./*">
            <head_substitution>
              <substitution>
                <targetSubstitute>
                  <placethree/>
                  <xsl:copy-of select="$targetTerm/*[$targetIndex]"/>
                  <xsl:for-each select="self::* | preceding-sibling::*">
                    <term>
                      <xsl:copy-of select="."/>
                    </term>
                  </xsl:for-each>
                </targetSubstitute>
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
          <xsl:message> Hs branch 3 </xsl:message>

          <xsl:variable name="seq_sub_options">
            <xsl:message> hS branch 3 about to call leading_subterm_specialisations</xsl:message>
            <xsl:for-each select="./*[2]">
              <xsl:call-template name="leading_subterm_specialisations">
                <xsl:with-param name="targetTerm" select="$targetTerm"/>
                <xsl:with-param name="targetIndex" select="$targetIndex"/>
                <xsl:with-param name="skipped" select="(())" />
              </xsl:call-template>
            </xsl:for-each>
          </xsl:variable>
          <xsl:variable name="tail" select="./*[position() &gt; 2]"/>
          <xsl:message> hS branch 3 tail is <xsl:apply-templates select="$tail" mode="text"/> 
          </xsl:message>
          <xsl:variable name="seq" select="./*[1]"/>
          <xsl:for-each select="$seq_sub_options/*">
            <xsl:message> hS branch match name() is <xsl:value-of select="name()"/>
            </xsl:message>
            <head_substitution>
              <substitution>
                <substitute>     
                  <xsl:copy-of select="$seq"/>
                  <xsl:for-each select="skipped/*">
                    <term>
                      <xsl:copy-of select="."/>
                    </term>
                  </xsl:for-each>
                </substitute>
                <xsl:copy-of select="./substitution/*"/>  
                                <!-- REMARK 21 Feb 2018 - shouldn't this substitution have additional substitute applied to it in a compose substitutions operation? -->
              </substitution>
              <tail>
                <xsl:copy-of select="$tail"/>
              </tail>
              <numberOfTargetChildrenConsumed>
                <xsl:value-of select="count(skipped/*)+1"/>
              </numberOfTargetChildrenConsumed>
            </head_substitution>
          </xsl:for-each>
        </xsl:when>
        <xsl:when test="(./*[1][self::*:seq]) and count(./*) = 1">
          <xsl:message>hS TAIL seq found</xsl:message>
          <head_substitution>
            <substitution>
              <substitute>     
                <xsl:copy-of select="./*[1]"/>
                <xsl:for-each select="$targetTerm/*[position() &gt; $targetIndex -1]">
                  <term>
                    <xsl:copy-of select="."/>
                  </term>
                </xsl:for-each>
              </substitute>
            </substitution>
            <tail>
            </tail>
            <numberOfTargetChildrenConsumed>
              <xsl:value-of select="count($targetTerm/*[position() &gt; $targetIndex -1])"/>
            </numberOfTargetChildrenConsumed>
          </head_substitution>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message terminate="yes"> ***** hS A FOURTH CASE ERROR </xsl:message>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:message> hS pre final case <xsl:copy-of select="$targetTerm/*[$targetIndex]"/>  
        then  <xsl:copy-of select="$targetTerm/*[$targetIndex]/following-sibling::*:seq"/>
      </xsl:message> 
      <xsl:if test="./*[1][self::*:seq] and count(./*) &gt; 2 and $targetTerm/*[$targetIndex]/following-sibling::*:seq">
        <xsl:message> hS final case</xsl:message> 
        <xsl:variable name="indexofTargetSeq" 
            as="xs:integer"
            select = "count($targetTerm/*[$targetIndex]/following-sibling::*:seq[1]/preceding-sibling::*)+1"  
            />         

        <xsl:message> hS indexofTargetSeq <xsl:value-of select="$indexofTargetSeq"/>
        </xsl:message> 
        <xsl:variable name="dotseq">
          <xsl:copy-of select="./*[1]"/>
        </xsl:variable>      
        <xsl:for-each select="./*[position() &gt; 1]">
          <head_substitution>
            <substitution>   <!-- REMARK 21 Feb 2018 Could these forward and backward substitutes be interlinked - might one be applied to the other -->
                             <!-- Could add defensive code to discover whether this is ever the case in practice -->
              <substitute>
                <xsl:copy-of select="$dotseq"/>
                <xsl:for-each select ="$targetTerm/*[(position() &gt; $targetIndex - 1)and (position() &lt; $indexofTargetSeq)]">
                  <term>
                    <xsl:copy-of select="."/>
                  </term>
                </xsl:for-each>
              </substitute>
              <targetSubstitute>
                <placefive/>
                <xsl:copy-of select="$targetTerm/*[$targetIndex]/following-sibling::*:seq[1]"/>
                <xsl:for-each select="self::* | preceding-sibling::*[count(preceding-sibling::*) &gt; 0]"> 
                  <term>
                    <xsl:copy-of select="."/>
                  </term>
                </xsl:for-each>
              </targetSubstitute>
            </substitution>
            <tail>
              <xsl:copy-of  select="following-sibling::*"/>
            </tail>
            <numberOfTargetChildrenConsumed>
              <xsl:value-of select="$indexofTargetSeq - $targetIndex + 2 "/> <!-- changed from +1 to + 2 on 21 Feb 2018 -->
            </numberOfTargetChildrenConsumed>
          </head_substitution>
        </xsl:for-each>
      </xsl:if>
    </xsl:variable>
    <!-- having gathered the results we will inspect then and apply post conditions before returning them -->
    <xsl:message>head substitution entry number: <xsl:value-of select="$head_substitution_entry_number"/>
    </xsl:message>
    <xsl:message>head substitution subject term: <xsl:apply-templates select="." mode="text"/>
    </xsl:message>
    <xsl:message>head substitution  targetTerm:  <xsl:apply-templates select="$targetTerm" mode="text"/>
    </xsl:message>
    <xsl:message>head substitution targetIndex:  <xsl:value-of select="$targetIndex"/>
    </xsl:message>
    <xsl:for-each select="$head_substitutions"> 
      <xsl:variable name="result_no" select="position()"/>
      <xsl:variable name="targetTail_text">
        <xsl:apply-templates select="tail" mode="text"/>
      </xsl:variable>
      <xsl:message>   head substitution result number:<xsl:value-of select="$result_no"/> </xsl:message>
      <xsl:message>   countOfVariablesSubstituted:<xsl:value-of select="count(substitution/substitute)"/></xsl:message>
      <xsl:message>   countOfTargetTermsSubstitutedIntoOuter:<xsl:value-of select="count(substitution/substitute/term)"/></xsl:message>  
      <xsl:message>   numberOfTargetChildrenConsumed:<xsl:value-of select="numberOfTargetChildrenConsumed"/></xsl:message>
      <xsl:message>   targetTail:<xsl:value-of select="$targetTail_text"/></xsl:message>
      <xsl:variable name="traceback" as="element(gat:traceback)">
        <traceback>
          <head_substitution_entry_number><xsl:value-of select="$head_substitution_entry_number"/></head_substitution_entry_number>
          <subjectTerm><xsl:value-of select="$subjectTerm_text"/></subjectTerm>
          <targetTerm><xsl:value-of select="$targetTerm_text"/></targetTerm>
          <targetIndex><xsl:value-of select="$targetIndex"/></targetIndex>
          <result_number><xsl:value-of select="$result_no"/></result_number>
          <countOfVariablesSubstituted><xsl:value-of select="count(substitution/substitute/term)"/></countOfVariablesSubstituted>
          <countOfTargetTermsSubstitutedIntoOuter><xsl:value-of select="count(substitution/substitute/term)"/></countOfTargetTermsSubstitutedIntoOuter>
          <numberOfTargetChildrenConsumed><xsl:value-of select="numberOfTargetChildrenConsumed"/></numberOfTargetChildrenConsumed>
          <targetTail><xsl:value-of select="$targetTail_text"/></targetTail>
        </traceback>
      </xsl:variable>
      <head_substitution>
        <xsl:for-each select="substitution">
          <substitution>
            <xsl:copy-of select="$traceback"/>
            <substitution_text><xsl:apply-templates select="substitute" mode="text"/></substitution_text>
            <targetSubstitution_text><xsl:apply-templates select="targetSubstitute" mode="text"/></targetSubstitution_text>
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
     -->

  <xsl:template name="leading_subterm_specialisations">
    <xsl:param name="targetTerm" as="element()"/>
    <xsl:param name="targetIndex" as="xs:integer"/>
    <xsl:param name="skipped" as="element()*"/>

    <xsl:message>lss Dot  <xsl:apply-templates select="." mode="text"/>
    </xsl:message>
    <xsl:message>lss targetTerm  <xsl:apply-templates select="$targetTerm" mode="text"/>
    </xsl:message>
    <xsl:message>lss targetIndex  <xsl:value-of select="$targetIndex"/>
    </xsl:message>
    <xsl:message>skipped/name()<xsl:value-of select="$skipped/name()"/></xsl:message>

    <xsl:variable name="headSpecialisations">   
      <xsl:call-template name="specialiseTerm">
        <xsl:with-param name="targetTerm" select="$targetTerm/*[$targetIndex]"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:if test="not($headSpecialisations/*[self::INCOMPATIBLE])">
      <xsl:for-each select="$headSpecialisations/*">
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
    <xsl:message> lss $targetIndex LT count(.*) ?? <xsl:value-of select="$targetIndex"/> ?? <xsl:value-of select="count($targetTerm/*)"/>
    </xsl:message> 
    <xsl:if test="$targetIndex &lt; count($targetTerm/*)">
      <xsl:message>lss About to recurse into leading_subterm_specialisations</xsl:message>
      <xsl:call-template name="leading_subterm_specialisations">
        <xsl:with-param name="targetTerm"  select="$targetTerm"/>
        <xsl:with-param name="targetIndex" select="$targetIndex + 1"/>
        <xsl:with-param name="skipped" select="($skipped,($targetTerm/*[$targetIndex]))"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

</xsl:transform>