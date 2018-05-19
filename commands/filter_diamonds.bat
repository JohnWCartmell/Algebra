call %~dp0\set_path_variables


set THEORY=%1

set ITERATION=%2

if not exist "%THEORY%\temp\iteration%ITERATION%\filtered_diamonds" mkdir %THEORY%\temp\iteration%ITERATION%\filtered_diamonds

java -jar %SAXON_PATH%\saxon9he.jar  -s:%THEORY%/temp/iteration%ITERATION%/correlated_diamonds ^
                                     -xsl:%THEORY%/theory/main.xslt -im:diamond_filter ^
									 -o:%THEORY%/temp/iteration%ITERATION%/filtered_diamonds
