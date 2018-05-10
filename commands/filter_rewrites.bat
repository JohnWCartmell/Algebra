call %~dp0\set_path_variables


set THEORY=%1
set ITERATION=%2

set /a SUCCESSOR=%ITERATION%+1

java -jar %SAXON_PATH%\saxon9he.jar  -s:%THEORY%\temp\diamonds%ITERATION%.grown.correlated.xml -xsl:%THEORY%\theory\main.xslt -im:rewrite_filter -o:%THEORY%/temp/algebra%SUCCESSOR%.xml include=algebra%ITERATION%.xml
