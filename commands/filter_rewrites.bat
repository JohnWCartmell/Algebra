call %~dp0\set_path_variables


set THEORY=%1


java -jar %SAXON_PATH%\saxon9he.jar  -s:%THEORY%\temp\diamonds.grown.correlated.xml -xsl:%THEORY%\theory\main.xslt -im:rewrite_filter -o:%THEORY%/temp/rewrites.xml
