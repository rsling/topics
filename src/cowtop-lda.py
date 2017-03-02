# -*- coding: utf-8 -*-

# This tool reads an MM corpus and creates a cowtop
# feature matrix using LDA.

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
    parser.add_argument('--alpha', help='alpha parameter; only "asymmetric" or "auto"')
    parser.add_argument('--etaauto', action='store_true', help="estimate asymmetric priors")
    parser.add_argument('--iterations', type=int, default=50, help='cf. Gensim documentation') 
    parser.add_argument('--passes', type=int, default=1, help='cf. Gensim documentation') 
    parser.add_argument('--eval_every', type=int, default=10, help='cf. Gensim documentation') 
    parser.add_argument('--gamma_threshold', type=float, default=0.001, help='cf. Gensim documentation') 
    parser.add_argument('--minimum_probability',type=float, default=0.01, help='cf. Gensim documentation') 
    parser.add_argument('--minimum_phi_value',  type=float, default=0.01, help='cf. Gensim documentation') 

    parser.add_argument('--chunksize', type=int, help='chunk size')
    parser.add_argument('--resume', help='specifiy a previously created LDA model')
    parser.add_argument('--erase', action='store_true', help="erase outout files if present")
    parser.add_argument('--distributed', action='store_true', help="run on cluster (alread set up!)")
    args = parser.parse_args()

    # Sanity-check parameters.
    if args.alpha and not (args.alpha == 'asymmetric' or args.alpha == 'auto'):
        sys.exit('Illegal value for alpa.')

    eta="auto" if args.etaauto else None
    chunksize=1000 if not args.chunksize else args.chunksize

    # Sanity-check num_topics.
    if args.num_topics < 2:
        sys.exit('Number of topics must be greater or equal to 2.')

    # Build output file names.
    fn_matrix_txt   = args.outprefix + "_matrix_lda.tsv"
    fn_topics       = args.outprefix + "_topics_lda.tsv"
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
        lda = models.LdaModel.load(args.resume, mmap='r')
    else:
        # Run LDA. TODO: Pass parameters.
        lda = models.LdaModel(corpus, alpha=args.alpha, eta=eta, id2word=dictionary, num_topics=args.num_topics, distributed=args.distributed, chunksize=chunksize, iterations=args.iterations, passes=args.passes, eval_every=args.eval_every, gamma_threshold=args.gamma_threshold, minimum_probability=args.minimum_probability, minimum_phi_value=args.minimum_phi_value)
        lda.save(fn_model)

    # Dump topics.
    outf = open(fn_topics, 'w')
    for i in range(0, args.num_topics):
        t = lda.show_topic(i, 25)
        outf.write('topic' + str(i) + '\t' + '\t'.join([' '.join([x[0], str(x[1])]) for x in t]).encode('utf-8') + '\n')

    # Dump document-topic associations. Human-readable.
    mtf = open(fn_matrix_txt, 'w')
    i = 0
    corpus_lda = lda[corpus]
    for doc in corpus_lda:
        mtf.write('document' + str(i) + '\t' + '\t'.join([' '.join([str(x[0]), str(x[1])]) for x in doc]) + '\n')
#        mtf.write('document' + str(i) + '\t' + '\t'.join([' '.join([str(x[0]), str(x[1])]) for x in lda.get_document_topics(doc)]) + '\n')
        i += 1

if __name__ == "__main__":
    main()

