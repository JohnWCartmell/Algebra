call %~dp0\set_path_variables

set THEORY=%1

java -jar %SAXON_PATH%\saxon9he.jar -s:%THEORY%/theory/algebra.xml -xsl:%THEORY%/theory/main_initial_enrichment.xslt -o:%THEORY%/theory/temp/algebra.enriched.xml

rem java -jar %SAXON_PATH%\saxon9he.jar -s:%THEORY%/theory/temp/algebra.enriched.xml -xsl:algebraLibrary\seqrules2xslt.xslt -o:%THEORY%/theory/temp/rewrite.module.xslt






