#!/usr/bin/python
# -*- coding:utf-8 -*-

import sys
import os
import numpy 
from argparse import ArgumentParser

def arguments():
    parser = ArgumentParser(description="Reads in two csv files with vectors as produced by cowcat2vec (one vector per line, tab separated values, first field is text-ID) and computes cosine similarity and a second naive similarity score for pairs of vectors from file1 and file2.")
    parser.add_argument('file1', help='csv file with vectors as produced by cowcat2vec')
    parser.add_argument('file2', help='csv file with vectors as produced by cowcat2vec')
    parser.add_argument('--sparse', action='store_true', default=False, help='Do not use sparse vectors (keep fields with zero values in both vectors)')
    args = parser.parse_args()
    return(args)


def mkvec(line):
    spline = line.strip().split("\t")
    textid = spline[0]
    try:
        vals = [int(i) for i in spline[1:]]
        vec = numpy.array(vals)
    except ValueError:
        vec = None
#        sys.stderr.write(textid + " ")
#        sys.stderr.write(str(vec)+"\n")
    return(textid,vec)


def sparse(vec1, vec2):
    if not len(vec1) == len(vec2):
        raise Exception("Sparse: vectors have different lengths.\n")
	sys.exit(1)
    else:
        z = zip(vec1,vec2)
        f = [(i,j) for (i,j) in z if i > 0 or j > 0]
        vec1 = numpy.array([i for (i,j) in f])
        vec2 = numpy.array([j for (i,j) in f])
    return(vec1, vec2)
	

def cosine_sim(vec_a, vec_b):
    dotproduct = vec_a.dot(vec_b)
    mag_a = numpy.linalg.norm(vec_a)
    mag_b = numpy.linalg.norm(vec_b)
    if mag_a * mag_b == 0:
        cosine = "NA"
    else:
        cosine = dotproduct/(mag_a*mag_b)
    return(cosine)
		


def simple_sim(vec1, vec2):
    if numpy.linalg.norm(vec1) * numpy.linalg.norm(vec2) == 0:
        score = "NA"
    else:
        nonmatching = sum(abs(vec1 - vec2))
        score = 1 - (float(nonmatching)/8)
    return(score) 




def main():
    args = arguments()
 
    if not os.path.exists(args.file1):
        sys.stderr.write("File '" + args.file1 + "'does not exist.\n" )
        sys.exit(1)
    else:
        file_a = open(args.file1)


    if not os.path.exists(args.file2):
        sys.stderr.write("File '" + args.file2 + "'does not exist.\n" )
        sys.exit(1)
    else:
        file_b = open(args.file2)
 


    for line_a in file_a:
        a = mkvec(line_a)
        id_a = a[0]
        vec_a = a[1]
       
        if vec_a is None:
            sys.stderr.write(id_a +"\t(File1): WARNING: could not build vector\n")
        else:
            if numpy.linalg.norm(vec_a) == 0:
                sys.stderr.write(id_a +"\t(File1): WARNING: zero magnitude vector\n")


        line_b = file_b.readline()
        b = mkvec(line_b)
        id_b = b[0]
        vec_b = b[1]
                
        if vec_b is None:
            sys.stderr.write(id_b +"\t(File2): WARNING: could not build vector\n")
        else:
            if numpy.linalg.norm(vec_b) == 0:
                sys.stderr.write(id_b +"\t(File2): WARNING: zero magnitude vector\n")

            
        if id_a == id_b:
            if type(vec_a) == numpy.ndarray and type(vec_b) == numpy.ndarray:
                if args.sparse == True:
                    vec_a, vec_b = sparse(vec_a, vec_b)
                cosine = cosine_sim(vec_a, vec_b)
                fsim = simple_sim(vec_a, vec_b)
                out_line = id_a + "\t" + str(cosine) + "\t" + str(fsim)
            else:
                out_line = id_a + "\tNA\tNA"	
	    print(out_line)
        else:
            sys.stderr.write("Text-IDs do not match. File1: " + id_a + ", File1: " + id_b + "\n")
            sys.exit(1)

if __name__ == "__main__":
	main()	
	
	


