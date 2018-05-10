call %~dp0\set_path_variables


set THEORY=%1

set ITERATION=%2


set DIAMOND=%3

TIME /T
java -jar %SAXON_PATH%\saxon9he.jar  -opt:0 -s:%THEORY%/temp/diamonds%ITERATION%.roughcut.xml -xsl:%THEORY%/temp/rewrite%ITERATION%.module.xslt -im:type_correction -o:%THEORY%/temp/diamonds%ITERATION%.typed.xml diamond_selection_pattern=%DIAMOND%
TIME /T
