call %~dp0\set_path_variables


set THEORY=%1

java -jar %SAXON_PATH%\saxon9he.jar -s:%THEORY%\theory\rewriteRules.xml -xsl:%THEORY%\theory\main.xslt -im:prepare_diamonds -o:%THEORY%/docs/diamonds.xml
