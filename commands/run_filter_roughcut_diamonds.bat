call %~dp0\set_path_variables


set THEORY=%1


java -jar %SAXON_PATH%\saxon9he.jar -opt:0 -s:%THEORY%\docs\roughcut_diamonds.xml -xsl:%THEORY%\theory\main.xslt -im:filter_roughcut_diamonds -o:%THEORY%/docs/firstcut_diamonds.xml
