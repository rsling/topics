# -*- coding: utf-8 -*-

# This tool reads an MM corpus and creates a cowtop
# feature matrix using LDA.

import argparse
import os.path
import sys
from gensim import models, corpora


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('corpus', help='serialized corpus (MM format)')
    parser.add_argument('dictionary', help='serialized Gensim dictionary matching corpus')
    parser.add_argument('outprefix', help='prefix for output files (model and ARFF)')
    parser.add_argument('num_topics', type=int, help='number of topics to infer')
    parser.add_argument('--resume', help='specifiy a previously created LDA model')
    parser.add_argument('--params', help='comma-separated list of parameters to pass to LDA')
    parser.add_argument('--erase', action='store_true', help="erase outout files if present")
    args = parser.parse_args()

    # Sanity-check num_topics.
    if args.num_topics < 2:
        sys.exit('Number of topics must be greater or equal to 2.')

    # Build output file names.
    fn_matrix_txt   = args.outprefix + "_matrix.tsv"
    fn_topics       = args.outprefix + "_topics.tsv"
    fn_model        = args.outprefix + ".lda"
    
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

    if args.resume:
        # Just load an old model.
        lda = models.LdaModel.load(args.resume, mmap='r')
    else:
        # Run LDA. TODO: Pass parameters.
        lda = models.LdaModel(corpus, id2word=dictionary, num_topics=args.num_topics)
        lda.save(fn_model)

    # Dump topics.
    outf = open(fn_topics, 'w')
    for i in range(0, args.num_topics):
        t = lda.show_topic(i, 25)
        outf.write('topic' + str(i) + '\t' + '\t'.join([' '.join([x[0], str(x[1])]) for x in t]).encode('utf-8') + '\n')

    # Dump document-topic associations. Human-readable.
    mtf = open(fn_matrix_txt, 'w')
    i = 0
    for doc in corpus:
        mtf.write('document' + str(i) + '\t' + '\t'.join([' '.join([str(x[0]), str(x[1])]) for x in lda.get_document_topics(doc)]) + '\n')
        i += 1

if __name__ == "__main__":
    main()

