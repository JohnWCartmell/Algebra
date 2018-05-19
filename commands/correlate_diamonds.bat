call %~dp0\set_path_variables

set THEORY=%1

set ITERATION=%2

if not exist "%THEORY%\temp\iteration%ITERATION%\correlated_diamonds" mkdir %THEORY%\temp\iteration%ITERATION%\correlated_diamonds

TIME /T
java -jar %SAXON_PATH%\saxon9he.jar  -s:%THEORY%/temp/iteration%ITERATION%/typecorrected ^
                                     -xsl:%THEORY%\theory\main.xslt -im:correlate_diamonds ^
									 -o:%THEORY%/temp/iteration%ITERATION%/correlated_diamonds
TIME /T
