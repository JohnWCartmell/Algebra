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


  <xsl:template match="o[not(gat:type)]
      [every $subterm in child::ccseq:* satisfies $subterm/gat:type]" 
      mode="initial_enrichment_recursive">
    <xsl:copy>
      <xsl:apply-templates mode="copy_tidily"/>
      <gat:type>
        <!-- typechecking -->
        <xsl:for-each select="ccseq:*[following-sibling::ccseq:*]">
          <xsl:variable name="cod_text">
            <xsl:apply-templates mode="text" select="gat:type/(Hom|HomSeq)/ccseq:*[2]"/>
          </xsl:variable>
          <xsl:variable name="dom_text">
            <xsl:apply-templates mode="text" select="following-sibling::ccseq:*[1]/gat:type/(Hom|HomSeq)/ccseq:*[1]"/>
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
                domain of subterm <xsl:value-of select="count(preceding-sibling::ccseq:*) + 2"/> is <xsl:value-of select="$dom_text"/> which is is not identical
                to codomain of preceding subterm which is <xsl:value-of select="$cod_text"/></gat:description>
            </gat:type_error>    

          </xsl:if>
        </xsl:for-each>
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
      <xsl:apply-templates mode="copy_tidily"/>
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
      <xsl:apply-templates mode="copy_tidily"/>
      <gat:type>
        <!-- add typechecking here ? -->
        <Ob>
          <xsl:copy-of select="ccseq:*[1]/gat:type/(ccseq:Hom|ccseq:HomSeq)/ccseq:*[1]"/>
        </Ob>
      </gat:type>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="q[not(gat:type)]
      [every $subterm in child::ccseq:* satisfies $subterm/gat:type]" 
      mode="initial_enrichment_recursive">
    <xsl:copy>
      <xsl:apply-templates mode="copy_tidily"/>
      <gat:type>
        <!-- add typechecking here ? -->
        <!-- to normalise we just need to normalise the domain -->
        <xsl:variable name="domain" as="element(gat:term)">
          <gat:term>
            <star>
              <xsl:copy-of select="ccseq:*[1]"/>
              <xsl:copy-of select="ccseq:*[2]"/>
            </star>
          </gat:term>
        </xsl:variable>
        <xsl:variable name="domain_term_normalised" as="element(gat:term)">
          <xsl:apply-templates mode="normalise" select="$domain"/>
        </xsl:variable>
        <xsl:if test="$domain_term_normalised/*[self::gat:term]">
          <xsl:message terminate="yes">Gotcha, you <xsl:value-of select="$domain_term_normalised/*/name()"/>!</xsl:message>
        </xsl:if>
        <Hom>
          <xsl:copy-of select="$domain_term_normalised/ccseq:*"/>   <!-- tuesday 13 Fevb 19:43 -->
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
      <xsl:apply-templates mode="copy_tidily"/>
      <gat:type>
        <!-- to normalise we just need to normalise the codomain -->
        <xsl:variable name="codomain">
          <gat:term>
            <star>
              <xsl:copy-of select="child::ccseq:*"/>
              <star>
                <p>
                  <xsl:copy-of select="$arg1type/(ccseq:Hom|ccseq:Homseq)/ccseq:*[2]"/>
                </p>
                <xsl:copy-of select="$arg1type/(ccseq:Hom|ccseq:Homseq)/ccseq:*[2]"/>
              </star>
            </star>	
          </gat:term>
        </xsl:variable>
        <xsl:variable name="codomain_term_normalised">
          <xsl:apply-templates mode="normalise" select="$codomain"/>
        </xsl:variable>
        <Hom>
          <xsl:copy-of select="$arg1type/(ccseq:Hom|ccseq:Homseq)/ccseq:*[1]"/>
          <xsl:copy-of select="$codomain_term_normalised/gat:term/ccseq:*"/>  <!-- 19:37 13 feb 2018 add ccseq: -->
        </Hom>
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

