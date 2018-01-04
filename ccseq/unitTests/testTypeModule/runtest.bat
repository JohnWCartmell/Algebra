call ..\..\..\commands\set_path_variables.bat

java -jar %SAXON_PATH%\saxon9he.jar -s:test.xml -xsl:..\..\theory\main.xslt -im:annotate_with_type -o:temp/annotated.out.xml




