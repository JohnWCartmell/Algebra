call %~dp0\set_path_variables


set THEORY=%1

set ITERATION=%2


java -jar %SAXON_PATH%\saxon9he.jar -opt:0 -s:%THEORY%\temp\diamonds%ITERATION%.filtered.xml -xsl:%THEORY%/temp/rewrite%ITERATION%.module.xslt -im:grow_diamond -o:%THEORY%/temp/diamonds%ITERATION%.grown.xml
