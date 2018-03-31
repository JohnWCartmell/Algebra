call ..\..\..\commands\set_path_variables.bat

java -jar %SAXON_PATH%\saxon9he.jar -opt:0 -s:termsToNormalise.xml -xsl:..\..\theory\main.xslt -im:normalise -o:temp/normalisation.out.xml




