call %~dp0\set_path_variables

java -jar %SAXON_PATH%\saxon9he.jar -s:ccseq\theory\ccseqRewriteRules.xml -xsl:algebraLibrary\rules2.initial_enrichment.module.xslt -o:temp/ccseqRewrite.enriched.xml

java -jar %SAXON_PATH%\saxon9he.jar -s:temp/ccseqRewrite.enriched.xml -xsl:algebraLibrary\seqrules2xslt.xslt -o:temp/ccseqRewrite.module.xslt






