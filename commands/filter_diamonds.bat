call %~dp0\set_path_variables


set THEORY=%1

set ITERATION=%2


java -jar %SAXON_PATH%\saxon9he.jar  -s:%THEORY%\temp\diamonds%ITERATION%.correlated.xml -xsl:%THEORY%\theory\main.xslt -im:diamond_filter -o:%THEORY%/temp/diamonds%ITERATION%.filtered.xml
