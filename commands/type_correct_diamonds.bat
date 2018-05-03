call %~dp0\set_path_variables


set THEORY=%1
set DIAMOND=%2

TIME /T
java -jar %SAXON_PATH%\saxon9he.jar  -opt:0 -s:%THEORY%/temp/diamonds.roughcut.xml -xsl:%THEORY%\theory\main_with_rewrite.xslt -im:type_correction -o:%THEORY%/temp/diamonds.typed.xml diamond_selection_pattern=%DIAMOND%
TIME /T
