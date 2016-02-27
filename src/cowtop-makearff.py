# -*- coding: utf-8 -*-

# This tool creates an ARFF file for Weka from a
# document-topic matrix and a file assigning
# topic domains to the documents.

import argparse
import os.path
import sys
from gensim import models, corpora


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('topics', help='file containing document-topic mapping')
    parser.add_argument('domains', help='file containing document-topic domain mapping')
    parser.add_argument('num_topics', type=int, help='number of topics')
    parser.add_argument('domainnames', help='file with domain names')
    parser.add_argument('outprefix', help='prefix for output files (model and ARFF)')
    parser.add_argument('--erase', action='store_true', help="erase outout files if present")
    args = parser.parse_args()

    # Build output file names.
    fn_arff   = args.outprefix + ".arff"
    
    # Check input files.
    infiles = [args.topics, args.domains, args.domainnames]
    
    for fn in infiles:
        if not os.path.exists(fn):
            sys.exit("Input file does not exist: " + fn)

    # Check (potentially erase) output files.
    outfiles = [fn_arff]
    for fn in outfiles:
        if fn is not None and os.path.exists(fn):
            if args.erase:
                try:
                    os.remove(fn)
                except:
                    sys.exit("Cannot delete pre-existing output file: " + fn)
            else:
                sys.exit("Output file already exists: " + fn)

    topics = open(args.topics, 'r')
    domains = open(args.domains, 'r')

    # Read topic domain names.
    topdoms = {} 
    i = 0
    f = open(args.domainnames, 'r')
    for l in f:
        topdoms[l.strip().decode('utf-8')] = i
        i += 1

    arff = open(fn_arff, 'w')

    arff.write('%\n% Sparse topic:domain matrix written by cowtop tools.\n%\n')
    arff.write('% Algorithm  : LDA\n')
    arff.write('%\n\n')
    arff.write('@RELATION ' + os.path.basename(args.outprefix) + '\n\n')
    
    for i in range(0, args.num_topics):
        arff.write('@ATTRIBUTE topic' + str(i) + ' REAL\n')

    arff.write('@ATTRIBUTE domain {' + ', '.join(topdoms.keys()) + '}')
    
    arff.write('\n\n@DATA\n')

    end_t = False
    end_d = False
    i = 0
    while True:

        # This skips empty lines
        t = '\n'
        while t == '\n':
            t = topics.readline()
            if not t:
                end_t = True
                break

        d = '\n'
        while d == '\n':
            d = domains.readline()
            if not d:
                end_d = True
                break

        # If one files is exhausted and the other one is not, something's wrong.
        if (not t) != (not d):
            sys.exit('Files\n' + args.topics + '\n' + args.domains + '\nare not of equal length at index '+ str(i) + '. Abort.')

        if end_t or end_d:
            break
        
        t = t.strip().split('\t')
        d = d.decode('utf-8').strip().split('\t')[1]
        
        arff.write('{' + ', '.join(t[1:]) + ', ' + str(args.num_topics) + ' ' + d.encode('utf-8') + '}\n')
        
        i += 1


if __name__ == "__main__":
    main()

