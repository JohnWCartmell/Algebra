call %~dp0\set_path_variables


set THEORY=%1


java -jar %SAXON_PATH%\saxon9he.jar  -s:%THEORY%\theory\temp\algebra.enriched.xml -xsl:%THEORY%\theory\main.xslt -im:prepare_roughcut_diamonds -o:%THEORY%/temp/diamonds.roughcut.xml
