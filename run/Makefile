### INSTALLATION:
bin:
	cd ../bin; make

### GENERAL setup:
export PATH := ../bin:${PATH} # Binaries in the bin directory
SEED=1  # Random seed
NCPU=20 # Number of threads/processes to use for parallel computations


### INPUT files:
TRAIN=../data/wsj.tok.gz # WSJ training data from CSR-3.  wc=5187874 126170376 690948662
TEST=../data/wsj.test1M.tok.gz # Test data from PTB-WSJ (wsj_0000 to wsj_2454).  wc=49208 1173766 6412448
GOLD=../data/wsj.test1M.gold.gz # Gold POS data for TEST.  wc=1222974 2347532 10255603
NTEST=1173766 # Number of test instances


### TRAIN includes TEST, line numbers between the following two should be excluded:
TESTHEAD=1560570 # The first line of PTB-WSJ in TRAIN (same as first line of TEST)
TESTTAIL=1613710 # The last line of PTB-WSJ in TRAIN (last line of TEST is 1612868)
GETTRAIN=zcat ${TRAIN} | perl -ne 'print if ($$. < ${TESTHEAD} || $$. > ${TESTTAIL})'


### SRILM options:
LM_NGRAM=4  # n-gram order
LM_VOCAB=20 # words seen less than this in GETTRAIN will be replaced with <unk>
LM_MTYPE=i686-m64 # architecture for compiling srilm

wsj.vocab.gz: ${TRAIN}  ## LM_VOCAB=20: time=1m16s, wc=78498   78498  672284
	${GETTRAIN} | ngram-count -write-order 1 -text - -write - | \
	perl -lane 'print $$F[0] if $$F[1] >= ${LM_VOCAB}' | gzip > $@

wsj.lm.gz: wsj.vocab.gz ${TRAIN} ## LM_NGRAM=4, LM_VOCAB=20: time=6m10s, wc=27427373 118077512 847912087
	${GETTRAIN} | ngram-count -order ${LM_NGRAM} -kndiscount -interpolate -unk -vocab $< -text - -lm $@


### FASTSUBS options:
FS_NSUB=100 # go until you have this many substitutes
FS_PSUB=1.0 # or this much cumulative probability
FS_OPTIONS=-n ${FS_NSUB} -p ${FS_PSUB}

wsj.sub.gz: ${TEST} wsj.lm.gz  ## FS_NSUB=100 FS_PSUB=1: time=4h47m, wc=1222974 245817774 2350067125
	zcat $< | fastsubs ${FS_OPTIONS} wsj.lm.gz | gzip > $@


### KNN options:
KNN=1000 # number of nearest neighbors to compute
KNN_METRIC=1 # 0=euclid, 1=cosine
KNN_OPTIONS=-k ${KNN} -d ${KNN_METRIC} -p ${NCPU}

wsj.knn.gz: wsj.sub.gz  ## KNN=1000 KNN_METRIC=1 NCPU=24: time=21h40m, wc=1173766 2348705766 18877273290
	zcat $< | preinput.py | dists ${KNN_OPTIONS} | gzip > $@


### RPART options:
RPART=65536 # Number of random partitions
RP_OPTIONS=-n ${NTEST} -p ${RPART} -s ${SEED}

wsj.words.gz: ${GOLD}  ## time=1s, wc=1173766 1173766 6412448
	zcat $< | perl -lane 'print $$F[0] if /\S/' | gzip > $@

rpart.pairs.gz: wsj.knn.gz wsj.words.gz ## RPART=65536: time=2m55s wc=1173766 2347532 14694702
	zcat $< | rpart.pl ${RP_OPTIONS} | join.pl wsj.words.gz - | gzip > $@


### WORDSUB options:
WORDSUB=64 # Number of random substitutes per word
WS_OPTIONS=-n ${WORDSUB} -s ${SEED}

wordsub.pairs.gz: wsj.sub.gz ## WS_NSUB=64: time=20m55s wc=75121024 150242048 809663253
	zcat $< | wordsub.pl ${WS_OPTIONS} | gzip > $@


### SCODE options:
# -r RESTART: number of restarts (default 1)                    
# -i NITER: number of iterations over data (default 50)         
# -d NDIM: number of dimensions (default 25)                    
# -z Z: partition function approximation (default 0.166)        
# -p PHI0: learning rate parameter (default 50.0)               
# -u NU0: learning rate parameter (default 0.2)                 
# -s SEED: random seed (default 0)                              
# -c: calculate real Z (default false)                          
# -m: merge vectors at output (default false)                   
# -v: verbose messages (default false)
SC_OPTIONS=-r 1 -i 50 -d 25 -z 0.166 -p 50 -u 0.2 -s ${SEED}

%.scode.gz: %.pairs.gz
	zcat $< | scode ${SC_OPTIONS} | gzip > $@

## With options -r1 -i20 -d25:
## rpart.scode.gz: time=53s wc=49207 1328564 12213908
## wordsub.scode.gz: time=46m2s wc=49207 1328564 12359744


### KMEANS options:
# -k number of clusters (default 2)
# -r number of restarts (default 0)
# -s random seed
# -l input file contains labels
# -w input file contains instance weights
# -v verbose output

KM_OPTIONS=-k 45 -r 16 -l -w -v -s ${SEED}

%.kmeans.gz: %.scode.gz
	zcat $< | perl -ne 'print if s/^0://' | wkmeans ${KM_OPTIONS} | gzip > $@

## With options --k=45 --restarts=10 --init kpp
## rpart.kmeans.gz: time=3m32s wc=1173766 1173766 3155470
## wordsub.kmeans.gz: time=4m20s wc=1173766 1173766 3205200


### EVAL options:
# -m prints many-to-one (default)
# -v prints v-measure
# -g file with gold answers

wsj.pos.gz: ${GOLD}  ## time=1s, wc=1173766 1173766 3793947
	zcat $< | perl -lane 'print $$F[1] if /\S/' | gzip > $@

%.eval: %.kmeans.gz wsj.pos.gz ## time=1s
	zcat $< | wkmeans2eval.pl -t ${TEST} | eval.pl -m -v -g wsj.pos.gz


### RPART experiments:
RPRUN_NARGS=4 # number of arguments for rprun.pl script

rprun.out: ${TEST} wsj.knn.gz wsj.words.gz wsj.pos.gz # NCPU=20 xargs=270: time=3h49m
	rprun-args.pl | xargs -n${RPRUN_NARGS} -P${NCPU} rprun.pl > $@


### WORDSUB experiments:
WSRUN_NARGS=4 # number of arguments for wsrun.pl script

wsrun.out:
	wsrun-args.pl | xargs -n${WSRUN_NARGS} -P${NCPU} wsrun.pl > $@


### BIGRAM experiments (Maron et.al. 2010)

bigram.pairs.gz: ${TEST}
	zcat $< | perl -lne 'for $$w (split) {print "$$p\t$$w" if defined $$p; $$p=$$w;}' | gzip > $@

bigram.scode.gz: bigram.pairs.gz
	zcat $< | scode -m ${SC_OPTIONS} | perl -pe 's/^/0:/' | gzip > $@



.PRECIOUS: wsj.lm.gz wsj.sub.gz wsj.knn.gz wsj.vocab.gz wsj.words.gz wsj.pos.gz \
           %.pairs.gz %.scode.gz %.kmeans.gz


clean:
	-rm -i wsj.lm.gz wsj.sub.gz wsj.knn.gz rprun.out wsrun.out
	-rm wsj.vocab.gz wsj.words.gz wsj.pos.gz
	-rm *.pairs.gz *.scode.gz *.kmeans.gz
	cd ../bin; make clean
	cd ../src; make clean
