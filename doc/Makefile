default: report.pdf

clean:
	rm -f report.{aux,bbl,blg,glo,gls,ilg,lof,log,lot,out,synctex.gz,toc,pdf}

report.pdf: report.tex
	pdflatex $<
	pdflatex $<
	pdflatex $<
