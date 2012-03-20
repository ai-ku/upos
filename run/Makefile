### Input files:
TRAIN=wsj.tok.gz # Training data from CSR-3.  wc=5187874 126170376 690948662
TEST=wsj.test1M.tok.gz # Test data from PTB-WSJ (wsj_0000 to wsj_2454).  wc=49208 1173766 6412448
GOLD=wsj.test1M.gold.gz # Gold POS data for TEST.  wc=1222974 2347532 10255603

### TRAIN includes TEST, line numbers between the following two should be excluded:
TESTHEAD=1560570 # The first line of PTB-WSJ in TRAIN (same as first line of TEST)
TESTTAIL=1613710 # The last line of PTB-WSJ in TRAIN (last line of TEST is 1612868)
GETTRAIN=zcat ${TRAIN} | perl -ne 'print if ($$. < ${TESTHEAD} || $$. > ${TESTTAIL})'

### SRILM options:
ORDER=4 # n-gram order
VOCTHR=20 # words seen less than this will be replaced with <unk>

wsj.lm.gz: wsj.vocab.gz wsj.tok.gz
	${GETTRAIN} | ngram-count -order ${ORDER} -kndiscount -interpolate -unk -vocab $< -text - -lm $@

wsj.vocab.gz: wsj.tok.gz # wc=78498   78498  672284
	${GETTRAIN} | ngram-count -write-order 1 -text - -write - | \
	perl -lane 'print $$F[0] if $$F[1] >= ${VOCTHR}' | gzip > $@

clean:
	rm wsj.vocab.gz wsj.lm.gz
