call %~dp0\set_path_variables

set THEORY=%1

set ITERATION=%2

if not exist "%THEORY%\temp\iteration%ITERATION%" mkdir %THEORY%\temp\iteration%ITERATION%

java -jar %SAXON_PATH%/saxon9he.jar  -s:%THEORY%/temp/algebra%ITERATION%.enriched.xml  ^
                                     -opt:0 -xsl:%THEORY%/temp/rewrite%ITERATION%.module.xslt -im:prepare_roughcut_diamonds ^
									 -o:%THEORY%/temp/iteration%ITERATION%/roughcut/algebra.xml
