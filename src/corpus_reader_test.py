# Demo script using corpus streaming class.

from cowtop import CowcorpText, CowcorpVec
import argparse
from gensim import corpora, models, similarities
import sys


import logging
logging.basicConfig(format='%(asctime)s : %(levelname)s : %(message)s', level=logging.INFO)

parser = argparse.ArgumentParser()
parser.add_argument("infile", help="input file in COW-XML")
parser.add_argument("outprefix", help="output file prefix")
args = parser.parse_args()



# ===== SETTINGS =====


# Filters on columns. Some remove tokens altogether.

filters=list()

# If you want to copy, always copy first so other filters apply to copied material.
filters.append([2, "copyif", 0, "(unknown)"])
#filters.append([2, "copyif2", 0, "(unknown)", 3, "I-PER"])

filters.append([2, "entities"])
filters.append([2, "alpha"])
filters.append([2, "length", 4, 30])
filters.append([2, "lower"])
filters.append([2, "blacklist", {"(unknown)", "(blank)", "@card@", "mensch", "mann", "frau", "kind"}])

filters.append([1, "lower"])
filters.append([1, "truncate", 2])
filters.append([1, "whitelist", {"nn", "ne"}])

# Which annotations to use.
selectors=[2]

num_tops=30


# ===== WORK =====


print "\nCREATING DICTIONARY\n"

# Create corpus object.
c=CowcorpText(args.infile, selectors, filters)

# Create dictionary.
dictionary = corpora.Dictionary(doc for doc in c)

# Filter frequent types.
dictionary.filter_extremes(no_below=2, no_above=0.5, keep_n=100000)

# Clean up dictionary.
dictionary.compactify()
dictionary.save(args.outprefix + '.dict')
dictionary.save_as_text(args.outprefix + '.dict.txt')

print "\nCREATING VECTORIZED CORPUS\n"

vc=CowcorpVec(args.infile, selectors, filters, dictionary)
corpora.MmCorpus.serialize(args.outprefix + '_bow.mm', vc)

print "\nLOADING SERIALZED CORPUS AND DOING TFIDF\n"

cs = corpora.MmCorpus(args.outprefix + '_bow.mm')
tfidf = models.TfidfModel(cs)
corpus_tfidf = tfidf[cs]
tfidf.save(args.outprefix + '.tfidf')

print "\nUSING TFIDF WITH CORPUS TO DO LSI\n"

lsi = models.LsiModel(corpus_tfidf, id2word=dictionary, num_topics=num_tops)
corpus_lsi = lsi[corpus_tfidf]
lsi.save(args.outprefix + '.lsi')

print "\nLOADING SERIALZED CORPUS AND DOING LDA\n"

lda = models.ldamodel.LdaModel(cs, id2word=dictionary, num_topics=num_tops, passes=2, iterations=75, alpha='auto', eval_every=5)
corpus_lda = lda[cs]
lda.save(args.outprefix + '.lda')

print "\nLSI TOPICS (first 15 words only)\n"

for doc in lsi.show_topics(num_topics=30, num_words=15, log=False, formatted=True):
    print 'Topik ' + str(doc[0])
    print '\t' + '\n\t'.join(doc[1].split(' + ')).encode('utf-8')

print "\nLDA TOPICS (first 15 words only)\n"

for doc in lda.show_topics(num_topics=30, num_words=15, log=False, formatted=True):
    print 'Topik ' + str(doc[0])
    print '\t' + '\n\t'.join(doc[1].split(' + ')).encode('utf-8')

# Topic coherence. Takes VERY long.
# print lda.top_topics(cs, num_words=20)
