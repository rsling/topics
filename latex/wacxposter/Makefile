LX = latex
PP = ps2pdf
PX = pdflatex
BX = bibtex
DP = dvips
AR = evince

DVIPSFLASG = -dAutoRotatePages=/None
TEXFLAGS = -interaction=nonstopmode -enable-installer
TEXFLAGSDBG = -enable-installer
FILEN = td-wacx

all:
	-$(PX) $(TEXFLAGS) $(FILEN)
	-$(BX) $(FILEN)
	-$(PX) $(TEXFLAGS) $(FILEN)

clean:
	-@$(RM) *.pdf
	-@$(RM) *~
	-@$(RM) *.aux
	-@$(RM) *.log
	-@$(RM) *.out
	-@$(RM) *.bbl
	-@$(RM) *.blg
	-@$(RM) *.toc
	-@$(RM) latexSuiteTemp*
	-@$(RM) *.dvi
	-@$(RM) *.ps
	-@$(RM) *.swp
	-@$(RM) *.lof
	-@$(RM) *.lot
	-@$(RM) *.idx
	-@$(RM) *.ilg
	-@$(RM) *.ind
	-@$(RM) *.nav
	-@$(RM) *.snm

