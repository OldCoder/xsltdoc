<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0">

<!-- ============================================================= -->
<!-- File:            xmldoc2dokuwiki.xsl                          -->
<!-- Purpose:         Converts XML documentation to DokuWiki       -->
<!-- Original author: Robert Kiraly from http://oldcoder.org/      -->
<!-- License:         MIT/X                                        -->
<!-- Revision:        120707                                       -->
<!-- ============================================================= -->

<!-- <![CDATA[

xmldoc2dokuwiki.xsl                                    Revised: 120707
======================================================================

1. Overview.

This is a simple XSLT stylesheet  that converts  XML-format documenta-
tion to DokuWiki format.

Presently, the stylesheet is written in XSLT 1;  i.e., it doesn't rely
on XSLT 2 features.  Therefore, it should work with most standard XSLT
processors, including "xsltproc".

One feature may be worth noting. This stylesheet knows how to "escape"
the most  common  DokuWiki  markup sequences  if they happen  to occur
inside input-text nodes. For example, a 'C' declaration of the follow-
ing form:

      int **foo;

will be replaced with:

      int *////*foo;

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

      xsltproc xmldoc2dokuwiki.xsl input.xml > output.dokuwiki

"Xalan" should also work.  Note that the order of the arguments is re-
versed for "Xalan":

      Xalan    input.xml xmldoc2dokuwiki.xsl > output.dokuwiki
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
<!-- Global parameters and/or variables.                           -->
<!-- ============================================================= -->

<!-- <![CDATA[
$maxSectionMarks  specifies the maximum length of a  DokuWiki "===..."
construct.
]]> -->

<xsl:variable name="maxSectionMarks">6</xsl:variable>

<!-- ============================================================= -->
<!-- Main program.                                                 -->
<!-- ============================================================= -->

<!-- <![CDATA[
You can think of this as  the "main program".  It  sets up the overall
structure of the output file.
]]> -->

<xsl:template match="/">
    <xsl:apply-templates/>
</xsl:template>

<!-- ============================================================= -->
<!-- Edit text nodes.                                              -->
<!-- ============================================================= -->

<!-- <![CDATA[
This code performs  a series of edits to text nodes.  The purpose, for
this stylesheet,  is to "escape" DokuWiki constructs  such as // or **
or == that occur accidentally in the input text.

Note: The code used to perform the edits is rather complicated.  There
must be a simpler way to do this (even in XSLT 1), but I haven't found
it yet.

This code uses tricks discussed in XSL-List by Michael J. Brown and in
an article  named  "Comparing and  Replacing Strings" by  Bob DuCharme
(June 2002).
]]> -->

<xsl:template name="editTextNodeDokuWiki">
<xsl:param name="buffer"    />
<xsl:param name="oldstring" />
<xsl:param name="newstring" />
<xsl:param name="pass"      />

<xsl:choose>
    <xsl:when test="contains($buffer,$oldstring)">
        <xsl:call-template name="editTextNodeDokuWiki">
<xsl:with-param name="buffer"
    select="concat(concat(substring-before($buffer,$oldstring),
$newstring),substring-after($buffer,$oldstring))"               />
<xsl:with-param name="oldstring"     select="$oldstring"        />
<xsl:with-param name="newstring"     select="$newstring"        />
<xsl:with-param name="pass"          select="$pass"             />
        </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
        <xsl:choose>
            <xsl:when test="$pass = 1">
                <xsl:call-template name="editTextNodeDokuWiki">
<xsl:with-param name="buffer"        select="$buffer"           />
<xsl:with-param name="oldstring"     select="'**'"              />
<xsl:with-param name="newstring"     select="'*__META_4S__*'"   />
<xsl:with-param name="pass"          select="2"                 />
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$pass = 2">
                <xsl:call-template name="editTextNodeDokuWiki">
<xsl:with-param name="buffer"        select="$buffer"           />
<xsl:with-param name="oldstring"     select="'=='"              />
<xsl:with-param name="newstring"     select="'=__META_4A__='"   />
<xsl:with-param name="pass"          select="3"                 />
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$pass = 3">
                <xsl:call-template name="editTextNodeDokuWiki">
<xsl:with-param name="buffer"        select="$buffer"           />
<xsl:with-param name="oldstring"     select="'__META_SS__'"     />
<xsl:with-param name="newstring"     select="'/__META_4A__/'"   />
<xsl:with-param name="pass"          select="4"                 />
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$pass = 4">
                <xsl:call-template name="editTextNodeDokuWiki">
<xsl:with-param name="buffer"        select="$buffer"           />
<xsl:with-param name="oldstring"     select="'//'"              />
<xsl:with-param name="newstring"     select="'/__META_4A__/'"   />
<xsl:with-param name="pass"          select="5"                 />
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$pass = 5">
                <xsl:call-template name="editTextNodeDokuWiki">
<xsl:with-param name="buffer"        select="$buffer"           />
<xsl:with-param name="oldstring"     select="'__META_4A__'"     />
<xsl:with-param name="newstring"     select="'****'"            />
<xsl:with-param name="pass"          select="6"                 />
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$pass = 6">
                <xsl:call-template name="editTextNodeDokuWiki">
<xsl:with-param name="buffer"        select="$buffer"           />
<xsl:with-param name="oldstring"     select="'__META_4S__'"     />
<xsl:with-param name="newstring"     select="'////'"            />
<xsl:with-param name="pass"          select="7"                 />
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$buffer" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template match="text()">
<xsl:call-template name="editTextNodeDokuWiki">
<xsl:with-param name="buffer"        select="."                 />
<xsl:with-param name="oldstring"     select="'//'"              />
<xsl:with-param name="newstring"     select="'__META_SS__'"     />
<xsl:with-param name="pass"          select="1"                 />
</xsl:call-template>
</xsl:template>

<xsl:template match="@*|*">
<xsl:copy><xsl:apply-templates select="@*|node()"/></xsl:copy>
</xsl:template>

<!-- ============================================================= -->
<!-- Depth-indicator support routine.                              -->
<!-- ============================================================= -->

<!-- <![CDATA[
This template is used as a subroutine.  It takes a negative integer as
a parameter (named "copies"),  outputs one "equals" sign without white
space and/or newlines, and recurses,  incrementing the parameter until
the value reaches zero.
]]> -->

<xsl:template name="xcopy-n">
<xsl:param name="copies" />
<xsl:choose>
    <xsl:when test="$copies &lt; 0">
        <xsl:text>=</xsl:text>
        <xsl:call-template name="xcopy-n">
            <xsl:with-param name="copies" select="$copies + 1" />
        </xsl:call-template>
    </xsl:when>
</xsl:choose>
</xsl:template>

<!-- ============================================================= -->
<!-- Depth-indicator support routine.                              -->
<!-- ============================================================= -->

<!-- <![CDATA[
This template is  used as a subroutine.  It takes an integer parameter
parameter (named "copies"),  which may range from zero to $maxSection-
Marks minus one.

The template is called by the code which processes a "section" element
and the parameter indicates the number of "section" elements above the
current one.

This subroutine outputs $copies plus one "equals" signs, without white
space and/or newlines.
]]> -->

<xsl:template name="copy-n">
<xsl:param name="copies" />
<xsl:choose>
    <xsl:when test="$copies &lt; $maxSectionMarks">
        <xsl:call-template name="xcopy-n">
            <xsl:with-param name="copies"
                            select="$copies - $maxSectionMarks" />
        </xsl:call-template>
    </xsl:when>
</xsl:choose>
</xsl:template>

<!-- ============================================================= -->
<!-- Handle simple cases.                                          -->
<!-- ============================================================= -->

<!-- <![CDATA[
This part handles simple XML elements; specifically XML elements with-
out attributes.
]]> -->

<xsl:template match="code">
    <xsl:text>''</xsl:text>
    <xsl:apply-templates />
    <xsl:text>''</xsl:text>
</xsl:template>

<xsl:template match="cproto">
    <xsl:element name="xterm">%%<xsl:apply-templates />%%</xsl:element>
    <xsl:text>&#10;&#10;</xsl:text>
</xsl:template>

<xsl:template match="desc">
    <xsl:apply-templates /><xsl:text>&#10;&#10;</xsl:text>
</xsl:template>

<xsl:template match="label">
    <xsl:text>**</xsl:text>
    <xsl:apply-templates />
    <xsl:text>**</xsl:text>
</xsl:template>

<xsl:template match="namedvar">
    <xsl:text>**</xsl:text>
    <xsl:apply-templates />
    <xsl:text>**</xsl:text>
</xsl:template>

<xsl:template match="note">
    <xsl:text>//</xsl:text>
    <xsl:apply-templates />
    <xsl:text>//</xsl:text>
</xsl:template>

<xsl:template match="proto">
    <xsl:element name="xterm">%%<xsl:apply-templates />%%</xsl:element>
    <xsl:text>&#10;&#10;</xsl:text>
</xsl:template>

<xsl:template match="text">
    <xsl:apply-templates /><xsl:text>&#10;&#10;</xsl:text>
</xsl:template>

<xsl:template match="xterm">
    <xsl:element name="xterm"><xsl:apply-templates /></xsl:element>
    <xsl:text>&#10;&#10;</xsl:text>
</xsl:template>

<!-- ============================================================= -->
<!-- Handle "function" elements.                                   -->
<!-- ============================================================= -->

<xsl:template match="function">
    <xsl:text>=== </xsl:text>
    <xsl:value-of select="@name"/>
    <xsl:text> ===</xsl:text>
    <xsl:text>&#10;&#10;</xsl:text>
    <xsl:apply-templates />
</xsl:template>

<!-- ============================================================= -->
<!-- Handle "link" elements.                                       -->
<!-- ============================================================= -->

<xsl:template match="link">
    <xsl:text>[[</xsl:text>
    <xsl:value-of select="@target" />
    <xsl:text>|</xsl:text>
    <xsl:value-of select="@name" />
    <xsl:text>]]</xsl:text>
</xsl:template>

<!-- ============================================================= -->
<!-- Handle "section" elements.                                    -->
<!-- ============================================================= -->

<xsl:template match="section">
    <xsl:call-template name="copy-n">
        <xsl:with-param name="copies"
                        select="count(ancestor::section)" />
    </xsl:call-template>
    <xsl:text> </xsl:text>
    <xsl:value-of select="@title"/>
    <xsl:text> </xsl:text>
    <xsl:call-template name="copy-n">
        <xsl:with-param name="copies"
                        select="count(ancestor::section)" />
    </xsl:call-template>
    <xsl:text>&#10;&#10;</xsl:text>
    <xsl:apply-templates />
</xsl:template>

<!-- ============================================================= -->
<!-- End of stylesheet.                                            -->
<!-- ============================================================= -->

</xsl:stylesheet>
