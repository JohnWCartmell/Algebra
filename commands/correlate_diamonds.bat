call %~dp0\set_path_variables


set THEORY=%1


java -jar %SAXON_PATH%\saxon9he.jar  -s:%THEORY%\temp\diamonds.typed.xml -xsl:%THEORY%\theory\main.xslt -im:correlate_diamonds -o:%THEORY%/temp/diamonds.correlated.xml
