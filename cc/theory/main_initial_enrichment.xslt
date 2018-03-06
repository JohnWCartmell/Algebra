<xsl:transform version="2.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:cc               ="http://www.entitymodelling.org/theory/contextualcategory"
		xmlns:gat              ="http://www.entitymodelling.org/theory/generalisedalgebraictheory"
		xpath-default-namespace="http://www.entitymodelling.org/theory/contextualcategory" 	   
		xmlns="http://www.entitymodelling.org/theory/contextualcategory" >

	<xsl:strip-space elements="*"/>

	<!--
  <xsl:include href="algebra2txt.module.xslt" />
  <xsl:include href="algebra2tex.module.xslt" />
  <xsl:include href="algebra2type.module.xslt" />
--> 

	<xsl:include href="../../algebraLibrary/algebra2.initial_enrichment.module.xslt"/>

	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="yes"/>


	<xsl:template match="id[not(gat:type)][child::cc:*/gat:type]" 
			mode="initial_enrichment_recursive">
		<xsl:copy>
			<xsl:apply-templates mode="copy"/>
			<gat:type>
				<!-- add typecheck here that childtype is an instance of "Ob" -->
				<Hom>
					<xsl:copy-of select="cc:*"/>
					<xsl:copy-of select="cc:*"/>
				</Hom>
			</gat:type>
		</xsl:copy>
	</xsl:template>		

	<xsl:template match="o[not(gat:type)]
		[every $subterm in child::cc:* satisfies $subterm/gat:type]" 
			mode="initial_enrichment_recursive">
		<xsl:copy>
			<xsl:apply-templates mode="copy"/>
			<gat:type>
				<!-- add typechecking here ? -->
				<Hom>
					<xsl:copy-of select="cc:*[1]/gat:type/cc:Hom/cc:*[1]"/>
					<xsl:copy-of select="cc:*[2]/gat:type/cc:Hom/cc:*[2]"/>
				</Hom>
			</gat:type>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="p[not(gat:type)][child::cc:*/gat:type]" 
			mode="initial_enrichment_recursive">
		<xsl:copy>
			<xsl:apply-templates mode="copy"/>
			<gat:type>
				<!-- add typecheck here that childtype is an instance of "Ob" -->
				<Hom>
					<xsl:copy-of select="cc:*"/>
					<xsl:copy-of select="cc:*/gat:type/cc:Ob/cc:*"/>  <!-- WARNING -not sure we can rely on this being here -->
				</Hom>
			</gat:type>
		</xsl:copy>
	</xsl:template>


	<xsl:template match="star[not(gat:type)]
		[every $subterm in child::cc:* satisfies $subterm/gat:type]" 
			mode="initial_enrichment_recursive">
		<xsl:copy>
			<xsl:apply-templates mode="copy"/>
			<gat:type>
				<!-- add typechecking here ? -->
				<Ob>
					<xsl:copy-of select="cc:*[1]/gat:type/cc:Hom/cc:*[1]"/>
				</Ob>
			</gat:type>
		</xsl:copy>
	</xsl:template>


	<xsl:template match="q[not(gat:type)]
		[every $subterm in child::cc:* satisfies $subterm/gat:type]" 
			mode="initial_enrichment_recursive">
		<xsl:copy>
			<xsl:apply-templates mode="copy"/>
			<gat:type>
				<!-- add typechecking here ? -->
				<Hom>
					<star>
						<xsl:copy-of select="cc:*[1]"/>
						<xsl:copy-of select="cc:*[2]"/>
					</star>
					<xsl:copy-of select="cc:*[2]"/>
				</Hom>
			</gat:type>
		</xsl:copy>
	</xsl:template>



	<xsl:template match="s[not(gat:type)][child::cc:*/gat:type]" 
			mode="initial_enrichment_recursive"  >
		<xsl:variable name="childtype" select="child::cc:*/gat:type"/>
		<xsl:call-template name="s_typed">
			<xsl:with-param name="arg1type" select="$childtype"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="s" name="s_typed" mode="explicit">
		<xsl:param name="arg1type" as="node()"/>
		<xsl:copy>
			<xsl:apply-templates mode="copy"/>
			<gat:type>
				<Hom>
					<xsl:copy-of select="$arg1type/cc:Hom/cc:*[1]"/>
					<star>
						<xsl:copy-of select="child::cc:*"/>
						<star>
							<p>
								<xsl:copy-of select="$arg1type/cc:Hom/cc:*[2]"/>
							</p>
							<xsl:copy-of select="$arg1type/cc:Hom/cc:*[2]"/>
						</star>
					</star>				
				</Hom>
			</gat:type>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*" mode="copy">
		<xsl:copy copy-namespaces="no">
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="copy"/>
		</xsl:copy>
	</xsl:template>


</xsl:transform>

