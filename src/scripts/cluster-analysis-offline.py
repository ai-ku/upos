#!/usr/bin/env python

# # Sample Usage
# # /work/_upos_new/run/enw[141]$ ./cluster-analysis.py enw.words.gz enw.pos.gz 
# # >>> load enw.pos.gz
# # Loaded enw.pos.gz
# # >>> load type.out.gz 
# # Loaded type.out.gz
# # >>> perp
# # -inf <= perp <= inf
# # -inf <= count <= inf
# # 1173766 (100.00%)
# # enw.pos.gz:	1
# # one-tag-per-type:	0.945642
# # type.out.gz:	0.764664

import sys, gzip, math, re
from collections import defaultdict as dd, namedtuple
from itertools import izip
from operator import itemgetter, attrgetter

def read_file(name, col = None):
    try:
        if name.endswith('.gz'):
            f = gzip.open(name)
        else:
            f = open(name)
#        lines = [line.strip().split()[0] for line in f]
        lines = []
        for line in f:
            ll = line.strip().split()
            if len(ll) == 1:
                lines.append(ll[0])
            elif col == None:
                lines.append(ll)
            elif col < len(ll):
                lines.append(ll[col])
            else:
                sys.exit("wrong col number")
        f.close()
        return lines
    except:
        return None

def perplexity_and_counts(count_vec):
    total = sum(count_vec.itervalues())
    entropy = 0.0
    for c in count_vec.itervalues():
        p = float(c) / total
        entropy += -p * math.log(p, 2)
    return 2 ** entropy, total

Stat = namedtuple('Stat', ['perp', 'count'])
def data_stats(word, pos):
    counts = dd(lambda: dd(int))
    for c, p in izip(word, pos):
        counts[c][p] += 1
    stats = {}
    for c, v in counts.iteritems():
        perp, count = perplexity_and_counts(v)
        stats[c] = Stat(perp, count)
    return stats

def m2o_mapping(cluster, pos):
    counts = dd(lambda: dd(int))
    for c, p in izip(cluster, pos):
        counts[c][p] += 1
    mapping = {}
    for c, v in counts.iteritems():
        mapping[c] = max(v.iteritems(), key=itemgetter(1))[0]
    return mapping

def m2o_accuracy(cluster, pos, mapping):
    match = 0
    for c, p in izip(cluster, pos):
        if mapping[c] == p:
            match += 1
    return float(match) / len(pos)

clusters = {}
mappings = {}
word = read_file(sys.argv[1])
pos = read_file(sys.argv[2])
experiment = int(sys.argv[3])
if (not word) or (not pos):
    print "Bad word or pos file"
    sys.exit(1)
stat = data_stats(word, pos)
clusters['one-tag-per-type'] = word
mappings['one-tag-per-type'] = m2o_mapping(word, pos)
for a in range(4,len(sys.argv)):
    tagname = sys.argv[a].split(".")[0]
#    print >> sys.stderr, "Read:%s" % sys.argv[a]
    new_file = read_file(sys.argv[a],experiment)
    clusters[tagname] = new_file
    mappings[tagname] = m2o_mapping(new_file, pos)
p = dd(lambda: [])
matches = dd(lambda: dict(((k, []) for k in clusters.iterkeys())))
for i in xrange(len(word)):
    p[word[i]].append(pos[i])
    for k, v in matches[word[i]].iteritems():
        v.append(clusters[k][i])
for w in sorted(stat, key=lambda x: stat[x].count, reverse=True):
    sys.stdout.write("%s\t%g\t%g\t" % (w,stat[w].perp,float(len(p[w])) / len(word)))
    for k in sorted(clusters.iterkeys()):
        sys.stdout.write("%s %g\t" % (k, m2o_accuracy(matches[w][k], p[w], mappings[k])))
    sys.stdout.write("\n")
