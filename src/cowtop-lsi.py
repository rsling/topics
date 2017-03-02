# -*- coding: utf-8 -*-

# This tool reads an MM corpus and creates a cowtop
# feature matrix using LSI.

import argparse
import os.path
import sys
import copy
from gensim import models, corpora
import logging


def main():
    logging.basicConfig(format='%(asctime)s : %(levelname)s : %(message)s', level=logging.INFO)
    parser = argparse.ArgumentParser()
    parser.add_argument('corpus', help='serialized corpus (MM format)')
    parser.add_argument('dictionary', help='serialized Gensim dictionary matching corpus')
    parser.add_argument('outprefix', help='prefix for output files (model and TSV)')
    parser.add_argument('num_topics', type=int, help='number of topics to infer')
    parser.add_argument('--low', type=int, help='lower bound on term-document frequency (absolute)')
    parser.add_argument('--high', type=float, help='upper bound on term-document frequency (proportion)')
    parser.add_argument('--iters', type=int, help='LSA iterations')
    parser.add_argument('--samples', type=int, help='LSA extra samples')
    parser.add_argument('--chunksize', type=int, help='chunk size')
    parser.add_argument('--resume', help='specifiy a previously created LSI model')
    parser.add_argument('--erase', action='store_true', help="erase outout files if present")
    parser.add_argument('--distributed', action='store_true', help="run on cluster (already set up)")
    args = parser.parse_args()

    # Sanity-check num_topics.
    if args.num_topics < 2:
        sys.exit('Number of topics must be greater or equal to 2.')

    # Build output file names.
    fn_matrix_txt   = args.outprefix + "_matrix_lsi.tsv"
    fn_topics       = args.outprefix + "_topics_lsi.tsv"
    fn_model        = args.outprefix + ".lsi"
    fn_tfidf        = args.outprefix + ".tfidf"
   
    # Set default LSI params.
    iters=4 if not args.iters else args.iters
    samples=300 if not args.samples else args.samples
    chunksize=1000 if not args.chunksize else args.chunksize
 
    # Check input files.
    infiles = [args.corpus, args.dictionary]
    if args.resume:
        infiles.append(args.resume)
    
    for fn in infiles:
        if not os.path.exists(fn):
            sys.exit("Input file does not exist: " + fn)

    # Check (potentially erase) output files.
    outfiles = [fn_matrix_txt, fn_topics]
    if not args.resume:
        outfiles.append(fn_model)
    
    # In case dictionary filters are used, check new files.
    if args.low or args.high:
        fn_newdict=args.outprefix + "_filtered.dict"
        outfiles.append(fn_newdict)
        fn_newdict_txt=args.outprefix + "_filtered.dict.txt"
        outfiles.append(fn_newdict_txt)
        fn_newcorp=args.outprefix + "_filtered.mm"
        outfiles.append(fn_newcorp)
    
    for fn in outfiles:
        if fn is not None and os.path.exists(fn):
            if args.erase:
                try:
                    os.remove(fn)
                except:
                    sys.exit("Cannot delete pre-existing output file: " + fn)
            else:
                sys.exit("Output file already exists: " + fn)

    # Load corpus and dictionary.
    dictionary = corpora.dictionary.Dictionary.load(args.dictionary)
    corpus = corpora.MmCorpus(args.corpus)

    # If desired, filter dict and adapt corpus.
    if args.low or args.high:
        new_dict = copy.deepcopy(dictionary)

        # Filter dictionary.
        # TODO There must be a more elegant solution for the conditional. 
        if args.low and not args.high:
            new_dict.filter_extremes(no_below=args.low)
        elif args.high and not args.low:
            new_dict.filter_extremes(no_above=args.high)
        else:
            new_dict.filter_extremes(no_below=args.low, no_above=args.high)
        new_dict.save(fn_newdict)
        new_dict.save_as_text(fn_newdict_txt)

        # Transform corpus.
        old2new = {dictionary.token2id[token]:new_id for new_id, token in new_dict.iteritems()}
        vt = models.VocabTransform(old2new)
        corpus=vt[corpus]
        corpora.MmCorpus.serialize(fn_newcorp, corpus, id2word=new_dict)
        
        # Reassing new dict to old variable.
        dictionary=new_dict


    if args.resume:
        # Just load an old model.
        tfidf = models.TfidfModel.load(args.resume, mmap='r')
        corpus_tfidf = tfidf[corpus]
        lsi = models.LsiModel.load(args.resume, mmap='r')
    else:
        # Run LSI.
        tfidf = models.TfidfModel(corpus)
        tfidf.save(fn_tfidf)
        corpus_tfidf = tfidf[corpus]
        lsi = models.LsiModel(corpus_tfidf, onepass=False, power_iters=iters, extra_samples=samples, id2word=dictionary, num_topics=args.num_topics, distributed=args.distributed, chunksize=chunksize)
        lsi.save(fn_model)

    # Dump topics.
    outf = open(fn_topics, 'w')
    for i in range(0, args.num_topics):
        t = lsi.show_topic(i, 25)
        outf.write('topic' + str(i) + '\t' + '\t'.join([' '.join([x[0], str(x[1])]) for x in t]).encode('utf-8') + '\n')

    # Dump document-topic associations. Human-readable.
    mtf = open(fn_matrix_txt, 'w')
    i = 0
    corpus_lsi = lsi[corpus_tfidf]
    for doc in corpus_lsi:
        mtf.write('document' + str(i) + '\t' + '\t'.join([' '.join([str(x[0]), str(x[1])]) for x in doc]) + '\n')
        i += 1

if __name__ == "__main__":
    main()

