from cowtop import Cowcorp
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("infile", help="input file in COW-XML")
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
selectors=[2,1]

# Create corpus object.
c=Cowcorp(args.infile, selectors, filters)

# Just print corpus for demo.
for l in c:
    print l.encode("utf-8")
