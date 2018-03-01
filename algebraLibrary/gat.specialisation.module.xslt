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
					<xsl:when test="self::*:var and $targetTerm[self::*:var] and ./name=$targetTerm/name">
						<xsl:message>new empty substitution for var </xsl:message>
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
				<!-- removed then included |self:seq previously 16 Mar 2017 -->
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
		<xsl:variable name="subject" as="element()*" select="."/> <!-- added for diagnostics -->
		<xsl:if test="not($targetTerm/*[$targetIndex]/name()='seq')"><xsl:message terminate="yes"/></xsl:if>
		<xsl:if test="not($targetIndex=1)"><xsl:message terminate="yes"/></xsl:if>
		<!-- full case   maybe reinstate with check that targetIndex is final? sounds right? -->
		<xsl:if test="$targetIndex = count($targetTerm/*)">
			<substitution>
				<subject>
				</subject>
				<target>
					<substitute>
						<placenine/>
						<xsl:copy-of select="$targetTerm/*[$targetIndex]"/>
						<xsl:for-each select="*">
							<term>
								<xsl:copy-of select="."/>
							</term>
						</xsl:for-each>
					</substitute>
				</target>
			</substitution>
		</xsl:if>
		<!--remainder cases -->
		<xsl:for-each select="*">
			<xsl:message>Loop <xsl:value-of select="position()"/> </xsl:message>
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
							<xsl:copy-of select="$targetTerm/*[$targetIndex]"/>
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
					<xsl:when test="$targetIndex+1 &lt; count($targetTerm/*)+1">   <!-- ************** Condition modified by addition of +1 to rhs 23 Feb 2018-->
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
							<xsl:message>pFATSBM proceeding</xsl:message>
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
			<xsl:if test="not(self::INCOMPATIBLE)">
				<!-- insert back mapping -->        
				<!-- was
        <xsl:for-each select="$continuation">
          <substitution>
            <reinforce/>
            <xsl:copy-of select="*"/>
            <xsl:copy-of select="$backMapping"/>
          </substitution>
        </xsl:for-each>
        now -->  

				<xsl:message>pFATSBM intmdt subject <xsl:apply-templates select="$subject" mode="text"/></xsl:message>
				<xsl:message> pFATSBM targetTerm <xsl:apply-templates select="$targetTerm" mode="text"/></xsl:message>
				<xsl:message> pFATSBM targetIndex <xsl:value-of select="$targetIndex"/></xsl:message>
				<xsl:message>Loop <xsl:value-of select="position()"/> </xsl:message>
				<xsl:message>count($subjectTail/*) <xsl:value-of select="count($subjectTail/*)"/> </xsl:message>
				<xsl:message>Number of tail_substitutions <xsl:value-of select="count($tail_substitutions)"/> </xsl:message>

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
		<!--
		<xsl:message>   sSTF targetIndex <xsl:value-of select="$targetIndex"/>
		</xsl:message>
		-->

		<xsl:variable name="headsubstitutions" as="element(head_substitution)*">
			<xsl:call-template name="head_substitutions">
				<xsl:with-param name="targetTerm" select="$targetTerm"/>
				<xsl:with-param name="targetIndex" select="$targetIndex"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:message>   sSTF Will now iterate through each of <xsl:value-of select="count($headsubstitutions/head_substitution)"/>
		</xsl:message>
		<xsl:for-each select="$headsubstitutions">

			<xsl:variable name="head_substitution" select="." as="element(head_substitution)"/>
			<xsl:if test="not($head_substitution/tail)">
				<xsl:message terminate="yes">   sSTF **** type error - tail assertion fails </xsl:message>
			</xsl:if>
			<xsl:variable name="numberOfTargetChildrenConsumed" as="xs:integer" select="numberOfTargetChildrenConsumed"/>

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
					<xsl:choose>
						<xsl:when test="($targetIndex + $numberOfTargetChildrenConsumed &lt; count($targetTerm/* ) + 1)
							or ( count($head_substitution/tail/*) = 1 and  $head_substitution/tail/*[self::*:seq]  )"> 
							<xsl:variable name="tailspecialised" as="element(tail)">
								<xsl:for-each select="$head_substitution/tail"> 
									<xsl:message>   sSTF substitution call one "<xsl:copy-of select="$head_substitution/substitution"/>"</xsl:message>
									<xsl:apply-templates select="." mode="substitution">
										<xsl:with-param name="substitutions" select="$head_substitution/substitution"/>  <!-- was just subject -->
									</xsl:apply-templates>
								</xsl:for-each>
							</xsl:variable>
							<xsl:message>    sSTF tail specialised <xsl:apply-templates select="$tailspecialised/*" mode="text"/>
							</xsl:message>

							<xsl:variable name="targetTermSpecialised" as="element()">
								<xsl:message>   sSTF about to sub into target </xsl:message>
								<xsl:message>   sSTF substitution call two</xsl:message>
								<xsl:apply-templates select="$targetTerm" mode="substitution">
									<xsl:with-param name="substitutions" select="$head_substitution/substitution"/> <!-- was just target -->
								</xsl:apply-templates>
								<xsl:message>   sSTF finished substitution call two</xsl:message>
								<!-- end new -->
							</xsl:variable> 

							<xsl:variable name="tail_substitutions" as="element(substitution)*">
								<xsl:for-each select="$tailspecialised">
									<xsl:call-template name="specialiseSubTermsFrom">   
										<xsl:with-param name="targetTerm" select="$targetTermSpecialised"/>  <!-- 13 April 2017 -->
										<xsl:with-param name="targetIndex" select="$targetIndex+$numberOfTargetChildrenConsumed"/>
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
              but now -->

							<xsl:message>   sSTF call compose of<xsl:apply-templates  select="$tail_substitutions" mode="text"/>
								and <xsl:apply-templates  select="$head_substitution/substitution" mode="text"/>
							</xsl:message>
							<xsl:apply-templates select="$tail_substitutions" mode="compose_substitutions">
								<xsl:with-param name="head_substitution" select="$head_substitution/substitution"/>
							</xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise>
							<xsl:message>   sSTF SHOULD WE BE WORRIED?</xsl:message>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:message terminate="yes">***** UNexpectedly got HERE </xsl:message>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
		<xsl:message>   sSTF exiting sSTF</xsl:message>
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
					<xsl:message>      hS branch 2 </xsl:message>     
					<xsl:for-each select="./*">
						<head_substitution>
							<substitution>
								<subject>
								</subject>
								<target>
									<substitute>
										<placethree/>
										<xsl:copy-of select="$targetTerm/*[$targetIndex]"/>
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

					<xsl:for-each select="$seq_sub_options">   
						<xsl:message>     hS branch match name() is <xsl:value-of select="name()"/>
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
				</xsl:when>
				<xsl:otherwise>
					<xsl:message terminate="yes"> ***** hS A FOURTH CASE ERROR </xsl:message>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:message>      hS pre final case <xsl:copy-of select="$targetTerm/*[$targetIndex]"/>  
				then  <xsl:copy-of select="$targetTerm/*[$targetIndex]/following-sibling::*:seq"/>
			</xsl:message> 
			<xsl:if test="./*[1][self::*:seq] and count(./*) &gt; 2 and $targetTerm/*[$targetIndex]/following-sibling::*:seq">
				<xsl:message>      hS final case</xsl:message> 
				<xsl:variable name="indexofTargetSeq" 
						as="xs:integer"
						select = "count($targetTerm/*[$targetIndex]/following-sibling::*:seq[1]/preceding-sibling::*)+1"  
						/>         

				<xsl:message>      hS indexofTargetSeq <xsl:value-of select="$indexofTargetSeq"/>
				</xsl:message> 
				<xsl:variable name="dotseq" as="element()"> <!-- actually a *:seq -->
					<xsl:copy-of select="./*[1]"/>
				</xsl:variable>      
				<xsl:for-each select="./*[position() &gt; 1]">
					<head_substitution>
						<substitution>   <!-- REMARK 21 Feb 2018 Could these forward and backward substitutes be interlinked - might one be applied to the other -->
							<!-- Could add defensive code to discover whether this is ever the case in practice -->
							<subject>
								<substitute>
									<xsl:copy-of select="$dotseq"/>
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
							<xsl:value-of select="$indexofTargetSeq - $targetIndex + 2 "/> <!-- changed from +1 to + 2 on 21 Feb 2018 -->
						</numberOfTargetChildrenConsumed>
					</head_substitution>
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
			<xsl:variable name="targetTail_text" as="text()*">
				<xsl:apply-templates select="tail" mode="text"/>
			</xsl:variable>
			<xsl:message>     hS head substitution result number:<xsl:value-of select="$result_no"/> </xsl:message>
			<xsl:message>     hS countOfVariablesSubstituted:<xsl:value-of select="count(substitution/*/substitute)"/></xsl:message>
			<xsl:message>     hS countOfTargetTermsSubstitutedIntoOuter:<xsl:value-of select="count(substitution/*/substitute/term)"/></xsl:message>  
			<xsl:message>     hS numberOfTargetChildrenConsumed:<xsl:value-of select="numberOfTargetChildrenConsumed"/></xsl:message>
			<xsl:message>     hS targetTail:<xsl:value-of select="$targetTail_text"/></xsl:message>
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
					<targetTail><xsl:value-of select="$targetTail_text"/></targetTail>
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
		<xsl:if test="not(some $targetseq in $targetTerm/*[$targetIndex]/descendant::*:seq satisfies $targetseq/name=$seq_name_to_avoid)"> 
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