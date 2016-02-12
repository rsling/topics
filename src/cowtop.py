# COW + IDS topic modeling helpers based on gensim.

import re
from gensim import corpora


class CowcorpVec:

    def __init__(self, filename, selectors, filters, dictionary):
        self.corpus = CowcorpText(filename, selectors, filters)
        self.dictionary = dictionary

    def __iter__(self):
        for d in self.corpus:
            yield self.dictionary.doc2bow(d)



class CowcorpText:
    """A class that reads COW-XML document by document for topic modeling"""


    def __init__(self, filename, selectors, filters):
        self.infilename = filename
        self.infile = open(self.infilename)

        self.selectors = selectors
        self.filters = filters


        self.count = 1

        self.docstart = re.compile(r'^<doc .+> *$')
        self.docend = re.compile(r'^</doc> *$')

        # Check if header is correct.
        l = self.sread()
        if not l == u'<?xml version="1.0" encoding="UTF-8"?>':
            raise BaseException('XML declaration missing.')



    # ITERATOR STUFF

    def __iter__(self):
        return self

    def next(self):

        # At first, document is empty.
        b = list()

        # Find doc start.
        while True: 
            l = self.sread()
            if l:
                if self.docstart.match(l):
                    b.append(l)
                    break
            else:
                print (u'Reached end of file after ' + str(self.count) + u' documents.').encode('utf-8')
                raise StopIteration
        
        # If doc start was found, buffer until end of doc.
        while True:
            l = self.sread()
            
            if l:
                b.append(l)
                if self.docend.match(l):
                    break
            else:
                print(u'End of file in the middle of document?'.encode('utf-8'))
                raise StopIteration

        # There was a document. Increase counter.
        self.count = self.count+1

        # Tokenize. Returns list of tokens, each token is a list of annotations.
        b = self.tokenize(b)

        # Apply filters.
        for filt in self.filters: 
            if filt[1] == "alpha":
                b = self.filter_alpha(b, filt[0])
            elif filt[1] == "lower":
                b = self.filter_lower(b, filt[0])
            elif filt[1] == "entities":
                b = self.filter_entities(b, filt[0])
            elif filt[1] == "truncate":
                b = self.filter_truncate(b, filt[0], filt[2])
            elif filt[1] == "length":
                b = self.filter_length(b, filt[0], filt[2], filt[3])
            elif filt[1] == "copyif":
                b = self.filter_copyif(b, filt[0], filt[2], filt[3])
            elif filt[1] == "copyif2":
                b = self.filter_copyif2(b, filt[0], filt[2], filt[3], filt[4], filt[5])
            elif filt[1] == "blacklist":
                b = self.filter_blacklist(b, filt[0], filt[2])
            elif filt[1] == "whitelist":
                b = self.filter_whitelist(b, filt[0], filt[2])
            else:
                raise BaseException('Filter type unknown: ' + filt[1])

        # Select columns.
        b = [self.select(token) for token in b]

        return b



    # FUNCTIONALITY


    # Reading a line and make ready to use.
    def sread(self):
        return self.infile.readline().decode('utf-8').strip()

    # Turn a buffered document into a list of tokens with annotations.
    def tokenize(self, xmldoc):
        return [line.split('\t') for line in xmldoc if not line[0] == '<']


    # Filter all non-alpha strings at annotaion idx.
    def filter_alpha(self, document, idx):
        return [token for token in document if token[idx].isalpha()]

    # Make lowercase.
    def filter_lower(self, document, idx):
        for token in document:
            token[idx] = token[idx].lower()
        return document

    # Decode entities.
    def filter_entities(self, document, idx):
        for token in document:
            token[idx] = token[idx].replace('&gt;','>').replace('&lt;','<').replace('&quot;','"').replace('&apos;',"'").replace('&amp;','&')
        return document

    # Truncate (e.g., POS) 
    def filter_truncate(self, document, idx, num):
        for token in document:
            token[idx] = token[idx][:num] if len(token[idx]) > num else token[idx]
        return document

    # Require length of annotation at idx.
    def filter_length(self, document, idx, low, high):
        return [token for token in document if len(token[idx]) >= low and len(token[idx]) <= high ]

    # Copy an annotation to another annotation if.
    def filter_copyif(self, document, idx, src, cond):
        for token in document:
            token[idx] = token[src] if token[idx] == cond else token[idx] 
        return document

    # Copy an annotation to another annotation if. With second condition.
    def filter_copyif2(self, document, idx, src, cond, idx2, cond2):
        for token in document:
            token[idx] = token[src] if token[idx] == cond and token[idx2] == cond2 else token[idx]
        return document

    # Remove tokens where some annotation is blacklisted.
    def filter_blacklist(self, document, idx, blacklist):
        return [token for token in document if not token[idx] in blacklist]

    # Only keep topens with the specified annoation on the whitelist.
    def filter_whitelist(self, document, idx, whitelist):
        return [token for token in document if token[idx] in whitelist]


    # Use self.selectors to extract columns from VRT.
    def select(self, token):
        if len(self.selectors) == 1:
            return token[self.selectors[0]]
        else:
            return "_".join([token[i] for i in self.selectors])
