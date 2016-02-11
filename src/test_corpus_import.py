#!/usr/bin/python

from cowtop import Cowcorp

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

selectors=[2,1]

c=Cowcorp("cowcat.patch.xml", selectors, filters)

for l in c:
    print l.encode("utf-8")
