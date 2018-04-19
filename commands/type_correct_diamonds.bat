call %~dp0\set_path_variables


set THEORY=%1


java -jar %SAXON_PATH%\saxon9he.jar  -s:%THEORY%/temp/diamonds.roughcut.xml -xsl:%THEORY%\theory\main.xslt -im:type_correction -o:%THEORY%/temp/diamonds.typed.xml
