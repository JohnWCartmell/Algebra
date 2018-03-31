remcall %~dp0\set_path_variables

set THEORY=%1

java -jar ..\..\Scripting\thirdparty\SaxonHE9-8-0-11J\saxon9he.jar -opt:0 -s:%THEORY%/theory/algebra.xml -xsl:%THEORY%\..\algebraLibrary\JCproblem_template.xslt -o:problem.out.xml


