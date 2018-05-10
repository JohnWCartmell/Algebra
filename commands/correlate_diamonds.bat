call %~dp0\set_path_variables

set THEORY=%1

set ITERATION=%2

TIME /T
java -jar %SAXON_PATH%\saxon9he.jar  -s:%THEORY%\temp\diamonds%ITERATION%.typed.xml -xsl:%THEORY%\theory\main.xslt -im:correlate_diamonds -o:%THEORY%/temp/diamonds%ITERATION%.correlated.xml
TIME /T
