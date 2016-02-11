from cowtop import CowcorpText, CowcorpVec
import argparse
from gensim import corpora

parser = argparse.ArgumentParser()
parser.add_argument("infile", help="input file in COW-XML")
parser.add_argument("outprefix", help="output file prefix")
args = parser.parse_args()

# Filters on columns. Some remove tokens altogether.
filters=list()
filters.append([2, "entities"])
filters.append([2, "lower"])
filters.append([2, "length", 4, 20])
filters.append([2, "copyif2", 0, "(unknown)", 3, "I-PER"])
filters.append([2, "blacklist", {"(unknown)", "(blank)", "@card@"}])
filters.append([2, "alpha"])
filters.append([1, "lower"])
filters.append([1, "truncate", 2])
filters.append([1, "whitelist", {"nn", "vv", "ad", "ne"}])

# Which annotations to use.
selectors=[2]


print "\nCREATING DICTIONARY\n"

# Create corpus object.
c=CowcorpText(args.infile, selectors, filters)

# Create dictionary.
dictionary = corpora.Dictionary(doc for doc in c)
once_ids = [tokenid for tokenid, docfreq in dictionary.dfs.iteritems() if docfreq == 1]
dictionary.filter_tokens(once_ids)
dictionary.compactify()
del c
dictionary.save(args.outprefix + '.dict')
dictionary.save_as_text(args.outprefix + '.dict.txt')
print(dictionary)

print "\nCREATING VECTORIZED CORPUS\n"

# Vectorized corpus object.
vc=CowcorpVec(args.infile, selectors, filters, dictionary)
corpora.MmCorpus.serialize(args.outprefix + '.mm', vc)
del vc

# Testload the serialized corpus.
print "\nTESTLOADING CORPUS (DEMO OUTPUT)\n"
corpus = corpora.MmCorpus(args.outprefix + '.mm')
for x in corpus [:10]:
    print x[:10]

print "\nDONE\n"
