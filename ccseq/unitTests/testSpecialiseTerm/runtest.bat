call ..\..\..\commands\set_path_variables.bat

java -jar %SAXON_PATH%\saxon9he.jar -s:termpairs_for_specialisation.xml -xsl:..\..\theory\main.xslt -im:testspecialisation -o:temp/specialisation.out.xml





