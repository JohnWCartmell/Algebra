call %~dp0\set_path_variables


set THEORY=%1

set INTERIM=%2


java -jar %SAXON_PATH%\saxon9he.jar  -s:%THEORY%\temp\diamonds.%INTERIM%.xml -xsl:%THEORY%\theory\main.xslt -im:structured_text -o:%THEORY%/docs/diamonds.%INTERIM%.text.xml
