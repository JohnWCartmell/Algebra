call ..\..\..\commands\set_path_variables.bat

java -jar %SAXON_PATH%\saxon9he.jar -s:termsToNormalise.xml -xsl:..\..\theory\ccseq.main.xslt -im:normalise -o:temp/normalisation.out.xml




