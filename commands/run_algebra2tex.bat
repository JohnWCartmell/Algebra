call %~dp0\set_path_variables

set THEORY=%1
set ITERATION=%2

java -jar %SAXON_PATH%\saxon9he.jar -s:%THEORY%\temp\algebra%ITERATION%.type_enriched.xml -xsl:%THEORY%\theory\main.xslt -im:tex_rulestyle -o:%THEORY%/docs/algebra%ITERATION%.tex
