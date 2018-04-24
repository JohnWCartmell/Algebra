call %~dp0\set_path_variables


set THEORY=%1


java -jar %SAXON_PATH%\saxon9he.jar  -s:%THEORY%\temp\diamonds.correlated.xml -xsl:%THEORY%\theory\main.xslt -im:diamond_filter -o:%THEORY%/temp/diamonds.filtered.xml
