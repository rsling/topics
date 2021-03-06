# -*- coding: utf-8 -*-

# This tool reads a COW-XML corpus and produces a vectorized
# corpus (MM format) with an appropriate lexicon with Gensim.

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
    parser.add_argument('--dictionary', help='use a pre-existing dictionary')
    parser.add_argument("--erase", action='store_true', help="erase outout files if present")
    parser.add_argument("--filters", type=str, help="file with tab-separated filter definitions")
    parser.add_argument("--mergers", type=str, help="file with tab-separated merger definitions")
    parser.add_argument("--minlength", type=int, default=-1, help="minimal token length of documents")
    parser.add_argument("--debug", action="store_true", help="whether corpus should be dumped after pre-processing")
    parser.add_argument("--zipped", action="store_true", help="use gzip for corpus files")
    args = parser.parse_args()


    # Build output file names.
    fn_corpus   = args.outprefix + "_bow.mm"

    # We only need dictionary output file names if we are not reusing.
    if not args.dictionary:
        fn_dict     = args.outprefix + ".dict"
        fn_dict_txt = args.outprefix + ".dict.txt"
   
    # Debug file name (dump preprocessed corpus).
    if args.debug:
        fn_debug = args.outprefix + ".debug"
    else:
        fn_debug = None

    # Check input files.
    infiles = [args.infile]
    if args.mergers:
        infiles.append(args.mergers)
    if args.dictionary:
        infiles.append(args.dictionary)

    for fn in infiles:
        if not os.path.exists(fn):
            sys.exit("Input file does not exist: " + fn)

    # Check (potentially erase) output files.
    outfiles = [fn_corpus]
    if args.debug:
        outfiles.append(fn_debug)

    if not args.dictionary:
        outfiles.append(fn_dict)
        outfiles.append(fn_dict_txt)
    for fn in outfiles:
        if fn is not None and os.path.exists(fn):
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
                if not os.path.exists(l[2]):
                    sys.exit("Blacklist/whitelist file does not exist: " + l[2])
                with open(l[2]) as f:
                    il = [x.decode('utf-8').strip() for x in f.readlines()]
                filters.append([int(l[0]), l[1], il])
    else:
      filters = None

    # Read mergers file.
    mergers = list()
    if args.mergers is not None:
        for m in open(args.mergers):
            lm = m.strip().decode('utf-8').split('\t')
            mergers.append([int(lm[0]), lm[1], [int(x) for x in lm[2].split(',')]  ])
    else:
      mergers = None

    # Create dictionary or load existing one.
    if not args.dictionary:
        c=CowcorpText(args.infile, columns, filters, mergers, args.minlength, args.zipped)
        dictionary = corpora.Dictionary(doc for doc in c)
        dictionary.save(fn_dict)
        dictionary.save_as_text(fn_dict_txt)
    else:
        dictionary = corpora.dictionary.Dictionary.load(args.dictionary)

 
    # Create matricified corpus.
    vc=CowcorpVec(args.infile, columns, filters, mergers, args.minlength, dictionary, args.zipped)
    corpora.MmCorpus.serialize(fn_corpus, vc)

    # If debug dump was requested, do it.
    if args.debug:
        dc=CowcorpText(args.infile, columns, filters, mergers, args.minlength, args.zipped)
        f_debug = open(fn_debug, 'wb')
        for document in dc:
            f_debug.write((' ').join(document).encode('utf-8') + '\n\n')

if __name__ == "__main__":
    main()
