call %~dp0\set_path_variables


set THEORY=%1

java -jar %SAXON_PATH%\saxon9he.jar -s:%THEORY%/theory/algebra.xml -xsl:algebraLibrary\rules2.initial_enrichment.module.xslt -o:%THEORY%/theory/temp/rewrite.enriched.xml

java -jar %SAXON_PATH%\saxon9he.jar -s:%THEORY%\theory\temp\rewrite.enriched.xml -xsl:%THEORY%\theory\main.xslt -im:prepare_diamonds -o:%THEORY%/docs/diamonds.xml
