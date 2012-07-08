<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0">

<!-- ============================================================= -->
<!-- File:            xmldoc2html.xsl                              -->
<!-- Purpose:         Converts XML documentation to HTML           -->
<!-- Original author: Robert Kiraly from http://oldcoder.org/      -->
<!-- License:         MIT/X                                        -->
<!-- Revision:        120707                                       -->
<!-- ============================================================= -->

<!-- <![CDATA[

xmldoc2html.xsl notes                                  Revised: 120707
======================================================================

1. Overview.

This is a simple XSLT stylesheet  that converts  XML-format documenta-
tion to HTML format. The HTML output is styled by embedded CSS code.

Presently, the stylesheet is written in XSLT 1;  i.e., it doesn't rely
on XSLT 2 features.  Therefore, it should work with most standard XSLT
processors, including "xsltproc".

======================================================================

2. XML core input elements.

The following  XML input elements  should be  sufficient for many pur-
poses:

code        - Defines a block of code. Used as follows:

              <code>lines of code</code>

              For HTML, maps to a CSS-styled  "div" named "code".  For
              DokuWiki, maps to ''lines of code''.

function    - Defines a function block. Used as follows:

              <function name="foo">
                  related elements go here
              </function>

              For HTML,  maps to a  CSS-styled  "div" named "function"
              that includes a  function-name line.  For DokuWiki, maps
              to a "=== name ===" block.

label       - Defines text that should be treated as a label;  i.e., a
              name that should be emphasized. Used as follows:

              <label name="x_counter" />

              For HTML, maps to a CSS-styled "span" named "label". For
              DokuWiki, maps to **name**.

link        - Defines a hyperlink. Used as follows:

              <link target="http://foo/" name="Short description" />

              For HTML, maps to a standard  "<a>" element.  For  Doku-
              Wiki, maps to a "[[target|name]]" construct.

note        - Defines text that should be treated as a note (for exam-
              ple, as an FYI or a warning). Used as follows:

              <note>One or more lines of text</note>

              For HTML, maps to a CSS-styled "span" named "note".  For
              DokuWiki, maps to //text//.

section     - Defines a section block. Used as follows:

              <section title="Popular Recipes">
                  <section title="Meat">
                      ...
                  </section>
                  <section title="Vegetarian">
                      ...
                  </section>
              </section>

              For HTML,  maps to a  CSS-styled  "div" named  "section"
              that includes a section-name line.

              For DokuWiki,  maps to a  "=== foo ===" block  with  the
              appropriate  number of "equals" signs determined automa-
              tically.

text        - Defines a block of text. Used as follows:

              <text>One or more lines of text.</text>

              For HTML, maps to a  CSS-styled "div" named "text".  For
              DokuWiki, simply produces  a block  of text followed  by
              two newlines.

xterm       - Multi-purpose element. Used as follows:

              <xterm>one or more lines of text</xterm>

              For HTML,  maps  to a  CSS-styled  "div" named  "xterm".
              For DokuWiki, maps to a DokuWiki "<xterm>" block.  Note:
              This feature requires the "xterm" plugin for "DokuWiki".

======================================================================

3. Additional XML input elements.

The following XML input elements are also supported:

cproto      - (Deprecated by "proto".) Defines a 'C' prototype defini-
              tion block. Used as follows:

              <cproto>lines of code</cproto>

              For HTML,  maps  to a  CSS-styled  "div" named "cproto".
              For DokuWiki, maps to:

              <xterm>%%lines of code%%</xterm>
              two newlines

              Note: This feature requires the "xterm" plugin for "Dok-
              uWiki".

desc        - Presently, equivalent to "text".

namedvar    - Presently, equivalent to "label".

proto       - Defines  a  programming  language  prototype  definition
              block. Used as follows:

              <proto lang="c">lines of code</proto>

              For HTML,  maps  to a  CSS-styled  "div" named  "proto".
              For DokuWiki, maps to:

              <xterm>%%lines of code%%</xterm>
              two newlines

              Note: This feature requires the "xterm" plugin for "Dok-
              uWiki".

======================================================================

4. Using this stylesheet.

To use this stylesheet under Linux,  execute an "xsltproc" CLI command
of the following form:

      xsltproc xmldoc2html.xsl input.xml > output.html

"Xalan" should also work.  Note that the order of the arguments is re-
versed for "Xalan":

      Xalan    input.xml xmldoc2html.xsl > output.html

]]> -->

<!-- ============================================================= -->
<!-- XSLT directives.                                              -->
<!-- ============================================================= -->

<!-- <![CDATA[
This section  uses one or more  XSLT directives to  configure the XSLT
processor used.  Not every  XSLT processor will support  every  direc-
tive.
]]> -->

<xsl:output method="text" indent="no" />
<xsl:output method="xml" omit-xml-declaration="yes" />
<xsl:strip-space elements="*" />

<!-- ============================================================= -->
<!-- Main program.                                                 -->
<!-- ============================================================= -->

<!-- <![CDATA[
You can think of this as  the "main program".  It  sets up the overall
structure of the output file.
]]> -->

<xsl:template match="/">
<html><xsl:text>&#10;</xsl:text>
<head><xsl:text>&#10;</xsl:text>
<title>API documentation</title><xsl:text>&#10;</xsl:text>
<style type="text/css">
<xsl:text disable-output-escaping="yes">&#60;</xsl:text>!--
body {
    background-color:   white;
    font-size:          1.2em;
    margin-left:        60px;
    margin-right:       60px;
    margin-top:         20px;
    margin-bottom:      20px;
}
.label {
    font-weight:        bold;
}
.note {
    font-style:         italic;
}
div.code {
    font-family:        Inconsolata,courier,fixed;
    font-size:          0.9em;
    white-space:        pre;
    background-color:   #c0c0c0;
}
div.cproto {
    font-family:        Inconsolata,courier,fixed;
    font-size:          0.9em;
    white-space:        pre;
    background-color:   #c0c0c0;
}
div.function {
}
div.proto {
    font-family:        Inconsolata,courier,fixed;
    font-size:          0.9em;
    white-space:        pre;
    background-color:   #c0c0c0;
}
div.secttitle {
    color:              #008800;
    font-weight:        bold;
    font-size:          1.5em;
    text-align:         center;
}
div.text {
    text-align:         justify;
}
div.xterm {
    font-family:        Inconsolata,courier,fixed;
    font-size:          0.9em;
    white-space:        pre;
    background-color:   #c0c0c0;
}
--<xsl:text disable-output-escaping="yes">&#62;</xsl:text>
</style><xsl:text>&#10;</xsl:text>
</head><xsl:text>&#10;</xsl:text>
<body>
<xsl:apply-templates/>
<xsl:text>&#10;</xsl:text>
</body><xsl:text>&#10;</xsl:text>
</html>
</xsl:template>

<!-- ============================================================= -->
<!-- Handle simple cases.                                          -->
<!-- ============================================================= -->

<!-- <![CDATA[
This part handles simple XML elements; specifically XML elements with-
out attributes.
]]> -->

<xsl:template match="code">
<xsl:text>&#10;</xsl:text>
<div class="code"><xsl:apply-templates /></div>
<xsl:text>&#10;</xsl:text>
</xsl:template>

<xsl:template match="cproto">
<xsl:text>&#10;</xsl:text>
<div class="cproto"><xsl:apply-templates /></div>
<xsl:text>&#10;</xsl:text>
</xsl:template>

<xsl:template match="desc">
<xsl:text>&#10;</xsl:text>
<div class="text">
<xsl:text>&#10;</xsl:text>
<p><xsl:apply-templates /></p></div>
<xsl:text>&#10;</xsl:text>
</xsl:template>

<xsl:template match="label">
<span class="label"><xsl:apply-templates /></span>
</xsl:template>

<xsl:template match="namedvar">
<span class="label"><xsl:apply-templates /></span>
</xsl:template>

<xsl:template match="note">
<span class="note"><xsl:apply-templates /></span>
</xsl:template>

<xsl:template match="proto">
<xsl:text>&#10;</xsl:text>
<div class="proto"><xsl:apply-templates /></div>
<xsl:text>&#10;</xsl:text>
</xsl:template>

<xsl:template match="text">
<xsl:text>&#10;</xsl:text>
<div class="text">
<xsl:text>&#10;</xsl:text>
<p><xsl:apply-templates /></p></div>
<xsl:text>&#10;</xsl:text>
</xsl:template>

<xsl:template match="xterm">
<xsl:text>&#10;</xsl:text>
<div class="xterm"><xsl:apply-templates /></div>
<xsl:text>&#10;</xsl:text>
</xsl:template>

<!-- ============================================================= -->
<!-- Handle "function" elements.                                   -->
<!-- ============================================================= -->

<xsl:template match="function">
<xsl:text>&#10;</xsl:text>
<p></p><hr/><p></p>
<xsl:text>&#10;</xsl:text>
<div class="function">
<xsl:text>&#10;</xsl:text>
<p><font size="5" color="#818100"><b>Function: </b></font>
<xsl:value-of select="@name"/>
</p>
<xsl:apply-templates />
</div>
<xsl:text>&#10;</xsl:text>
</xsl:template>

<!-- ============================================================= -->
<!-- Handle "link" elements.                                       -->
<!-- ============================================================= -->

<xsl:template match="link">
<xsl:text>&#10;</xsl:text>
<a>
<xsl:attribute name="href">
<xsl:value-of select="@target" />
</xsl:attribute>
<xsl:value-of select="@name" />
</a>
</xsl:template>

<!-- ============================================================= -->
<!-- Handle "section" elements.                                    -->
<!-- ============================================================= -->

<xsl:template match="section">
<xsl:text>&#10;</xsl:text>
<p></p><hr/><p></p>
<xsl:text>&#10;</xsl:text>
<div class="section">
<xsl:text>&#10;</xsl:text>
<div class="secttitle">
<xsl:text>&#10;</xsl:text>
<p><xsl:value-of select="@title"/></p>
<xsl:text>&#10;</xsl:text>
</div>
<xsl:text>&#10;</xsl:text>
<xsl:apply-templates />
</div>
<xsl:text>&#10;</xsl:text>
</xsl:template>

<!-- ============================================================= -->
<!-- End of stylesheet.                                            -->
<!-- ============================================================= -->

</xsl:stylesheet>
