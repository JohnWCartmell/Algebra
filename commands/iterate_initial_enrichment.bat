call %~dp0\set_path_variables

set THEORY=%1
set ITERATION=%2

java -jar %SAXON_PATH%\saxon9he.jar -opt:0 -s:%THEORY%/temp/algebra%ITERATION%.xml -xsl:%THEORY%/theory/main_initial_enrichment.xslt -o:%THEORY%/temp/algebra%ITERATION%.enriched.xml

java -jar %SAXON_PATH%\saxon9he.jar -s:%THEORY%/temp/algebra%ITERATION%.enriched.xml -xsl:algebraLibrary\seqrules2xslt.xslt -o:%THEORY%/temp/rewrite%ITERATION%.module.xslt

java -jar %SAXON_PATH%\saxon9he.jar -opt:0 -s:%THEORY%/temp/algebra%ITERATION%.enriched.xml -xsl:%THEORY%/temp/rewrite%ITERATION%.module.xslt -im:type_enrich -o:%THEORY%/temp/algebra%ITERATION%.type_enriched.xml

java -jar %SAXON_PATH%\saxon9he.jar -opt:0 -s:%THEORY%\temp\algebra%ITERATION%.type_enriched.xml -xsl:%THEORY%\theory\main.xslt -im:tex_rulestyle -o:%THEORY%/docs/algebra%ITERATION%.tex

