#!/bin/sh
# build-xsltdoc-examples.sh - Builds examples except for PDF output
# License:  MIT/X (for this file only)
# Revision: 120707

#---------------------------------------------------------------------
# Check for "xsltproc".

PATH_XSLTPROC=`which xsltproc 2> /dev/null`

if [ "x$PATH_XSLTPROC" == "x" ]; then
    echo Error: xsltproc is needed
    exit 1
fi
if [ \! -x $PATH_XSLTPROC ]; then
    echo Error: xsltproc is needed
    exit 1
fi
echo Using $PATH_XSLTPROC

#---------------------------------------------------------------------
# Rebuild DokuWiki output.

$PATH_XSLTPROC ../xmldoc2dokuwiki.xsl \
    API_Reference.xml > \
    API_Reference.dokuwiki          || exit 1

#---------------------------------------------------------------------
# Rebuild HTML output.

$PATH_XSLTPROC ../xmldoc2html.xsl \
    API_Reference.xml > \
    API_Reference.html              || exit 1

#---------------------------------------------------------------------
# Wrap it up.

echo Done
