#!/bin/bash
cd `dirname $0`
ls -1 ead *.xml | while read ead
do
	echo -n $ead ": "
	if [ -f "./rico{$ead}" ]
	then
		echo SKIP
	else
		xsltproc ../../xsl/ead2rico.xsl ead/$ead | tidy -xml -utf8 -indent -wrap 90 -q > ./rico/$ead
		test $? -eq 0 || rm ./rico/$ead
		echo DONE
	fi
done