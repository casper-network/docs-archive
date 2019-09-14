make clean
make latex
cd _build/latex/

# Run twice to get the references right
xelatex CasperLabsTechSpec.tex
xelatex CasperLabsTechSpec.tex
