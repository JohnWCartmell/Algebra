call %~dp0\set_path_variables


set THEORY=%1

set ITERATION=%2

set DIAMOND=%3

if not exist "%THEORY%\temp\iteration%ITERATION%\typecorrected" mkdir %THEORY%\temp\iteration%ITERATION%\typecorrected

TIME /T
java -jar %SAXON_PATH%\saxon9he.jar  -opt:0 -s:%THEORY%/temp/iteration%ITERATION%/roughcut ^
                    -xsl:%THEORY%/temp/rewrite%ITERATION%.module.xslt -im:type_correction ^
					-o:%THEORY%/temp/iteration%ITERATION%/typecorrected diamond_selection_pattern=%DIAMOND%

TIME /T
