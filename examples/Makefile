default:
	sh ./build-xsltdoc-examples.sh
	@echo "Made or tried to make DokuWiki and HTML output files"
	@echo "PDF has not been built. If you have wkhtmltopdf, then you can"
	@echo "execute: make pdf"

pdf:
	sh ./build-xsltdoc-pdf.sh
	@echo "Made or tried to make PDF output file"

clean:
	rm -f API_Reference.{dokuwiki,html,pdf} *~
