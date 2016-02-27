# -*- coding: utf-8 -*-

# COW + IDS topic modeling helpers based on gensim.

import re
from gensim import corpora


class CowcorpVec:

    def __init__(self, filename, selectors, filters, mergers, minlength, dictionary):
        self.corpus = CowcorpText(filename, selectors, filters, mergers, minlength)
        self.dictionary = dictionary

    def __iter__(self):
        for d in self.corpus:
            yield self.dictionary.doc2bow(d)



class CowcorpText:
    """A class that reads COW-XML document by document for topic modeling"""


    def __init__(self, filename, selectors, filters, mergers, minlength):
        self.infilename = filename
        self.infile = open(self.infilename)

        self.selectors = selectors
        self.filters = filters
        self.mergers = mergers
        self.minlength = minlength

        self.count = 1

        self.docstart = re.compile(r'^<doc .+> *$')
        self.docend = re.compile(r'^</doc> *$')


    # ITERATOR STUFF

    def __iter__(self):
        return self

    def next(self):

        while True:
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
                    raise StopIteration
            
            # If doc start was found, buffer until end of doc.
            while True:
                l = self.sread()
                
                if l:
                    b.append(l)
                    if self.docend.match(l):
                        break
                else:
                    raise StopIteration

            # There was a document. Increase counter.
            self.count = self.count+1

            # Tokenize. Returns list of tokens, each token is a list of annotations.
            b = self.tokenize(b)

            # Execute the token mergers if there are any defined.
            for merger in self.mergers:
                b = self.merge_if_identical(b, merger[0], merger[1], merger[2])

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

            if not len(b) < self.minlength:
                break
        return b



    # FUNCTIONALITY


    # Read a line and make ready to use.
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

    # This function merges the merge fields where the check field is
    # identical and equal to value in running token sequences. Sort
    # of like a more complex RLE with merging. (I guess that's pretty
    # incomprehensible. Look at the comments and the output.)
    def merge_if_identical(self, document, check, value, merge):

        # Create new outpu list.
        o = list()

        # At start, we have not seen a target item
        last = [None] * 20

        # Iterate through doc ...
        for t in document:

            # ... and if the previous token matched ...
            if last[check] == value:

                # ... and this token matches ...
                if t[check] == value:
                    
                    # ... then construct new "last" with merging ...
                    for i in merge:
                        last[i] = last[i] + t[i]
                
                # ... but if only the previous token matched, there is
                #     no sequence, and we write both to output and
                #     reset the last token buffer ...
                else:
                    o.append(last)
                    o.append(t)
                    last = [None] * 20

            # ... but if the last token did not match ...
            else:

                # ... and the current token matches ...
                if t[check] == value:

                    # ... we might see the beginning of a new sequence
                    #     and buffer the current token instead of writing it ...
                    last = t

                # ... but if neither the last nor the current token match
                #     we write the current token!
                else:
                    o.append(t)
        return o

