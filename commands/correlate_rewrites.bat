call %~dp0\set_path_variables


set THEORY=%1

set ITERATION=%2


java -jar %SAXON_PATH%\saxon9he.jar -opt:0 -s:%THEORY%/temp/iteration%ITERATION%/grown_diamonds/algebra.xml ^
                                           -xsl:%THEORY%/theory/main.xslt -im:correlate_rewrites ^
										   -o:%THEORY%/temp/diamonds%ITERATION%.grown.correlated.xml
