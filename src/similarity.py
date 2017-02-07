#!/usr/bin/python

# reads in two csv files with vectors,
# (one per line, tab separated values,
# first column is text-id) and computes
# cosine similarity for pairs of vectors
# from file_a and file_b.


NOSPARSE=False


# don't adapt past this line #

import numpy # as np

def mkvec(line):
	spline = line.strip().split("\t")
	textid = spline[0]
        try:
            vals = [int(i) for i in spline[1:]]
            vec = numpy.array(vals)
        except ValueError:
            vec = None
	return(textid,vec)

def nosparse(vec1, vec2):
	if not len(vec1) == len(vec2):
		raise Exception("Nosparse: vectors have different lengths.\n")
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
		pass
#		raise Exception("Zero magnitude vector\n")
#		sys.exit(1)
	else:
		cosine = dotproduct/(mag_a*mag_b)
		return(cosine)
		
def my_sim(vec1, vec2):
	nonmatching = sum(abs(vec1 - vec2))
	score = 1 - (float(nonmatching)/8)
	return(score) 


def main():
	
	import sys
#	import numpy as np

	file_a = open(sys.argv[1])
	file_b = open(sys.argv[2])

	for line_a in file_a:
		a = mkvec(line_a)
		id_a = a[0]
		vec_a = a[1]
		line_b = file_b.readline()
		b = mkvec(line_b)
		id_b = b[0]
		vec_b = b[1]
		if id_a == id_b:
                        if type(vec_a) == numpy.ndarray and type(vec_b) == numpy.ndarray:
				cosine = cosine_sim(vec_a, vec_b)
				fsim = my_sim(vec_a, vec_b)
				out_line = id_a + "\t" + str(cosine) + "\t" + str(fsim)
                        else:
				out_line = id_a + "\tNA\tNA"	
			print(out_line)

if __name__ == "__main__":
	main()	
	
	


