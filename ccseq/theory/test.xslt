<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		version="2.0"
		xpath-default-namespace="">
		
	<xsl:template  match="a">
	    <xsl:message><xsl:value-of select="description"/></xsl:message>
		<xsl:variable name="b" as="element()*" select="b"/>
		<xsl:variable name="gapsize" as="xs:integer*" select="(0 to 10)"/>
		<xsl:variable name="c" as="element()*" select="$b/following-sibling::*[$gapsize][self::c]"/>

		<xsl:message>Count of b is <xsl:value-of select="count($b)"/></xsl:message>
		<xsl:message>Count of c is <xsl:value-of select="count($c)"/></xsl:message>
	</xsl:template>

</xsl:transform>