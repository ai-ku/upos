#!/usr/bin/env python

import sys, itertools, operator

multiplier = float(sys.argv[1])

pos = {}
pos_color = {}
colors = ['0000ff','ff0000','00ff00','ff1ab8','ffd300','0083f6','008c46','a7603d','4f0069','00fff6','3d7b8c','eda7ff','ff7eda']
with open(sys.argv[3], 'r') as f:
    p = {}
    for line in f:
        line = line.strip().split("\t")
        p.setdefault(line[0], {})
        p[line[0]].setdefault(line[1], 0)
        p[line[0]][line[1]] += 1
    for k, v in p.iteritems():
        pos[k] = max(v.iteritems(), key=operator.itemgetter(1))[0]
    p = {}
    for v in pos.itervalues():
        try:
            p[v] += 1
        except:
            p[v] = 1
    for (k, v), c  in zip(sorted(p.items(), key=lambda x: x[1], reverse=True), colors):
        pos_color[k] = c

cluster = {}
m2o_color = {}
with open(sys.argv[4], 'r') as f:
    p = {}
    for line in f:
        line = line.strip().split("\t")
        p.setdefault(line[1], [])
        p[line[1]].append(line[0])
    p = sorted(p.iteritems(), key=lambda x: len(x[1]), reverse=True)
    for (k, v), c in zip(p, colors):
        m2o_color[k] = c
        for word in v:
            cluster[word] = k

initial = {}
array = []
obj = []
with open(sys.argv[2], 'r') as f:
    for line, c in zip(f, itertools.count()):
        line = line.split("\t")
        ver = [c]
        ver.extend(map(lambda x: int(float(x) * multiplier), line[1:]))
        initial[line[0]] = ver
        array.append("[%s,\"%s\",\"%s\",\"%s\",\"%s\"]" % (",".join(map(str, ver)), pos_color[pos[line[0]]], pos[line[0]], m2o_color[cluster[line[0]]], cluster[line[0]]))
        obj.append("\"%s\":%d" % (line[0], c))

sys.stdout.write("var word_index = {%s};\n" % ",".join(obj))
sys.stdout.write("var ver_initial = [%s];\n" % ",".join(array))

with open(sys.argv[5], 'r') as f:
    updates = f.readlines()

runtime = 30
fps = 25
steps = 25 * 30
stepsize = int((len(updates) + steps - 1) / float(steps))

array_outer = []
for i in xrange(steps):
    update = {}
    array = []
    for j in xrange(i * stepsize, min((i + 1) * stepsize, len(updates))):
        line = updates[j].split("\t")
        c = initial[line[0]][0]
        update[c] = map(lambda x: int(float(x) * multiplier), line[1:])
    for c, v in update.iteritems():
        array.append("[%d,%s]" % (c, ",".join(map(str, v))))
    # if i == 10:
    #     break
    array_outer.append("[%s]" % ",".join(array))

sys.stdout.write("var ver_updates = [%s];\n" % ",".join(array_outer))
sys.stdout.write("var n_updates = %d;\n" % len(array_outer))
