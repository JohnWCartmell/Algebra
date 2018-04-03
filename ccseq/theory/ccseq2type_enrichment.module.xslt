<xsl:transform version="2.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:ccseq               ="http://www.entitymodelling.org/theory/contextualcategory/sequence"
		xmlns:gat              ="http://www.entitymodelling.org/theory/generalisedalgebraictheory"
		xpath-default-namespace="http://www.entitymodelling.org/theory/contextualcategory/sequence" 	   
		xmlns="http://www.entitymodelling.org/theory/contextualcategory/sequence" >

	<xsl:strip-space elements="*"/>

	<!--

  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="yes"/>
  
  -->


	<xsl:template match="id[not(gat:type)][child::ccseq:*/gat:type]" 
			mode="initial_enrichment_recursive">
		<xsl:copy>
			<xsl:copy-of select="@*"/>  
			<xsl:apply-templates mode="copy_tidily"/>
			<gat:type>
				<!-- add typecheck here that childtype is an instance of "Ob" -->
				<Hom>
					<xsl:copy-of select="ccseq:*"/>
					<xsl:copy-of select="ccseq:*"/>
				</Hom>
			</gat:type>
		</xsl:copy>
	</xsl:template>	

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


	<xsl:template match="o[not(gat:type)]
			[count(child::ccseq:*) &gt; 1]
			[every $subterm in child::ccseq:*[position() &gt; 1] satisfies $subterm/gat:type]" 
			mode="initial_enrichment_recursive" priority="10">
		<xsl:copy>
			<xsl:copy-of select="@*"/>  
			<xsl:apply-templates mode="copy_tidily"/>
			<gat:type>

				<!-- typechecking -->
				<xsl:variable name="arg1">
					<xsl:copy-of select="ccseq:*[1]"/>
				</xsl:variable>
				<xsl:variable name="arg2dom">
					<xsl:copy-of select="ccseq:*[2]/gat:type/(Hom|HomSeq)/ccseq:*[1]"/>
				</xsl:variable>
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
						<xsl:copy-of select="gat:type/(Hom|HomSeq)/ccseq:*[2]"/>
					</xsl:variable>
					<xsl:variable name="dom" as="element()">
						<xsl:copy-of select="following-sibling::ccseq:*[1]/gat:type/(Hom|HomSeq)/ccseq:*[1]"/>
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
									<xsl:copy-of select="gat:type/(Hom|HomSeq)/ccseq:*[2]"/>
								</gat:lhs>
								<gat:rhs>
									<xsl:copy-of select="following-sibling::ccseq:*[1]/gat:type/(Hom|HomSeq)/ccseq:*[1]"/>
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
				<Hom>
					<xsl:copy-of select="$arg2dom"/>
					<xsl:copy-of select="ccseq:*[last()]/gat:type/(ccseq:Hom|ccseq:HomSeq)/ccseq:*[2]"/>
				</Hom>
			</gat:type>
		</xsl:copy>
	</xsl:template>


	<xsl:template match="p[not(gat:type)]
			[ccseq:*[1][gat:type]]
			" 
			mode="initial_enrichment_recursive">
		<xsl:variable name="domainTerm" as="element()" select="ccseq:*[1]"/>
		<xsl:variable name="codomainTerm" as="element()" select="ccseq:*[2]"/>
		<xsl:variable name="domainTermBase" as="element()" select="$domainTerm/gat:type/ccseq:Ob/ccseq:*[1]"/>
		<xsl:variable name="domainTerm_normalised" as="element()">
			<xsl:message>normalise p domain</xsl:message>
			<xsl:apply-templates mode="normalise" select="$domainTerm"/>
		</xsl:variable>
		<xsl:message>domain of p term normalised is <xsl:apply-templates select="$domainTerm_normalised" mode="text"/> </xsl:message>
		<xsl:variable name="codomainTerm_normalised" as="element()">
			<xsl:message>normalise p codomain term</xsl:message>
			<xsl:apply-templates mode="normalise" select="$codomainTerm"/>
		</xsl:variable>

		<xsl:variable name="codomainTerm_text">
			<xsl:apply-templates select="$codomainTerm_normalised" mode="text"/>
		</xsl:variable>
		<xsl:variable name="domainTermBase_text">
			<xsl:apply-templates select="$domainTermBase" mode="text"/>
		</xsl:variable>
		<xsl:copy>
			<xsl:copy-of select="@*"/> 
			<xsl:apply-templates mode="copy_tidily"/>	  

			<gat:type>
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
			</gat:type>
		</xsl:copy>
	</xsl:template>


	<xsl:template match="star[not(gat:type)]
			[child::ccseq:*[2][gat:type]]
			[child::ccseq:*[3][gat:type]]
			" 
			mode="initial_enrichment_recursive">
		<!-- star(x,f,z) -->
		<xsl:variable name="xTerm" as="element()" select="*[1]"/>
		<xsl:variable name="fTerm" as="element()" select="*[2]"/>
		<xsl:variable name="zTerm" as="element()" select="*[3]"/>
		<xsl:variable name="zTermBase" as="element()?" select="$zTerm/gat:type/ccseq:Ob/ccseq:*"/>
		<xsl:variable name="fTermDomain" as="element()?" select="$fTerm/gat:type/ccseq:Hom/ccseq:*[1]"/>
		<xsl:variable name="fTermCodomain" as="element()?" select="$fTerm/gat:type/ccseq:Hom/ccseq:*[2]"/>
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
						<gat:lacking_type_information/>
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
						<gat:lacking_type_information/>
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
			[ccseq:*[2]/gat:type]
			[ccseq:*[3]/gat:type]
			" 
			mode="initial_enrichment_recursive">

		<xsl:variable name="xTerm" as="element()" select="child::ccseq:*[1]"/>
		<xsl:variable name="fTerm" as="element()" select="child::ccseq:*[2]"/>
		<xsl:variable name="zTerm" as="element()" select="child::ccseq:*[3]"/>
		<xsl:variable name="fTermDomain" as="element()" select="$fTerm/gat:type/(Hom|HomSeq)/ccseq:*[1]"/>
		<xsl:variable name="fTermCodomain" as="element()" select="$fTerm/gat:type/(Hom|HomSeq)/ccseq:*[2]"/>
		<xsl:variable name="zTermBase" as="element()" select="$zTerm/gat:type/Ob/ccseq:*[1]"/>
		<xsl:variable name="xTerm_text">
			<xsl:apply-templates mode="text" select="$xTerm"/>
		</xsl:variable>
		<xsl:variable name="fTermDomain_text">
			<xsl:apply-templates mode="text" select="$fTermDomain"/>
		</xsl:variable>
		<xsl:variable name="fTermCodomain_text">
			<xsl:apply-templates mode="text" select="$fTermCodomain"/>
		</xsl:variable>
		<xsl:variable name="zTermBase_text">
			<xsl:apply-templates mode="text" select="$zTermBase"/>
		</xsl:variable>

		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="copy_tidily"/>
			<gat:type>
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
				<xsl:variable name="codomain_term_normalised" as="element()">
					<xsl:apply-templates mode="normalise" select="ccseq:*[3]"/>
				</xsl:variable>
				<Hom>
					<xsl:copy-of select="$domain_term_normalised/ccseq:*"/>  
					<xsl:copy-of select="$codomain_term_normalised"/>  
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
			</gat:type>
		</xsl:copy>
	</xsl:template>


	<xsl:template match="s[not(gat:type)]
			[child::ccseq:*[2]/gat:type/(ccseq:Hom|ccseq:Homseq)/ccseq:*[2]/gat:type]" 
			mode="initial_enrichment_recursive">

		<xsl:variable name="xTerm" as="element()" select="child::ccseq:*[1]"/>
		<xsl:variable name="fTerm" as="element()" select="child::ccseq:*[2]"/>
		<xsl:variable name="yTerm" as="element()" select="$fTerm/gat:type/(ccseq:Hom|ccseq:Homseq)/ccseq:*[2]"/>
		<xsl:variable name="fTermDomain" as="element()" select="$fTerm/gat:type/(Hom|HomSeq)/ccseq:*[1]"/>

		<xsl:variable name="xTerm_text">
			<xsl:apply-templates mode="text" select="$xTerm"/>
		</xsl:variable>
		<xsl:variable name="fTermDomain_text">
			<xsl:apply-templates mode="text" select="$fTermDomain"/>
		</xsl:variable>

		<xsl:message>in type of s term yTerm is <xsl:copy-of select="$yTerm"/></xsl:message>
		<xsl:variable name="y_pTerm" as="element()" select="$yTerm/gat:type/Ob/ccseq:*[1]"/>
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="copy_tidily"/>
			<gat:type>
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

