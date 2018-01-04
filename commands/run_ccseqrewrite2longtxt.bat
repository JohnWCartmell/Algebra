call %~dp0\set_path_variables

java -jar %SAXON_PATH%\saxon9he.jar -s:ccseq\theory\ccseqRewriteRules.xml -xsl:ccseq\theory\ccseq.main.xslt -im:longtext -o:temp/ccseq_longText.txt






