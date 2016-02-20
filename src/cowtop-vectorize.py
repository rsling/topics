# -*- coding: utf-8 -*-

import argparse
import os.path
import sys
from gensim import corpora
from cowtop import CowcorpText, CowcorpVec


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('infile', help='COW-XML input file')
    parser.add_argument('outprefix', help='prefix for output files')
    parser.add_argument('columns', help='comma-separated list of columns to use (0-based)')
    parser.add_argument("--erase", action='store_true', help="erase outout files if present")
    parser.add_argument("--filters", type=str, help="file with tab-separated filter definitions")
    args = parser.parse_args()

    # Build output file names.
    fn_corpus   = args.outprefix + "_bow.mm"
    fn_dict     = args.outprefix + ".dict"
    fn_dict_txt = args.outprefix + ".dict.txt"

    # Check input file.
    if not os.path.exists(args.infile):
        sys.exit("Input file does not exist: " + args.infile)

    # Check (potentially erase) output files.
    for fn in [fn_corpus, fn_dict]:
        if os.path.exists(fn):
            if args.erase:
                try:
                    os.remove(fn)
                except:
                    sys.exit("Cannot delete pre-existing output file: " + fn)
            else:
                sys.exit("Output file already exists: " + fn)

    # Read column specs.
    columns = args.columns.split(',')
    columns = [int(x) for x in columns if x.isdigit()]
    columns = [x for x in columns if x >= 0 and x <= 20]
    if len(columns) < 1:
        sys.exit('Column specification seems incorrect: ' + args.columns)

    # Read filters.
    if args.filters is not None:
        if not os.path.exists(args.filters):
            sys.exit("Filter file does not exist: " + args.filters)

        # Actually create the list of filters.
        filters = list()
        for f in open(args.filters):
            l = f.decode('utf-8').strip().split('\t')
            if len(l) < 2:
                continue
            if not l[1] in ['blacklist','whitelist']:
                filters.append([int(x) if x.isdigit() else x for x in l])
            else:
                try:
                    idx = [p[:2] for p in filters].index([int(l[0]), l[1]])
                    (filters[idx][2]).append(l[2])
                except:
                    filters.append([int(l[0]), l[1], [l[2]]])

    # Create dictionary.
    c=CowcorpText(args.infile, columns, filters)
    dictionary = corpora.Dictionary(doc for doc in c)
    dictionary.save(fn_dict)
    dictionary.save_as_text(fn_dict_txt)

    # Create matricified corpus.
    vc=CowcorpVec(args.infile, columns, filters, dictionary)
    corpora.MmCorpus.serialize(fn_corpus, vc)


if __name__ == "__main__":
    main()
