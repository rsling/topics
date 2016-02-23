# topics
Wrappers for COW/COCOA and DeReKo topic modelling experiments

Example call for creating a vectorized corpus with default filters and settings:

```
python src/cowtop-vectorize.py data/cattle13.xml data/cattle13 2,1 --erase --filters data/filters.tab --mergers data/mergers.tab --debug
```

Example call for merging to dictionaries and corpora (in this case using the same dict and corp twice):

```
python src/cowtop-merge.py data/cattle13.dict data/cattle13.dict data/cattle13_bow.mm data/cattle13_bow.mm data/joint --erase
```

Example call for running LDA or LSI on vectorized corpora:

```
python src/cowtop-lda.py data/cattle13_bow.mm data/cattle13.dict data/cattle13 20 --erase
python src/cowtop-lsi.py data/cattle13_bow.mm data/cattle13.dict data/cattle13 20 --erase
```

The same if an LDA or LSI model has already been created:

```
python src/cowtop-lda.py data/cattle13_bow.mm data/cattle13.dict data/cattle13 20 --erase --resume data/cattle13.lda
python src/cowtop-lsi.py data/cattle13_bow.mm data/cattle13.dict data/cattle13 20 --erase --resume data/cattle13.lsi
```

Create ARFFs for Weka:

```
python src/cowtop-makearff.py data/cattle13_matrix_lda.tsv data/cattle13.domain.single.tsv 20 data/domain_names.tsv data/cattle13 --erase
python src/cowtop-makearff.py data/cattle13_matrix_lsi.tsv data/cattle13.domain.single.tsv 20 data/domain_names.tsv data/cattle13 --erase
```

