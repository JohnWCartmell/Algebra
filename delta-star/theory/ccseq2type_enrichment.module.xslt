<xsl:transform version="2.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:ccseq               ="http://www.entitymodelling.org/theory/contextualcategory/sequence"
		xmlns:gat              ="http://www.entitymodelling.org/theory/generalisedalgebraictheory"
		xpath-default-namespace="http://www.entitymodelling.org/theory/contextualcategory/sequence" 	   
		xmlns="http://www.entitymodelling.org/theory/contextualcategory/sequence" 
		exclude-result-prefixes="xs">

	<xsl:strip-space elements="*"/>

	<!-- type of o(x) is Hom(x,x) -->
	<xsl:template match="o[not(gat:type)]
			[count(child::ccseq:*)=1]
			" 
			mode="initial_enrichment_recursive" priority="11">
		<xsl:copy>
			<xsl:copy-of select="@*"/>  
			<xsl:apply-templates mode="copy_tidily"/>
			<gat:type>				
				<Hom>
					<xsl:copy-of select="ccseq:*[1]"/>
					<xsl:copy-of select="ccseq:*[1]"/>
				</Hom>
			</gat:type>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="o
			[count(*[not(self::ccseq:*)]) &gt; 1]" 
			mode="initial_enrichment_recursive" priority="1000">
		<xsl:message>Found in o term : <xsl:copy-of select="*[not(self::ccseq:*)]"/></xsl:message>
		<xsl:message terminate="yes">so hold everything - more than one non ccseq child in o term
			<xsl:apply-templates select="." mode="text"/>
		</xsl:message>
	</xsl:template>

	<xsl:template match="o[not(gat:type)]
			[count(child::ccseq:*) &gt; 1]
			[every $subterm in child::ccseq:*[position() &gt; 1] satisfies $subterm/gat:type[not(gat:type_error)]]" 
			mode="initial_enrichment_recursive" priority="10">
		<xsl:copy>
			<xsl:copy-of select="@*"/>  
			<xsl:apply-templates mode="copy_tidily"/>
			<gat:type>
				<xsl:variable name="arg1" as="element()">
					<xsl:apply-templates select="ccseq:*[1]" mode="normalise"/>
				</xsl:variable>
				<xsl:if test="not(ccseq:*[2]/gat:type/(Hom|HomSeq)/ccseq:*[1])">
					<xsl:message terminate="yes">Arg 2 of o term has type <xsl:copy-of select="ccseq:*[2]/gat:type"/> which has no domain</xsl:message>
				</xsl:if>
				<xsl:if test="count(ccseq:*[2]/gat:type/(Hom|HomSeq)/ccseq:*[1]) &gt; 1 ">
					<xsl:message terminate="yes">Unexpected structure in o term<xsl:copy-of select="."/></xsl:message>
				</xsl:if>
				<xsl:variable name="arg2dom" as="element()">
					<xsl:apply-templates select="ccseq:*[2]/gat:type/(Hom|HomSeq)/ccseq:*[1]" mode="normalise"/>
				</xsl:variable>
				<Hom>
					<xsl:copy-of select="$arg2dom"/>
					<xsl:copy-of select="ccseq:*[last()]/gat:type/(ccseq:Hom|ccseq:HomSeq)/ccseq:*[2]"/>
				</Hom>
				<!-- typechecking -->
				<xsl:variable name="arg1_text">
					<xsl:apply-templates mode="text" select="$arg1"/>
				</xsl:variable>
				<xsl:variable name="arg2dom_text">
					<xsl:apply-templates mode="text" select="$arg2dom"/>
				</xsl:variable>
				<xsl:if test="not($arg1_text=$arg2dom_text)">
					<gat:type_error>
						<gat:need-equal>
							<gat:lhs>
								<xsl:copy-of select="$arg1"/>
							</gat:lhs>
							<gat:rhs>
								<xsl:copy-of select="$arg2dom"/>
							</gat:rhs>
						</gat:need-equal>
						<gat:description>
							<gat:text>domain of subterm 2 of o is </gat:text>
							<gat:term>
								<xsl:copy-of select="$arg2dom"/> 
							</gat:term>
							<gat:text> which is is not identical to explicit domain in arg 1 which is </gat:text>
							<gat:term>
								<xsl:copy-of select="$arg1"/>
							</gat:term>
						</gat:description>
					</gat:type_error> 
				</xsl:if>
				<xsl:for-each select="ccseq:*[position() &gt; 1][following-sibling::ccseq:*]">
					<xsl:variable name="cod" as="element()">                       
						<xsl:apply-templates select="gat:type/(Hom|HomSeq)/ccseq:*[2]" mode="normalise"/>
					</xsl:variable>
					<xsl:variable name="dom" as="element()">
						<xsl:apply-templates select="following-sibling::ccseq:*[1]/gat:type/(Hom|HomSeq)/ccseq:*[1]" mode="normalise"/>
					</xsl:variable>
					<xsl:variable name="cod_text">
						<xsl:apply-templates mode="text" select="$cod"/>
					</xsl:variable>
					<xsl:variable name="dom_text">
						<xsl:apply-templates mode="text" select="$dom"/>
					</xsl:variable>
					<xsl:if test="$cod_text=''" >
						<xsl:message> No cod text for type <xsl:copy-of select="gat:type"/> </xsl:message>
						<xsl:message terminate="yes">No codomain defined in <xsl:copy-of select=".."/></xsl:message>
					</xsl:if>
					<xsl:if test="not($cod_text=$dom_text)">
						<xsl:message> Type error in subterms of o in rule <xsl:value-of select="ancestor::gat:rewriteRule/gat:id"/></xsl:message>
						<gat:type_error>
							<gat:need-equal>
								<gat:lhs>
									<xsl:copy-of select="$cod"/>
								</gat:lhs>
								<gat:rhs>
									<xsl:copy-of select="$dom"/>
								</gat:rhs>
							</gat:need-equal>
							<gat:description>
								<gat:text>domain of subterm <xsl:value-of select="count(preceding-sibling::ccseq:*) + 2"/> is </gat:text>
								<gat:term>
									<xsl:copy-of select="$dom"/> 
								</gat:term>
								<gat:text> which is is not identical to codomain of preceding subterm which is </gat:text>
								<gat:term>
									<xsl:copy-of select="$cod"/>
								</gat:term>
							</gat:description>
						</gat:type_error>    
					</xsl:if>
				</xsl:for-each>
			</gat:type>
		</xsl:copy>
	</xsl:template>


	<xsl:template match="p[not(gat:type)]
			[ccseq:*[1][gat:type]]
			" 
			mode="initial_enrichment_recursive">
		<xsl:variable name="domainTerm" as="element()" select="ccseq:*[1]"/>
		<xsl:variable name="codomainTerm" as="element()" select="ccseq:*[2]"/>
		<xsl:variable name="domainTermBase" as="element()?" select="$domainTerm/gat:type/ccseq:Ob/ccseq:*[1]" />
		<xsl:copy>
			<xsl:copy-of select="@*"/> 
			<xsl:apply-templates mode="copy_tidily"/>
			<gat:type>
				<xsl:choose>
					<xsl:when test="not($domainTermBase)">
						<xsl:message>p term is <xsl:apply-templates select="." mode="text"/></xsl:message>
						<xsl:message>Typing insufficient - domain term of first argument to p has no base</xsl:message>
						<gat:type_error>
							<gat:insufficient_explicit_typing/>
							<gat:description>
								<gat:text> In p term </gat:text>
								<gat:term>
									<xsl:copy-of select="."/>
								</gat:term>
								<gat:text> subterm 1 has not got a base type</gat:text>
							</gat:description>
						</gat:type_error> 
					</xsl:when>
					<xsl:otherwise>
						<xsl:variable name="domainTermBase_normalised" as="element()">
							<xsl:apply-templates select="$domainTerm" mode="normalise" />
						</xsl:variable>	
						<xsl:variable name="domainTerm_normalised" as="element()">
							<xsl:apply-templates select="$domainTerm" mode="normalise" />
						</xsl:variable>
						<xsl:variable name="codomainTerm_normalised" as="element()">
							<xsl:apply-templates  select="$codomainTerm" mode="normalise"/>
						</xsl:variable>

						<xsl:variable name="codomainTerm_text">
							<xsl:apply-templates select="$codomainTerm_normalised" mode="text"/>
						</xsl:variable>
						<xsl:variable name="domainTermBase_text">
							<xsl:apply-templates select="$domainTermBase" mode="text"/>
						</xsl:variable>

						<xsl:choose>
							<xsl:when test="$domainTerm_normalised=$codomainTerm_normalised">
								<xsl:message>illformed p term <xsl:apply-templates select="." mode="text"/></xsl:message>
								<gat:illformed/>
								<Hom>
									<impossible/>
									<impossible/>
								</Hom>
							</xsl:when>
							<xsl:otherwise>
								<Hom>
									<xsl:copy-of select="$domainTerm_normalised"/>
									<xsl:copy-of select="$codomainTerm_normalised"/>  
								</Hom>
								<xsl:if test="not($domainTermBase_text=$codomainTerm_text)">
									<gat:type_error>
										<gat:need-equal>
											<gat:lhs>
												<xsl:copy-of select="$domainTermBase"/>
											</gat:lhs>
											<gat:rhs>
												<xsl:copy-of select="$codomainTerm"/>
											</gat:rhs>
										</gat:need-equal>
										<gat:description>
											<gat:text>domain of p term hase base</gat:text>
											<gat:term>
												<xsl:copy-of select="$domainTermBase"/> 
											</gat:term>
											<gat:text> which is is not identical to codomain in arg 2 which is </gat:text>
											<gat:term>
												<xsl:copy-of select="$codomainTerm"/>
											</gat:term>
										</gat:description>
									</gat:type_error>    
								</xsl:if>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</gat:type>
		</xsl:copy>
	</xsl:template>


	<xsl:template match="star[not(gat:type)]
			[child::ccseq:*[2][gat:type]]
			[child::ccseq:*[3][gat:type]]
			" 
			mode="initial_enrichment_recursive">
		<!-- star(x,f,z) -->
		<xsl:variable name="xTerm" as="element()">
			<xsl:apply-templates select="*[1]" mode="normalise"/>
		</xsl:variable>
		<xsl:variable name="fTerm" as="element()">
			<xsl:apply-templates  select="*[2]" mode="normalise"/>
		</xsl:variable>
		<xsl:variable name="zTerm" as="element()">
			<xsl:apply-templates  select="*[3]" mode="normalise"/>
		</xsl:variable>
		<xsl:variable name="zTermBase" as="element()?">
			<xsl:apply-templates  select="*[3]/gat:type/ccseq:Ob/ccseq:*" mode="normalise"/>
		</xsl:variable>
		<xsl:variable name="fTermDomain" as="element()?">
			<xsl:apply-templates  select="*[2]/gat:type/ccseq:Hom/ccseq:*[1]" mode="normalise"/>
		</xsl:variable>
		<xsl:variable name="fTermCodomain" as="element()?">
			<xsl:apply-templates  select="*[2]/gat:type/ccseq:Hom/ccseq:*[2]" mode="normalise"/>
		</xsl:variable>
		<xsl:variable name="xTerm_text" >
			<xsl:apply-templates mode="text" select="$xTerm"/>
		</xsl:variable>
		<xsl:variable name="zTermBase_text">
			<xsl:apply-templates mode="text" select="$zTermBase"/>
		</xsl:variable>
		<xsl:variable name="fTermDomain_text">
			<xsl:apply-templates mode="text" select="$fTermDomain"/>
		</xsl:variable>
		<xsl:variable name="fTermCodomain_text">
			<xsl:apply-templates mode="text" select="$fTermCodomain"/>
		</xsl:variable>
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="copy_tidily"/>
			<gat:type>
				<Ob>
					<xsl:copy-of select="$xTerm" />
				</Ob>
				<xsl:if test="not($zTermBase)">
					<xsl:message> In star - undefined zTermBase for <xsl:apply-templates select="$zTerm" mode="text"/>  in <xsl:apply-templates select="." mode="text"/> <xsl:copy-of select="."/> </xsl:message>
					<gat:type_error>
						<gat:insufficient_explicit_typing/>
						<gat:description>
							<gat:text> In star term </gat:text>
							<gat:term>
								<xsl:copy-of select="."/>
							</gat:term>
							<gat:text> subterm 3 has not got a base type</gat:text>
						</gat:description>
					</gat:type_error> 
				</xsl:if>
				<xsl:if test="not($fTermDomain)">	
					<xsl:message> In star - undefined fTermDomain for <xsl:apply-templates select="$fTerm" mode="text"/>  in <xsl:apply-templates select="." mode="text"/></xsl:message>				
					<gat:type_error>
						<gat:insufficient_explicit_typing/>
						<gat:description>
							<gat:text> In star term </gat:text>
							<gat:term>
								<xsl:copy-of select="."/>
							</gat:term>
							<gat:text> subterm 2 has not got a domaintype</gat:text>
						</gat:description>
					</gat:type_error> 
				</xsl:if>
				<xsl:if test="$fTermDomain and $zTermBase and not($zTermBase_text = $fTermCodomain_text)">
					<gat:type_error>
						<gat:need-equal>
							<gat:lhs>
								<xsl:copy-of select="$zTermBase"/>
							</gat:lhs>
							<gat:rhs>
								<xsl:copy-of select="$fTermCodomain"/>
							</gat:rhs>
						</gat:need-equal>
						<gat:description>
							<gat:text> In star term </gat:text>
							<gat:term>
								<xsl:copy-of select="."/>
							</gat:term>
							<gat:text> subterm 2 has codomain </gat:text>
							<gat:term><xsl:copy-of select="$fTermCodomain"/></gat:term>
							<gat:text>which is not identical to base type of subterm 3 which is </gat:text>
							<gat:term><xsl:copy-of select="$zTermBase"/></gat:term>
						</gat:description>
					</gat:type_error> 
				</xsl:if>
				<xsl:if test="$fTermDomain and not($xTerm_text = $fTermDomain_text)">
					<gat:type_error>
						<gat:need-equal>
							<gat:lhs>
								<xsl:copy-of select="$xTerm"/>
							</gat:lhs>
							<gat:rhs>
								<xsl:copy-of select="$fTermDomain"/>
							</gat:rhs>
						</gat:need-equal>
						<gat:description>
							<gat:text> In star term </gat:text>
							<gat:term>
								<xsl:copy-of select="."/>
							</gat:term>
							<gat:text> subterm 1 is </gat:text>
							<gat:term><xsl:copy-of select="$xTerm"/></gat:term>
							<gat:text>which is not identical to domain of subterm 2 which is </gat:text>
							<gat:term><xsl:copy-of select="$fTermDomain"/></gat:term>
						</gat:description>
					</gat:type_error> 
				</xsl:if>

			</gat:type>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="q[not(gat:type)]
			[ccseq:*[2]/gat:type[not(gat:type_error)]]
			[ccseq:*[3]/gat:type[not(gat:type_error)]]
			" 
			mode="initial_enrichment_recursive">

		<xsl:variable name="xTerm" as="element()">
			<xsl:apply-templates   select="child::ccseq:*[1]" mode="normalise"/>
		</xsl:variable>
		<xsl:variable name="fTerm" as="element()">
			<xsl:copy-of   select="child::ccseq:*[2]"/>
		</xsl:variable>
		<xsl:variable name="zTerm" as="element()">
			<xsl:apply-templates   select="child::ccseq:*[3]" mode="normalise"/>
		</xsl:variable>
		<xsl:variable name="fTermDomain" as="element()">
			<xsl:apply-templates   select="child::ccseq:*[2]/gat:type/(Hom|HomSeq)/ccseq:*[1]" mode="normalise"/>
		</xsl:variable>
		<xsl:variable name="fTermCodomain" as="element()">
			<xsl:apply-templates   select="child::ccseq:*[2]/gat:type/(Hom|HomSeq)/ccseq:*[2]" mode="normalise"/>
		</xsl:variable>

		<xsl:variable name="xTerm_text">
			<xsl:apply-templates mode="text" select="$xTerm"/>
		</xsl:variable>
		<xsl:variable name="fTermDomain_text">
			<xsl:apply-templates mode="text" select="$fTermDomain"/>
		</xsl:variable>
		<xsl:variable name="fTermCodomain_text">
			<xsl:apply-templates mode="text" select="$fTermCodomain"/>
		</xsl:variable>
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="copy_tidily"/>
			<gat:type>
				<xsl:choose>
					<xsl:when test="not(child::ccseq:*[3]/gat:type/Ob/ccseq:*[1])">
						<xsl:message>Typing incomplete in q term - zTerm has no base</xsl:message>
						<gat:type_error>
							<gat:insufficient_explicit_typing/>
							<gat:description>
								<gat:text> In q term </gat:text>
								<gat:term>
									<xsl:copy-of select="."/>
								</gat:term>
								<gat:text> subterm 3 </gat:text>
								<gat:term>
									<xsl:copy-of select="child::ccseq:*[3]"/>
								</gat:term>
								<gat:text>has not got a base type</gat:text>
							</gat:description>
						</gat:type_error> 
					</xsl:when>
					<xsl:otherwise>
						<xsl:variable name="zTermBase" as="element()">
							<xsl:apply-templates   select="child::ccseq:*[3]/gat:type/Ob/ccseq:*[1]" mode="normalise"/>
						</xsl:variable>
						<xsl:variable name="zTermBase_text">
							<xsl:apply-templates mode="text" select="$zTermBase"/>
						</xsl:variable>
						<!-- add typechecking here ? -->
						<!-- to normalise we just need to normalise the domain -->
						<xsl:variable name="domain" as="element(gat:term)">
							<gat:term>
								<star>
									<xsl:copy-of select="$fTermDomain"/>
									<xsl:copy-of select="$fTerm"/>
									<xsl:copy-of select="$zTerm"/>
								</star>
							</gat:term>
						</xsl:variable>
						<xsl:variable name="domain_term_normalised" as="element(gat:term)">
							<xsl:apply-templates mode="normalise" select="$domain"/>
						</xsl:variable>
						<Hom>
							<xsl:copy-of select="$domain_term_normalised/ccseq:*"/>  
							<xsl:copy-of select="$zTerm"/>  
						</Hom>
						<xsl:if test="not($xTerm_text=$fTermDomain_text)">
							<gat:type_error>
								<gat:need-equal>
									<gat:lhs>
										<xsl:copy-of select="$xTerm"/>
									</gat:lhs>
									<gat:rhs>
										<xsl:copy-of select="$fTermDomain"/>
									</gat:rhs>
								</gat:need-equal>
								<gat:description>
									<gat:text>in q term the domain of subterm 2 is </gat:text>
									<gat:term>
										<xsl:copy-of select="$fTermDomain"/> 
									</gat:term>
									<gat:text> which is is not identical to explicit domain in arg 1 which is </gat:text>
									<gat:term>
										<xsl:copy-of select="$xTerm"/>
									</gat:term>
								</gat:description>
							</gat:type_error> 
						</xsl:if>
						<xsl:if test="not($zTermBase_text=$fTermCodomain_text)">
							<gat:type_error>
								<gat:need-equal>
									<gat:lhs>
										<xsl:copy-of select="$zTermBase"/>
									</gat:lhs>
									<gat:rhs>
										<xsl:copy-of select="$fTermCodomain"/>
									</gat:rhs>
								</gat:need-equal>
								<gat:description>
									<gat:text>in q term the codomain of subterm 2 is </gat:text>
									<gat:term>
										<xsl:copy-of select="$fTermCodomain"/> 
									</gat:term>
									<gat:text> which is is not identical to the base type of arg 3 which is </gat:text>
									<gat:term>
										<xsl:copy-of select="$zTermBase"/>
									</gat:term>
								</gat:description>
							</gat:type_error> 
						</xsl:if>
					</xsl:otherwise>
				</xsl:choose>
			</gat:type>
		</xsl:copy>
	</xsl:template>


	<xsl:template match="s[not(gat:type)]
			[child::ccseq:*[2]/gat:type[not(gat:type_error)]/(ccseq:Hom|ccseq:Homseq)/ccseq:*[2]/gat:type]" 
			mode="initial_enrichment_recursive">
		<!-- 
           suppose s(f) where  f: x -> y 
		-->
		<xsl:variable name="xTerm" as="element()">
			<xsl:apply-templates    select="child::ccseq:*[1]" mode="normalise"/>
		</xsl:variable>
		<xsl:variable name="fTerm" as="element()" select="child::ccseq:*[2]"/>
		<xsl:variable name="yTerm" as="element()" select="$fTerm/gat:type/(ccseq:Hom|ccseq:Homseq)/ccseq:*[2]"/>
		<xsl:variable name="fTermDomain" as="element()">
			<xsl:apply-templates  select="$fTerm/gat:type/(ccseq:Hom|ccseq:HomSeq)/ccseq:*[1]" mode="normalise"/>
		</xsl:variable>

		<xsl:variable name="xTerm_text">
			<xsl:apply-templates mode="text" select="$xTerm"/>
		</xsl:variable>
		<xsl:variable name="fTermDomain_text">
			<xsl:apply-templates mode="text" select="$fTermDomain"/>
		</xsl:variable>
		<xsl:variable name="y_pTerm" as="element()?" select="$yTerm/gat:type/Ob/ccseq:*[1]"/>

		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="copy_tidily"/>
			<gat:type>
				<xsl:choose>
					<xsl:when test="not($y_pTerm)">
						<xsl:message>Incomplete typing - in s term its f argument has a codomain that has no base</xsl:message>
						<gat:type_error>
							<gat:insufficient_explicit_typing/>
							<gat:description>
								<gat:text> In s term </gat:text>
								<gat:term>
									<xsl:copy-of select="."/>
								</gat:term>
								<gat:text> its f argument has a codomain </gat:text>
								<gat:term>
									<xsl:copy-of select="$yTerm"/>
								</gat:term>
								<gat:text>that has no base</gat:text>
							</gat:description>
						</gat:type_error>
					</xsl:when>					
					<xsl:otherwise>
						<!-- to normalise we just need to normalise the codomain -->
						<xsl:variable name="codomain" as="element(gat:term)">
							<gat:term>
								<star>
									<xsl:copy-of select="$xTerm"/>
									<xsl:copy-of select="$fTerm"/>
									<star>
										<xsl:copy-of select="$xTerm"/>
										<p>								   
											<xsl:copy-of select="$yTerm"/>
											<xsl:copy-of select="$y_pTerm"/>
										</p>
										<xsl:copy-of select="$yTerm"/>
									</star>
								</star>	
							</gat:term>
						</xsl:variable>
						<xsl:variable name="codomain_term_normalised" as="element(gat:term)">
							<xsl:apply-templates mode="normalise" select="$codomain"/>
						</xsl:variable>
						<Hom>
							<xsl:copy-of select="$xTerm"/>
							<xsl:copy-of select="$codomain_term_normalised/ccseq:*"/>  
						</Hom>
						<xsl:if test="not($xTerm_text=$fTermDomain_text)">
							<gat:type_error>
								<gat:need-equal>
									<gat:lhs>
										<xsl:copy-of select="$xTerm"/>
									</gat:lhs>
									<gat:rhs>
										<xsl:copy-of select="$fTermDomain"/>
									</gat:rhs>
								</gat:need-equal>
								<gat:description>
									<gat:text>in s term the domain of subterm 2 is </gat:text>
									<gat:term>
										<xsl:copy-of select="$fTermDomain"/> 
									</gat:term>
									<gat:text> which is is not identical to explicit domain in arg 1 which is </gat:text>
									<gat:term>
										<xsl:copy-of select="$xTerm"/>
									</gat:term>
								</gat:description>
							</gat:type_error> 
						</xsl:if>
					</xsl:otherwise>
				</xsl:choose>				
			</gat:type>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="subm[not(gat:type)]
			[child::ccseq:*[2][gat:type]]
			[child::ccseq:*[3][gat:type]]
			[child::ccseq:*[3]/gat:type[not(gat:type_error)]/ccseq:Hom/ccseq:*[2]/gat:type]
			" 
			mode="initial_enrichment_recursive">   <!-- NOT CLEAR that ABOVE 3rd predicate correct -->
		<!-- subm(x, f,g) -->
		<!-- f: x -> yp -->
		<!-- g: yp -> y -->
		<xsl:variable name="fTerm" as="element()">
			<xsl:apply-templates  select="ccseq:*[2]" mode="normalise"/>
		</xsl:variable>
		<xsl:variable name="gTerm" as="element()">
			<xsl:apply-templates  select="ccseq:*[3]" mode="normalise"/>
		</xsl:variable>
		<xsl:variable name="fTermDomain_aka_x" as="element()?">
			<xsl:apply-templates  select="$fTerm/gat:type/ccseq:Hom/ccseq:*[1]" mode="normalise"/>
		</xsl:variable>
		<xsl:variable name="fTermCodomain_aka_yp" as="element()?">
			<xsl:apply-templates  select="$fTerm/gat:type/ccseq:Hom/ccseq:*[2]" mode="normalise"/>
		</xsl:variable>
		<xsl:variable name="gTermDomain_aka_yp" as="element()?">
			<xsl:apply-templates  select="$gTerm/gat:type/ccseq:Hom/ccseq:*[1]" mode="normalise"/>
		</xsl:variable>
		<xsl:variable name="gTermCodomain_aka_y" as="element()?">
			<xsl:apply-templates  select="$gTerm/gat:type/ccseq:Hom/ccseq:*[2]" mode="normalise"/>
		</xsl:variable>
		<xsl:variable name="gTermCodomainBase_aka_yp" as="element()?">
			<xsl:apply-templates  select="$gTermCodomain_aka_y/gat:type/ccseq:Ob/ccseq:*" mode="normalise"/> 
		</xsl:variable>
		<xsl:variable name="fTermCodomain_aka_yp_text" >
			<xsl:apply-templates mode="text" select="$fTermCodomain_aka_yp"/>
		</xsl:variable>
		<xsl:variable name="gTermDomain_aka_yp_text">
			<xsl:apply-templates mode="text" select="$gTermDomain_aka_yp"/>
		</xsl:variable>
		<xsl:variable name="gTermCodomainBase_aka_yp_text">
			<xsl:apply-templates mode="text" select="$gTermCodomainBase_aka_yp"/>
		</xsl:variable>
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="copy_tidily"/>
			<xsl:variable name="codomain" as="element(gat:term)">
				<gat:term>
					<star>
						<xsl:copy-of select="$fTermDomain_aka_x"/>
						<o>
							<xsl:copy-of select="$fTermDomain_aka_x"/>
							<xsl:copy-of select="$fTerm"/>
							<xsl:copy-of select="$gTerm"/>
							<p>
								<xsl:copy-of select="$gTermCodomain_aka_y"/>
								<xsl:copy-of select="$gTermCodomainBase_aka_yp"/>
							</p>
						</o>
						<xsl:copy-of select="$gTermCodomain_aka_y"/>
					</star>
				</gat:term>
			</xsl:variable>
			<xsl:variable name="codomain_term_normalised" as="element(gat:term)">
				<xsl:apply-templates mode="normalise" select="$codomain"/>
			</xsl:variable>
			<gat:type>
				<Hom>
					<xsl:copy-of select="$fTermDomain_aka_x" />
					<xsl:copy-of select="$codomain_term_normalised/ccseq:*"/>  
				</Hom>

				<xsl:if test="not($gTermCodomainBase_aka_yp)">
					<xsl:message> In subm - undefined gTermCodomainBase_aka_yp for <xsl:apply-templates select="$gTerm" mode="text"/>  in <xsl:apply-templates select="." mode="text"/> <xsl:copy-of select="."/> </xsl:message>
					<gat:type_error>
						<gat:insufficient_explicit_typing/>
						<gat:description>
							<gat:text> In subm term </gat:text>
							<gat:term>
								<xsl:copy-of select="."/>
							</gat:term>
							<gat:text> codomain of subterm 3 has not got a base type</gat:text>
						</gat:description>
					</gat:type_error> 
				</xsl:if>
				<xsl:if test="not($gTermDomain_aka_yp_text = $fTermCodomain_aka_yp_text)">
					<gat:type_error>
						<gat:need-equal>
							<gat:lhs>
								<xsl:copy-of select="$gTermDomain_aka_yp"/>
							</gat:lhs>
							<gat:rhs>
								<xsl:copy-of select="$fTermCodomain_aka_yp"/>
							</gat:rhs>
						</gat:need-equal>
						<gat:description>
							<gat:text> In subm term </gat:text>
							<gat:term>
								<xsl:copy-of select="."/>
							</gat:term>
							<gat:text> subterm 2 has codomain</gat:text>
							<gat:term><xsl:copy-of select="$fTermCodomain_aka_yp"/></gat:term>
							<gat:text>which is not identical to domain of subterm 3 which is </gat:text>
							<gat:term><xsl:copy-of select="$gTermDomain_aka_yp"/></gat:term>
						</gat:description>
					</gat:type_error> 
				</xsl:if>
				<xsl:if test="$gTermCodomainBase_aka_yp and not($gTermCodomainBase_aka_yp_text = $gTermDomain_aka_yp_text)">
					<gat:type_error>
						<gat:need-equal>
							<gat:lhs>
								<xsl:copy-of select="$gTermCodomainBase_aka_yp"/>
							</gat:lhs>
							<gat:rhs>
								<xsl:copy-of select="$gTermDomain_aka_yp"/>
							</gat:rhs>
						</gat:need-equal>
						<gat:description>
							<gat:text> In subm term </gat:text>
							<gat:term>
								<xsl:copy-of select="."/>
							</gat:term>
							<gat:text> subterm 3 has domain</gat:text>
							<gat:term><xsl:copy-of select="$gTermDomain_aka_yp"/></gat:term>
							<gat:text>which is not identical to base type of its codomain  which is </gat:text>
							<gat:term><xsl:copy-of select="$gTermCodomainBase_aka_yp"/></gat:term>
						</gat:description>
					</gat:type_error> 
				</xsl:if>
			</gat:type>
		</xsl:copy>
	</xsl:template>


	<xsl:template match="*" mode="copy_tidily">
		<xsl:copy copy-namespaces="no">
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="copy_tidily"/>
		</xsl:copy>
	</xsl:template>


</xsl:transform>

