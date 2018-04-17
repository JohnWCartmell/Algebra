<xsl:transform version="2.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:gat              ="http://www.entitymodelling.org/theory/generalisedalgebraictheory"
		xpath-default-namespace="http://www.entitymodelling.org/theory/generalisedalgebraictheory"	   
		xmlns="http://www.entitymodelling.org/theory/generalisedalgebraictheory"
		exclude-result-prefixes="xs">

	<!-- The entry point to these templates is "unifyTerms". -->


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
	<!--  16 April 2018 Rename specialiseTerm to unifyTerms. 
                       Make subjectTerm an explicit param (no longer context node)
                       Move logic for mapping final targetsequence back to empty sequence
					   Return zero results if incompatible rather than explicit <INCOMPATIBLE/>.
    -->					   

	<!-- 
     unifyTerms 
     ==============
     Find a substitutional instance of a given term that
     matches a substitutional instance of a target term.
     Returns zero, one or more <substitution> elements.
     A <substitution> element contains a <subject> and a <target> - each containing
	 zero, one or more <substitute> elements each 
     specifying a variable <var>  and a <term> to be substituted for it
     or a <seq> and zero, one or more <term> elements to be substituted for it.          
     -->

	<!-- Call Graph -->
	<!-- "unifyTerms"            calls "unifySubtermSequences"
       "unifySubtermSequences"      calls "headUnification"
                                     and   "unifySubtermSequences"
                                     and   "applyTargetSubstitutions"
       "headUnification"          calls "unifyTerms"
                                                 
     -->

	<xsl:template name="unifyTerms">
		<xsl:param name="subjectTerm" as="element()"/>
		<xsl:param name="targetTerm" as="element()"/>
		<!--<xsl:variable name="subjectTerm" as="element()" select="."/>-->
		<xsl:message>unifyTerms subjectTerm: <xsl:apply-templates select="$subjectTerm" mode="text"/>
		</xsl:message>
		<xsl:message>unifyTerms  targetTerm: <xsl:apply-templates select="$targetTerm" mode="text"/>
		</xsl:message>
		<xsl:if test="$subjectTerm[self::*:seq]"><xsl:message terminate="yes">Assertion failure: unifyTerms called with seq as subject</xsl:message></xsl:if>
		<xsl:choose>
			<!-- 15 Feb 2017 switched order of these when branches -->
			<!-- to avoid proof that f=g -->
			<xsl:when test="$subjectTerm[self::*:var]">
				<!--  BELIEVE THAT WE NEED THE self::seq CASE for engulfing target seq-->
				<xsl:choose>
					<xsl:when test="$targetTerm[self::*:var] and $subjectTerm/name=$targetTerm/name">
						<xsl:message>new empty substitution for var </xsl:message>
						<substitution>
							<subject/>
							<target/>
						</substitution>
					</xsl:when>
					<xsl:when test="$targetTerm[self::*:seq] and $subjectTerm/name=$targetTerm/name">
						<xsl:message terminate="yes">new empty substitution for seq </xsl:message> 
						<!-- terminate added after code inspection 15 March 2018 -->
						<substitution>
							<subject/>
							<target/>
						</substitution>
					</xsl:when>
					<xsl:otherwise>
						<xsl:choose>
							<xsl:when test="$subjectTerm[self::*:var] and (some $targetvar in $targetTerm/descendant::*:var satisfies $targetvar/name=$subjectTerm/name)">
								<!--<INCOMPATIBLE/>-->
							</xsl:when>
							<xsl:when test="$subjectTerm[self::*:seq] and (some $targetseq in $targetTerm/descendant::*:seq satisfies $targetseq/name=$subjectTerm/name)">
								<xsl:message terminate="yes">OUT OF SPEC </xsl:message>
								<!--<INCOMPATIBLE/>-->
							</xsl:when>
							<xsl:otherwise>
								<substitution>
									<subject>
										<substitute>
											<xsl:copy-of select="$subjectTerm"/>
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
					<xsl:when test="some $subjectvar in $subjectTerm/descendant::* satisfies $subjectvar/name = $targetTerm/name">
						<!--<INCOMPATIBLE/>-->
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
										<xsl:copy-of select="$subjectTerm"/>
									</term>
								</substitute>
							</target>
						</substitution>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$targetTerm[self::*:seq]">  <!-- added to make logic clear -->
				<!--<INCOMPATIBLE/> -->
			</xsl:when>	
			<xsl:when test="(name($subjectTerm) != name($targetTerm)) "> 
				<!--<INCOMPATIBLE/>-->
			</xsl:when>
			<xsl:otherwise> 
				<!-- descend -->
				<xsl:choose>
					<xsl:when test="count($subjectTerm/*)=0 "> <!-- zero subterms --> 
						<xsl:choose>
							<xsl:when test="count($targetTerm/*)=0">   
								<substitution><subject/><target/></substitution>
							</xsl:when>
							<xsl:otherwise>
								<!--<INCOMPATIBLE/>-->
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="count($targetTerm/*)=0"> <!-- if get here then  count(./*) != 0 -->
						<!--<INCOMPATIBLE/>-->
					</xsl:when>
					<xsl:otherwise> 
						<xsl:message>unifyTerms to unifySubtermSequences</xsl:message>
						<xsl:call-template name="unifySubtermSequences">
							<xsl:with-param name="subjectTerm" select="$subjectTerm"/>
							<xsl:with-param name="targetTerm" select="$targetTerm"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:message>Exit unifyTerms</xsl:message>
	</xsl:template>


	<!-- unifySubtermSequences
       ======================
       Iterate along subterms of a given term establishing 
       and appplying successive substitutions to unify 
       each subterm to match a correspondingly positioned subterm 
       of a target term.
       Returns zero, one or more <substitution> elements.
  -->
	<xsl:template name="unifySubtermSequences">
		<xsl:param name="subjectTerm" as="element()"/>
		<xsl:param name="targetTerm" as="element()"/>
		<xsl:message>   sSTF specialise subterms from subject: <xsl:apply-templates select="$subjectTerm" mode="text"/>
		</xsl:message>
		<xsl:message>   sSTF                        to target: <xsl:apply-templates select="$targetTerm" mode="text"/>
		</xsl:message>

		<xsl:variable name="headsubstitutions" as="element(head_substitution)*">
			<xsl:call-template name="headUnification">
				<xsl:with-param name="subjectTerm" select="$subjectTerm"/>
				<xsl:with-param name="targetTerm" select="$targetTerm"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:message>   sSTF Will now iterate through each of <xsl:value-of select="count($headsubstitutions)"/>
		</xsl:message>
		<xsl:for-each select="$headsubstitutions">
			<xsl:variable name="head_substitution" select="." as="element(head_substitution)"/>
			<xsl:message>   sSFT iteration               subjectTerm <xsl:apply-templates select="$subjectTerm" mode="text"/> </xsl:message>
			<xsl:message>                                targetTerm <xsl:apply-templates select="$targetTerm" mode="text"/> </xsl:message>
			<xsl:message>                                substitution subject <xsl:apply-templates select="$head_substitution/substitution/subject" mode="text"/> </xsl:message>
			<xsl:message>                                substitution target <xsl:apply-templates select="$head_substitution/substitution/target" mode="text"/> </xsl:message>

			<xsl:if test="not($head_substitution/subjectTail)">
				<xsl:message terminate="yes">   sSTF **** type error - subjectTail assertion fails </xsl:message>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="(count($head_substitution/subjectTail/*) = 0)
				                   and (count($head_substitution/targetTail/*) = 0)">
					<xsl:if test="not($head_substitution/substitution[self::substitution])">
						<xsl:message terminate="yes"> ***** return type assertion fails</xsl:message>
					</xsl:if>
					<xsl:message>   sSTF finished consumption branch one</xsl:message>
					<xsl:copy-of select="$head_substitution/substitution"/> 
				</xsl:when>
				<xsl:otherwise>	
					<xsl:variable name="targetTailSpecialised" as="element(targetTail)">
						<xsl:message>   sSTF about to sub into targetTail <xsl:apply-templates select="$head_substitution/targetTail" mode="text"/> </xsl:message>
						<xsl:apply-templates select="$head_substitution/targetTail" mode="substitution">
							<xsl:with-param name="substitutions" select="$head_substitution/substitution"/>
						</xsl:apply-templates>
					</xsl:variable> 
					<xsl:message>   sSTF target tail specialised <xsl:apply-templates select="$targetTailSpecialised" mode="text"/>
					</xsl:message>
					<xsl:variable name="subjectTailSpecialised" as="element(subjectTail)">
						<xsl:for-each select="$head_substitution/subjectTail">
							<xsl:apply-templates select="." mode="substitution">
								<xsl:with-param name="substitutions" select="$head_substitution/substitution"/>  
							</xsl:apply-templates>
						</xsl:for-each>
					</xsl:variable>
					<xsl:message>   sSTF subject tail specialised <xsl:apply-templates select="$subjectTailSpecialised" mode="text"/>
					</xsl:message>
					<xsl:choose>
						<xsl:when test="   (count($targetTailSpecialised/*) &gt; 0)
								or (count($subjectTailSpecialised/*) = 1 and  $subjectTailSpecialised/*[self::*:seq] )
								"> 
							<xsl:variable name="tail_substitutions" as="element(substitution)*">
								<xsl:message>   sSTF call to itself (unifySubtermSequences) recursively</xsl:message>
								<xsl:call-template name="unifySubtermSequences">
									<xsl:with-param name="subjectTerm" select="$subjectTailSpecialised"/>  									
									<xsl:with-param name="targetTerm" select="$targetTailSpecialised"/>  
								</xsl:call-template>
							</xsl:variable>
							<xsl:apply-templates select="$tail_substitutions" mode="compose_substitutions">
								<xsl:with-param name="head_substitution" select="$head_substitution/substitution"/>
							</xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise>
							<xsl:message>   sSTF iteration leg with no solution</xsl:message>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
		<xsl:message>Exiting sSTF</xsl:message>
	</xsl:template>


	<!-- headUnification
     ==================
    
     "headUnification" finds all substitutions that can be made into
     either the head subterm of the current subject or target term to bring them to match some
     sequence of subterms of the other term commencing from the target index.
     
     Returns zero one or more <head_substitution> elements.
     each <head_substitution> element contains
     a <substitution> element and a <subjectTail> element and a <targetTail> element.
     
     
     21 Feb 2018 Add a postcondition:
            <numberOfTargetChildrenConsumed>=count(<substitution>/<substitute>/<term>)
-->

	<xsl:template name="headUnification">
		<xsl:param name="subjectTerm" as="element()"/>
		<xsl:param name="targetTerm" as="element()"/>
		<xsl:variable name="head_substitution_entry_number" select="generate-id()"/>
		<xsl:variable name="subjectTerm_text"><xsl:apply-templates select="$subjectTerm" mode="text"/></xsl:variable>
		<xsl:variable name="targetTerm_text"><xsl:apply-templates select="$targetTerm" mode="text"/></xsl:variable>
		<xsl:message>      hS  head_substitution entry number: <xsl:value-of select="$head_substitution_entry_number"/>
		</xsl:message>
		<xsl:message>      hS  subjectTerm   <xsl:apply-templates select="$subjectTerm" mode="text"/>
		</xsl:message>
		<xsl:message>      hS  targetTerm  <xsl:apply-templates select="$targetTerm" mode="text"/>
		</xsl:message>
		<xsl:variable name="headUnification" as="element(head_substitution)*">
			<xsl:choose>
				<xsl:when test="$subjectTerm/* and not($subjectTerm/*[1][self::*:seq]) and not($targetTerm/*[1][self::*:seq])">
					<xsl:message> hS branch 1 </xsl:message>
					<!-- source is not  target is not seq -->
					<xsl:variable name="substitutions" as="element(substitution)*">  
						<xsl:call-template name="unifyTerms">
							<xsl:with-param name="subjectTerm" select="$subjectTerm/*[1]"/>
							<xsl:with-param name="targetTerm" select="$targetTerm/*[1]"/>
						</xsl:call-template>
					</xsl:variable>

					<xsl:variable name="subjectTailTerms" as="element()*" select="$subjectTerm/*[position() &gt; 1]"/>
					<xsl:message>      hS branch 1 subjectTailTerms are <xsl:apply-templates select="$subjectTailTerms" mode="text"/> 
					</xsl:message>
					<xsl:for-each select="$substitutions">
						<head_substitution>
							<xsl:copy-of select="."/>
							<subjectTail>
								<xsl:copy-of select="$subjectTailTerms"/> 
							</subjectTail>
							<targetTail>
								<xsl:copy-of select="$targetTerm/*[position() &gt; 1]"/> 
							</targetTail>
						</head_substitution>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise> 
					<xsl:if test="$subjectTerm/*[1][self::*:seq] and $targetTerm/*[1][self::*:seq]">

						<xsl:variable name="subjectseq" as="element()" select="$subjectTerm/*[1]"/>
						<xsl:variable name="targetseq" as="element()" select="$targetTerm/*[1]"/>

						<xsl:message>       19 March 2018 - case (1)</xsl:message> 
						<!-- case (3)  subject seq maps to empty
						               target seq  maps to empty
					    -->
						<head_substitution>
							<substitution>
								<case>1</case>
								<subject>
									<substitute>				
										<xsl:copy-of select="$subjectseq"/>
									</substitute>
								</subject>
								<target>
									<substitute>				
										<xsl:copy-of select="$targetseq"/>
									</substitute>
								</target>
							</substitution>
							<subjectTail>
								<xsl:copy-of  select="$subjectTerm/*[position() &gt; 1]"/>
							</subjectTail> 
							<targetTail>
								<xsl:copy-of select="$targetTerm/*[position() &gt; 1]"/> 
							</targetTail>
						</head_substitution>   

						<xsl:message>       19 March 2018 - case (2)</xsl:message> 
						<!-- case (2)  subject seq maps  empty
						               target seq  maps to each non-empty initial sequence of subterms of subject subterms bar subject 1
					    -->						
						<xsl:for-each select="$subjectTerm/*[position() &gt; 1 ]
								[not(some $subjectsubterm 
								in (  descendant-or-self::*:seq 
								| preceding-sibling::*/descendant-or-self::*:seq
								)               
								satisfies $subjectsubterm/name=$subjectseq/name
								)
								]
								">
							<head_substitution>
								<substitution>
									<case>2</case>
									<subject>
										<substitute>
											<xsl:copy-of select="$subjectseq"/>
										</substitute>
									</subject>
									<target>
										<substitute>
											<xsl:copy-of select="$targetseq"/>											
											<xsl:for-each select="(self::* | preceding-sibling::*)[preceding-sibling::*]"> 
												<term>
													<xsl:copy-of select="."/>
												</term>
											</xsl:for-each>
										</substitute>
									</target>
								</substitution>
								<subjectTail>
									<xsl:copy-of  select="following-sibling::*"/>
								</subjectTail>
								<targetTail>
									<xsl:copy-of select="$targetTerm/*[position() &gt; 1]"/> 
								</targetTail>
							</head_substitution>
						</xsl:for-each>

						<xsl:message>       19 March 2018 - case (3)</xsl:message> 
						<!-- case (3)  subject seq maps to every  to every initial sequence of target subterms starting beyond target subterm 1
						               target 1 maps to empty
					    -->
						<xsl:variable name="subjectTail" as="element(subjectTail)">
							<subjectTail>
								<xsl:copy-of  select="$subjectTerm/*[position() &gt; 1]"/>
							</subjectTail>
						</xsl:variable>
						<xsl:for-each select="$targetTerm/*[position() &gt; 1 ]
								[not(some $targetsubterm 
								in (  descendant-or-self::*:seq 
								| preceding-sibling::*/descendant-or-self::*:seq
								)               
								satisfies $targetsubterm/name=$subjectseq/name
								)
								]
								">
							<head_substitution>
								<substitution>
									<case>3</case>
									<subject>
										<substitute>
											<xsl:copy-of select="$subjectseq"/>
											<xsl:for-each select="(self::* | preceding-sibling::*)[preceding-sibling::*]"> 
												<term>
													<xsl:copy-of select="."/>
												</term>
											</xsl:for-each>
										</substitute>
									</subject>
									<target>
										<substitute>
											<xsl:copy-of select="$targetseq"/>
										</substitute>
									</target>
								</substitution>
								<xsl:copy-of  select="$subjectTail"/> 
								<targetTail>
									<xsl:copy-of select="$targetTerm/*[position() &gt; current()/count(preceding-sibling::*) + 1 ]"/> 
								</targetTail>
							</head_substitution>
						</xsl:for-each>
					</xsl:if>
					<xsl:if test="$subjectTerm/*[1][self::*:seq]">
						<xsl:variable name="subjectseq" as="element()" select="$subjectTerm/*[1]"/>
						<!-- case (4)  s1 maps to every non-empty non-singleton initial subsequence of the subterms target subterms -->
						<xsl:message>       19 March 2018 - case (4)</xsl:message> 
						<xsl:variable name="subjectTail" as="element(subjectTail)">
							<subjectTail>
								<xsl:copy-of  select="$subjectTerm/*[position() &gt; 1]"/>
							</subjectTail>
						</xsl:variable>
						<xsl:for-each select="$targetTerm/*[position() &gt; 1 ]
								[not(some $targetsubterm 
								in (  descendant-or-self::*:seq 
								| preceding-sibling::*/descendant-or-self::*:seq
								)               
								satisfies $targetsubterm/name=$subjectseq/name
								)
								]
								">
							<head_substitution>
								<substitution>
									<case>4</case>
									<subject>
										<substitute>
											<xsl:copy-of select="$subjectseq"/>
											<xsl:for-each select="self::* | preceding-sibling::*"> 
												<term>
													<xsl:copy-of select="."/>
												</term>
											</xsl:for-each>
										</substitute>
									</subject>
									<target>
									</target>
								</substitution>
								<xsl:copy-of  select="$subjectTail"/> 
								<targetTail>
									<xsl:copy-of select="$targetTerm/*[position() &gt; current()/count(preceding-sibling::*) + 1 ]"/> 
								</targetTail>
							</head_substitution>
						</xsl:for-each>						
					</xsl:if>

					<xsl:if test="$targetTerm/*[1][self::*:seq]">
						<xsl:message>       19 March 2018 - case (5)</xsl:message> 
						<!-- case (4)  t1 maps to every non-empty non-singleton initial subsequence of the subject subterms -->
						<xsl:variable name="targetseq" as="element()" select="$targetTerm/*[1]"/>
						<xsl:for-each select="$subjectTerm/*[position() &gt; 1][not(some $subjectsubterm 
								in (descendant-or-self::*:seq | preceding-sibling::*/descendant-or-self::*:seq) 
								satisfies $subjectsubterm/name=$targetseq/name
								)
								]
								">
							<head_substitution>
								<substitution>
									<case>5</case>
									<subject>
									</subject>
									<target>
										<substitute>
											<xsl:copy-of select="$targetseq"/>
											<xsl:for-each select="self::* | preceding-sibling::*">
												<term>
													<xsl:copy-of select="."/>
												</term>
											</xsl:for-each>
										</substitute>
									</target>
								</substitution>
								<subjectTail>
									<xsl:copy-of  select="following-sibling::*"/>
								</subjectTail>
								<targetTail>
									<xsl:copy-of select="$targetTerm/*[position() &gt; 1 ]"/> 
								</targetTail>
							</head_substitution>
						</xsl:for-each>
						<!--case (6) t1 maps to singleton s1 -->
						<xsl:if test="$subjectTerm/*">  <!-- test not reqd as at 20 March 2018 because calling template has code that completes when one target seq left and no subject subterms -->
							<!-- but calling code should be changed to call this template instead - code would be more uniform -->
							<xsl:message>       19 March 2018 - case (6)</xsl:message> 
							<xsl:message>       In case (6) number of subject subterms is <xsl:value-of select="count($subjectTerm/*)"/></xsl:message>
							<xsl:if test="not($subjectTerm/*[1][self::*:seq] and ($targetseq/name = $subjectTerm/*[1]/name) )">
								<xsl:message> case (6) triggers</xsl:message>
								<head_substitution>
									<substitution>
										<case>6</case>
										<subject>
										</subject>
										<target>
											<substitute>
												<xsl:copy-of select="$targetseq"/>
												<term>
													<xsl:copy-of select="$subjectTerm/*[1]"/>
												</term>
											</substitute>
										</target>
									</substitution>
									<subjectTail>
										<xsl:copy-of  select="$subjectTerm/*[position() &gt; 1]"/> 
									</subjectTail>
									<targetTail>
										<xsl:copy-of select="$targetTerm/*[position() &gt;  1 ]"/> 
									</targetTail>
								</head_substitution> 
							</xsl:if>							
						</xsl:if>						
					</xsl:if> 
					<xsl:if test="$subjectTerm/*[1][self::*:seq] and not($targetTerm/*[1][self::*:seq])">
						<xsl:variable name="subjectseq" as="element()" select="$subjectTerm/*[1]"/>
						<xsl:message> In case (7) number of target subterms is <xsl:value-of select="count($targetTerm/*)"/></xsl:message>
						<!-- case (7) s1 maps to empty-->
						<head_substitution>
							<substitution>
								<case>7</case>
								<subject>
									<substitute>
										<xsl:copy-of select="$subjectseq"/>
									</substitute>
								</subject>
								<target>
								</target>
							</substitution>
							<subjectTail>
								<xsl:copy-of  select="$subjectTerm/*[position() &gt; 1]"/> 
							</subjectTail>
							<targetTail> 
							    <xsl:copy-of select="$targetTerm/*"/>
							</targetTail>
						</head_substitution> 
						<xsl:if test="$targetTerm/*[1]">
							<!-- case (8) s1 maps to singleton t1-->
							<xsl:message>       19 March 2018 - case (8)</xsl:message>
							<head_substitution>							
								<substitution>
									<case>8</case>
									<subject>
										<substitute>
											<xsl:copy-of select="$subjectseq"/>
											<term>
												<xsl:copy-of select="$targetTerm/*[1]"/>
											</term>
										</substitute>
									</subject>
									<target>
									</target>
								</substitution>
								<subjectTail>
									<xsl:copy-of  select="$subjectTerm/*[position() &gt; 1]"/> 
								</subjectTail>
								<targetTail>
									<xsl:copy-of select="$targetTerm/*[position() &gt;  1 ]"/> 
								</targetTail>
							</head_substitution>
						</xsl:if>
					</xsl:if>
					<xsl:if test="$targetTerm/*[1][self::*:seq] and not($subjectTerm/*[1][self::*:seq])">
						<xsl:message>       19 March 2018 - case (9)</xsl:message>
						<xsl:message>                In case (9) number of subject subterms is <xsl:value-of select="count($subjectTerm/*)"/></xsl:message>
						<xsl:variable name="targetseq" as="element()" select="$targetTerm/*[1]"/>
						<!-- case (9) t1 maps to empty-->
						<head_substitution>
							<substitution>
								<case>9</case>
								<subject>								
								</subject>
								<target>
									<substitute>
										<xsl:copy-of select="$targetseq"/>
									</substitute>
								</target>
							</substitution>
							<subjectTail>
								<xsl:copy-of  select="$subjectTerm/*"/> 
							</subjectTail>
							<targetTail>
								<xsl:copy-of select="$targetTerm/*[position() &gt;  1 ]"/> 
							</targetTail>
						</head_substitution>
					</xsl:if>

				</xsl:otherwise> 
			</xsl:choose> 
		</xsl:variable>
		<!-- having gathered the results we will inspect then and apply post conditions before returning them -->
		<xsl:message>      hS head substitution entry number: <xsl:value-of select="$head_substitution_entry_number"/>
		</xsl:message>
		<xsl:message>      hS head substitution subject term: <xsl:apply-templates select="$subjectTerm" mode="text"/>
		</xsl:message>
		<xsl:message>      hS head substitution  targetTerm:  <xsl:apply-templates select="$targetTerm" mode="text"/>
		</xsl:message>
		<xsl:for-each select="$headUnification"> 
			<xsl:variable name="result_no" as="xs:integer" select="position()"/>
			<xsl:variable name="subjectTail_text" as="text()*">
				<xsl:apply-templates select="subjectTail" mode="text"/>
			</xsl:variable>
			<xsl:message>     hS head substitution result number:<xsl:value-of select="$result_no"/> </xsl:message>
			<xsl:message>     hS countOfVariablesSubstituted:<xsl:value-of select="count(substitution/*/substitute)"/></xsl:message>
			<xsl:message>     hS countOfTargetTermsSubstitutedIntoOuter:<xsl:value-of select="count(substitution/*/substitute/term)"/></xsl:message>  
			<xsl:message>     hS subjectTail:<xsl:value-of select="$subjectTail_text"/></xsl:message>

			<head_substitution>
				<!-- inject traceback for diagnostic purposes - can trace back to this place from the resulting substitutions -->
				<xsl:for-each select="substitution"> 
					<substitution>
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


</xsl:transform>