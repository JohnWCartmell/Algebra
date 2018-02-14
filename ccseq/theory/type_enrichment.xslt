<xsl:transform version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:ccseq               ="http://www.entitymodelling.org/theory/contextualcategory/sequence"
    xmlns:gat              ="http://www.entitymodelling.org/theory/generalisedalgebraictheory"
    xpath-default-namespace="http://www.entitymodelling.org/theory/contextualcategory/sequence" 	   
    xmlns="http://www.entitymodelling.org/theory/contextualcategory/sequence" >

  <xsl:strip-space elements="*"/>

  <!--
  <xsl:include href="algebra2txt.module.xslt" />
  <xsl:include href="algebra2tex.module.xslt" />
  <xsl:include href="algebra2type.module.xslt" />
--> 
  <xsl:include href="temp/rewrite.module.xslt" />
  <xsl:include href="../../algebraLibrary/enrichedalgebra2.type_enrichment.module.xslt"/>
  <xsl:include href="../../algebraLibrary/gat.module.xslt"/>
  <xsl:include href="../../algebraLibrary/gat.rewrite.module.xslt"/>


  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="yes"/>

  <xsl:template match="id[not(gat:type)][child::ccseq:*/gat:type]" 
      mode="initial_enrichment_recursive">
    <xsl:copy>
      <xsl:apply-templates mode="copy"/>
      <gat:type>
        <!-- add typecheck here that childtype is an instance of "Ob" -->
        <Hom>
          <xsl:copy-of select="ccseq:*"/>
          <xsl:copy-of select="ccseq:*"/>
        </Hom>
      </gat:type>
    </xsl:copy>
  </xsl:template>	


  <xsl:template match="o[not(gat:type)]
      [every $subterm in child::ccseq:* satisfies $subterm/gat:type]" 
      mode="initial_enrichment_recursive">
    <xsl:copy>
      <xsl:apply-templates mode="copy"/>
      <gat:type>
        <!-- add typechecking here ? -->
        <Hom>
          <xsl:copy-of select="ccseq:*[1]/gat:type/(ccseq:Hom|ccseq:HomSeq)/ccseq:*[1]"/>
          <xsl:copy-of select="ccseq:*[last()]/gat:type/(ccseq:Hom|ccseq:HomSeq)/ccseq:*[2]"/>
        </Hom>
      </gat:type>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="p[not(gat:type)][child::ccseq:*/gat:type]" 
      mode="initial_enrichment_recursive">
    <xsl:copy>
      <xsl:apply-templates mode="copy"/>
      <gat:type>
        <!-- add typecheck here that childtype is an instance of "Ob" -->
        <Hom>
          <xsl:copy-of select="ccseq:*"/>
          <xsl:copy-of select="ccseq:*/gat:type/ccseq:Ob/ccseq:*"/>  <!-- WARNING -not sure we can rely on this being here -->
        </Hom>
      </gat:type>
    </xsl:copy>
  </xsl:template>


  <xsl:template match="star[not(gat:type)]
      [every $subterm in child::ccseq:* satisfies $subterm/gat:type]" 
      mode="initial_enrichment_recursive">
    <xsl:copy>
      <xsl:apply-templates mode="copy"/>
      <gat:type>
        <!-- add typechecking here ? -->
        <Ob>
          <xsl:copy-of select="ccseq:*[1]/gat:type/ccseq:Hom/ccseq:*[1]"/>
        </Ob>
      </gat:type>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="q[not(gat:type)]
      [every $subterm in child::ccseq:* satisfies $subterm/gat:type]" 
      mode="initial_enrichment_recursive">
    <xsl:copy>
      <xsl:apply-templates mode="copy"/>
      <gat:type>
        <!-- add typechecking here ? -->
        <!-- to normalise we just need to normalise the domain -->
        <xsl:variable name="domain">
          <gat:term>
            <star>
              <xsl:copy-of select="ccseq:*[1]"/>
              <xsl:copy-of select="ccseq:*[2]"/>
            </star>
          </gat:term>
        </xsl:variable>
        <xsl:variable name="domain_term_normalised">
          <xsl:apply-templates mode="normalise" select="$domain"/>
        </xsl:variable>
        <Hom>
          <xsl:copy-of select="$domain_term_normalised/gat:term/ccseq:*"/>   <!-- tuesday 13 Fevb 19:43 -->
          <xsl:copy-of select="ccseq:*[2]"/>
        </Hom>
      </gat:type>
    </xsl:copy>
  </xsl:template>


  <xsl:template match="s[not(gat:type)][child::ccseq:*/gat:type]" 
      mode="initial_enrichment_recursive"  >
    <xsl:variable name="childtype" select="child::ccseq:*/gat:type"/>
    <xsl:call-template name="s_typed">
      <xsl:with-param name="arg1type" select="$childtype"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="s" name="s_typed" mode="explicit">
    <xsl:param name="arg1type" as="node()"/>
    <xsl:copy>
      <xsl:apply-templates mode="copy"/>
      <gat:type>
        <!-- to normalise we just need to normalise the codomain -->
        <xsl:variable name="codomain">
          <gat:term>
            <star>
              <xsl:copy-of select="child::ccseq:*"/>
              <star>
                <p>
                  <xsl:copy-of select="$arg1type/ccseq:Hom/ccseq:*[2]"/>
                </p>
                <xsl:copy-of select="$arg1type/ccseq:Hom/ccseq:*[2]"/>
              </star>
            </star>	
          </gat:term>
        </xsl:variable>
        <xsl:variable name="codomain_term_normalised">
          <xsl:apply-templates mode="normalise" select="$codomain"/>
        </xsl:variable>
        <Hom>
          <xsl:copy-of select="$arg1type/ccseq:Hom/ccseq:*[1]"/>
          <xsl:copy-of select="$codomain_term_normalised/gat:term/ccseq:*"/>  <!-- 19:37 13 feb 2018 add ccseq: -->
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

