call %~dp0\set_path_variables

set THEORY=%1

java -jar %SAXON_PATH%\saxon9he.jar -s:%THEORY%/theory/rewriteRules.xml -xsl:algebraLibrary\rules2.initial_enrichment.module.xslt -o:%THEORY%/theory/temp/rewrite.enriched.xml

java -jar %SAXON_PATH%\saxon9he.jar -s:%THEORY%/theory/temp/rewrite.enriched.xml -xsl:algebraLibrary\seqrules2xslt.xslt -o:%THEORY%/theory/temp/rewrite.module.xslt






