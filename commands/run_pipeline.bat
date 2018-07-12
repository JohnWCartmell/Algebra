call %~dp0\set_path_variables

set THEORY=%1
set ITERATION=%2

if %ITERATION% EQU 0 COPY %THEORY%\theory\algebra.xml %THEORY%\temp\algebra0.xml

call %~dp0\iterate_initial_enrichment.bat %THEORY% %ITERATION%

call %~dp0\rewrite2.roughcutdiamonds.bat %THEORY% %ITERATION%

call %~dp0\type_correct_diamonds.bat %THEORY% %ITERATION%

call %~dp0\correlate_diamonds.bat %THEORY% %ITERATION%

call %~dp0\filter_diamonds.bat %THEORY% %ITERATION%

call %~dp0\grow_diamonds.bat %THEORY% %ITERATION%

call %~dp0\diamonds2.structured_text.bat %THEORY% %ITERATION% grown

call %~dp0\correlate_rewrites.bat %THEORY% %ITERATION%

call %~dp0\diamonds2.structured_text.bat %THEORY% %ITERATION% grown.correlated

call %~dp0\filter_rewrites.bat %THEORY% %ITERATION%



