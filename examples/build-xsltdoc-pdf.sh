#!/bin/sh
# build-xsltdoc-pdf.sh - Builds sample PDF output
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
# Check for "wkhtmltopdf".

PATH_WKHTMLTOPDF=`which wkhtmltopdf 2> /dev/null`

if [ "x$PATH_WKHTMLTOPDF" == "x" ]; then
    echo Error: wkhtmltopdf is needed
    exit 1
fi
if [ \! -x $PATH_WKHTMLTOPDF ]; then
    echo Error: wkhtmltopdf is needed
    exit 1
fi
echo Using $PATH_WKHTMLTOPDF

#---------------------------------------------------------------------
# Rebuild HTML output.

$PATH_XSLTPROC ../xmldoc2html.xsl \
    API_Reference.xml > \
    API_Reference.html              || exit 1

#---------------------------------------------------------------------
# Rebuild PDF output using HTML output.

$PATH_WKHTMLTOPDF \
    -s Letter -L 7 -R 0 -T 0 -B 0 \
    API_Reference.html \
    API_Reference.pdf               || exit 1

#---------------------------------------------------------------------
# Wrap it up.

echo Done
