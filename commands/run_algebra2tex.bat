call %~dp0\set_path_variables

set THEORY=%1

java -jar %SAXON_PATH%\saxon9he.jar -opt:0 -s:%THEORY%/theory/algebra.xml -xsl:%THEORY%/theory/main_initial_enrichment.xslt -o:%THEORY%/temp/algebra.enriched.xml

java -jar %SAXON_PATH%\saxon9he.jar -s:%THEORY%/temp/algebra.enriched.xml -xsl:algebraLibrary\seqrules2xslt.xslt -o:%THEORY%/temp/rewrite.module.xslt

java -jar %SAXON_PATH%\saxon9he.jar -opt:0 -s:%THEORY%/temp/algebra.enriched.xml -xsl:%THEORY%/temp/rewrite.module.xslt -im:type_enrich -o:%THEORY%/temp/algebra.type_enriched.xml

java -jar %SAXON_PATH%\saxon9he.jar -s:%THEORY%/temp/algebra.type_enriched.xml -xsl:%THEORY%/theory/main.xslt -im:tex_rulestyle -o:%THEORY%/docs/algebra.tex
