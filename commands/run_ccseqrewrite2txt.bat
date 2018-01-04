call %~dp0\set_path_variables

java -jar %SAXON_PATH%\saxon9he.jar -s:ccseq\theory\ccseqRewriteRules.xml -xsl:ccseq\theory\ccseq.main.xslt -im:text -o:temp/ccseq_text.txt





