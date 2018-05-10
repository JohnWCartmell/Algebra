call %~dp0\set_path_variables


set THEORY=%1

set ITERATION=%2

set INTERIM=%3


java -jar %SAXON_PATH%\saxon9he.jar  -s:%THEORY%\temp\diamonds%ITERATION%.%INTERIM%.xml -xsl:%THEORY%\theory\main.xslt -im:structured_text -o:%THEORY%/docs/diamonds%ITERATION%.%INTERIM%.text.xml
