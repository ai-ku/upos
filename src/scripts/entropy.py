#!/usr/bin/env python
#
#./entropy.py enw.word.gz enw.pos.gz
# First argument = word file
# Second argument = cluster file 
# Second argument can be any file with multiple columns (multiple
# answers) in such a case script will return the average entropy of
# all columns

import sys, gzip, math
from collections import defaultdict as dd
from itertools import izip
from operator import itemgetter, attrgetter
from pprint import pprint as pp

def read_file(name):
    try:
        if name.endswith('.gz'):
            f = gzip.open(name)
        else:
            f = open(name)
        lines = [line.strip().split() for line in f]
        f.close()
        return lines
    except:
        return None

word = read_file(sys.argv[1])
pos = read_file(sys.argv[2])
if (not word) or (not pos) or (len(word) != len(pos)):
    print "Bad word or pos file"
    sys.exit(1)


counts = []

for i in range(len(pos[0])):
    h = dd(lambda: dd(int))
    for w,t in izip(word,pos):
        h[w[0]][t[i]] += 1
    counts.append(h)

print "calculating entropy"
avgentropy = 0.0
for i in xrange(len(pos[0])):
    entropy = 0.0
    for (w,v) in counts[i].items():
        s = sum(v.itervalues())
        for t in v.values():
            pr = float(t) / s
            entropy += -pr * math.log(pr,2)
    print "%d\t%g" % (i,entropy)
    avgentropy += entropy
avgentropy /= 10
print avgentropy, len(counts[0]), avgentropy/len(counts[0]), 2**(avgentropy/len(counts[0]))

