call %~dp0\set_path_variables

set THEORY=%1

java -jar %SAXON_PATH%\saxon9he.jar -opt:0 -s:%THEORY%/theory/test.xml -xsl:%THEORY%/theory/test.xslt -o:%THEORY%/theory/temp/test.out.xml
