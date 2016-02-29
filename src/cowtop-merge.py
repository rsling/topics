# -*- coding: utf-8 -*-

# This tool merges two dictionaries and subsequently
# the to respective corpora

import argparse
import os.path
import sys
import itertools
from gensim import corpora



def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('dictionary1', help='first serialized Gensim dictionary (binary)')
    parser.add_argument('dictionary2', help='second serialized Gensim dictionary (binary)')
    parser.add_argument('corpus1', help='first serialized corpus (MM format)')
    parser.add_argument('corpus2', help='second serialized corpus (MM format)')
    parser.add_argument('outprefix', help='prefix for output files')
    parser.add_argument("--erase", action='store_true', help="erase outout files if present")
    args = parser.parse_args()

    # Build output file names.
    fn_corpus   = args.outprefix + "_bow.mm"
    fn_dict     = args.outprefix + ".dict"
    fn_dict_txt = args.outprefix + ".dict.txt"
    

    # Check input files.
    for fn in [args.dictionary1, args.dictionary2, args.corpus1, args.corpus2]:
        if not os.path.exists(fn):
            sys.exit("Input file does not exist: " + args.infile)

    # Check (potentially erase) output files.
    for fn in [fn_corpus, fn_dict, fn_dict_txt]:
        if fn is not None and os.path.exists(fn):
            if args.erase:
                try:
                    os.remove(fn)
                except:
                    sys.exit("Cannot delete pre-existing output file: " + fn)
            else:
                sys.exit("Output file already exists: " + fn)

    # Careful, dictionary1 is modified in place, but the call
    # returns a transformation object to adapt dict2-based corpora to
    # new modified dict1.
    dictionary1 = corpora.dictionary.Dictionary.load(args.dictionary1)
    dictionary2 = corpora.dictionary.Dictionary.load(args.dictionary2)
    transform = dictionary1.merge_with(dictionary2)

    dictionary1.save(fn_dict)
    dictionary1.save_as_text(fn_dict_txt)

    corpus1 = corpora.MmCorpus(args.corpus1)
    corpus2 = corpora.MmCorpus(args.corpus2)

    merged_corpus = itertools.chain(corpus1, transform[corpus2])
    corpora.MmCorpus.serialize(fn_corpus, merged_corpus)

if __name__ == "__main__":
    main()
