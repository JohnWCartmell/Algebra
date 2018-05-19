call %~dp0\set_path_variables


set THEORY=%1

set ITERATION=%2

if not exist "%THEORY%\temp\iteration%ITERATION%\grown_diamonds" mkdir %THEORY%\temp\iteration%ITERATION%\grown_diamonds

java -jar %SAXON_PATH%\saxon9he.jar -opt:0 -s:%THEORY%/temp/iteration%ITERATION%/filtered_diamonds ^
                                           -xsl:%THEORY%/temp/rewrite%ITERATION%.module.xslt -im:grow_diamond ^
										   -o:%THEORY%/temp/iteration%ITERATION%/grown_diamonds
