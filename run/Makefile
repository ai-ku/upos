## ### INSTALLATION:
bin:
	cd ../../bin; make

## ### GENERAL setup:
SEED=1 # Random seed
NCPU=10 # Number of threads/processes to use for parallel computations
SRILM_PATH=/opt/srilm/bin/i686-m64
export PATH := ../../bin:.:${SRILM_PATH}:${PATH} # Binaries in the bin directory
## ### INPUT files:
## # WSJ training data from CSR-3.  wc=5187874 126170376 690948662
## NTEST=118424 # Number of test instances of English

### SRILM options:
LM_NGRAM=4 # n-gram order
#LM_VOCAB=2 # words seen less than this in GETTRAIN will be replaced with <unk>
LM_MTYPE=i686-m64 # architecture for compiling srilm
LM_DISCOUNT=-wbdiscount
#GET_LANG=`perl -e '$$var=${TEST}; $$var=~m/_(\w\w)./;print $$1;'`

%.vocab.gz: train.%.tok.gz ## LM_VOCAB=2: time=1m16s, wc=78498   78498  672284
	zcat $< | ngram-count -write-order 1 -text - -write - | \
	perl -lane 'print $$F[0] if $$F[1] >= ${LM_VOCAB}' | gzip > $@

%.lm.gz: %.vocab.gz train.%.tok.gz ## LM_NGRAM=4, LM_VOCAB=20: time=6m10s, wc=27427373 118077512 847912087
	zcat train.$*.tok.gz | ngram-count -order ${LM_NGRAM} ${LM_DISCOUNT} -interpolate -unk -vocab $< -text - -lm $@

%.ppl.gz: %.lm.gz %.tok.gz
	zcat $*.tok.gz | \
	ngram -order ${LM_NGRAM} -unk -lm $< -ppl - -debug 2 | gzip > $@

%.unk: %.vocab.gz %.tok.gz # Calculates unknown word ratio
	unknown.pl $< $*.tok.gz > $@

### FASTSUBS options:
FS_NSUB=100 # go until you have this many substitutes
FS_PSUB=1.0 # or this much cumulative probability
FS_OPTIONS=-n ${FS_NSUB} -p ${FS_PSUB}

%.sub.gz: %.tok.gz %.lm.gz  ## FS_NSUB=100 FS_PSUB=1: time=4h47m, wc=1222974 245817774 2350067125	
	zcat $< | fastsubs ${FS_OPTIONS} $*.lm.gz | gzip > $@

### KNN options:[??del or comment out]
KNN=1000 # number of nearest neighbors to compute
KNN_METRIC=2 # 0=euclid, 1=cosine 2=manhattan 3=maximum 4=jensen 5=zero-mean covariance
KNN_OPTIONS=-k ${KNN} -d ${KNN_METRIC} -p ${NCPU} -v

%.knn.gz: %.sub.gz  ## KNN=1000 KNN_METRIC=1 NCPU=24: time=21h40m, wc=1173766 2348705766 18877273290
	zcat $< | preinput.py | dists ${KNN_OPTIONS} | gzip > $@

### 2.5.1 MORFESSOR:
# creates the segmentation file with morfessor
# -m for path to morfessor
# -p for ppl threshold
MORFESSOR=../../src/morfessor
PPLTHRESH=1
%.seg.gz: %.words.gz # time=32m56s wc=50069  182579 1059157
	zcat $< | run-morfessor.pl -m ${MORFESSOR} -p ${PPLTHRESH}  | gzip > $@

### 2.6.1 FEATURE-TABLE of morphessor split:
# creates the feature table
# -s segmentation file from morfessor
# -w tokens from wsj.test1M.gz
# -p put a common feature for punctuation marks /PP/

%.feat.gz: %.seg.gz %.words.gz  # time=2s wc=33065   70599  525357
	feature-table.pl -p -s $< -w $*.words.gz | gzip > $@

### RPART options:[??del or comment out]
RPART=65536 # Number of random partitions
RP_OPTIONS=-n ${NTEST} -p ${RPART} -s ${SEED}

%.words.gz: %.gold.gz  ## time=1s, wc=1173766 1173766 6412448
	zcat $< | perl -lane 'print $$F[0] if /\S/' | gzip > $@

rpart.%.pairs.gz: %.knn.gz %.words.gz ## RPART=65536: time=2m55s wc=1173766 2347532 14694702
	zcat $< | rpart.pl ${RP_OPTIONS} | join.pl $*.words.gz - | gzip > $@

### WORDSUB options:
WORDSUB=1 # Number of random substitutes per word
WS_OPTIONS=-n ${WORDSUB} -s ${SEED}

wordsub.%.pairs.gz: %.sub.gz ## WS_NSUB=64: time=20m55s wc=75121024 150242048 809663253
	perl -le 'print "$<" for 1..${WORDSUB}' | xargs zcat | grep -v '^</s>' | wordsub -s ${SEED} | gzip > $@

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
WSC_OPTIONS=-r 1 -i 100 -d 25 -z 0.166 -p 50 -u 0.2 -s ${SEED} -v
wordsub.%.scode.gz: wordsub.%.pairs.gz 
	zcat $< | scode ${WSC_OPTIONS} | gzip > $@

### KMEANS options:
# -k number of clusters (default 2)
# -r number of restarts (default 0)
# -s random seed
# -l input file contains labels
# -w input file contains instance weights
# -v verbose output

KM_OPTIONS=-k ${LANG_CL} -r 128 -l -w  -s ${SEED}

%.kmeans.gz: %.scode.gz
#	zcat $< | wkmeans ${KM_OPTIONS} | gzip > $@
	zcat $< | perl -ne 'print if s/^0://' | wkmeans ${KM_OPTIONS} | gzip > $@

## With options --k=45 --restarts=10 --init kpp
## rpart.kmeans.gz: time=3m32s wc=1173766 1173766 3155470
## wordsub.kmeans.gz: time=4m20s wc=1173766 1173766 3205200

### EVAL options:
# -m prints many-to-one (default)
# -v prints v-measure
# -g file with gold answers

%.pos.gz: %.gold.gz  ## time=1s, wc=1173766 1173766 3793947
	zcat $< | perl -lane 'print $$F[1] if /\S/' | gzip > $@

.SECONDEXPANSION:
%.ans: $$(word 2, $$(subst ., ,%)).pos.gz %.kmeans.gz
	zcat $*.kmeans.gz | wkmeans2eval.pl -t ${LANGUAGE}.tok.gz | perl -lane 'print "$$i++ $$F[0]"' > $@

.SECONDEXPANSION:
%.eval: ${LANGUAGE}.pos.gz %.kmeans.gz 
	zcat $*.kmeans.gz | wkmeans2eval.pl -t ${LANGUAGE}.tok.gz | eval.pl -m -v -g ${LANGUAGE}.pos.gz

### BIGRAM options (needs scode -m): (Maron et.al. 2010)

bigram.%.pairs.gz: %.tok.gz
	zcat $< | perl -lne 'for $$w (split) {print "$$p\t$$w" if defined $$p; $$p=$$w;}' | gzip > $@

BSC_OPTIONS=-r 1 -i 100 -d 25 -z 0.166 -p 50 -u 0.2 -s ${SEED} -v

bigram.%.scode.gz: bigram.%.pairs.gz
	zcat $< | scode -m -i 50 ${BSC_OPTIONS} | gzip > $@

bigram.${LANGUAGE}.kmeans.gz: bigram.${LANGUAGE}.scode.gz
	zcat $< | wkmeans ${KM_OPTIONS} | gzip > $@

### 3.1.4 WORDSUB+FEATURES options:

ws+f.%.pairs.gz: wordsub.%.pairs.gz %.feat.gz  # time=7s wc=4493184 8986368 51775335
	zcat $< | add-features-3.pl -f $*.feat.gz | gzip > $@

ws+f.%.scode.gz: ws+f.%.pairs.gz # -i 10: time=2m22s wc=49206 1328562 12222826
	zcat $< | scode ${WSC_OPTIONS} | gzip > $@

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
SC_OPTIONS=-r 1 -i 101 -d 25 -z 0.166 -p 50 -u 0.2 -s ${SEED} -v

%.scode.gz: %.pairs.gz
	zcat $< | scode ${SC_OPTIONS} | gzip > $@

## With options -r1 -i20 -d25:
## rpart.scode.gz: time=53s wc=49207 1328564 12213908
## wordsub.scode.gz: time=46m2s wc=49207 1328564 12359744

### RPART experiments:
RPRUN_NARGS=4 # seed, npart, ndim, z => scode-logl, wkmeans-rms, m2o, homo, comp, vm, time

rprun.out: ${TEST} wsj.knn.gz wsj.words.gz wsj.pos.gz # NCPU=20 xargs=270: time=3h49m
	./rprun-args.pl | xargs -n${RPRUN_NARGS} -P${NCPU} rprun.pl > $@

plot-p.dat: rprun.out
	cat $< | plotdata.pl 1=x 2=25 3=0.166 6=y > $@

plot-d.dat: rprun.out
	cat $< | plotdata.pl 1=16384 2=x 3=0.166 6=y > $@

plot-z.dat: rprun.out
	cat $< | plotdata.pl 1=16384 2=25 3=x 6=y > $@


### WORDSUB experiments(DIS):
DIS_NARGS=10 # ntest,nclu, lang, seed, nsub, ndim, z $nu $phi => scode-logl, wkmeans-rms, m2o, homo, comp, vm, time

dis.%.out:  %.pos.gz %.words.gz %.sub.gz
	disrun-args.pl ${LANG_CL} ${LANGUAGE} | xargs -n${DIS_NARGS} -P${NCPU} disrun.pl > $@

displot-s.%.dat: dis.%.out
	cat $< | plotdata.pl 2=x 3=25 4=0.166 7=y > $@

displot-v.%.dat: dis.%.out
	cat $< | plotdata.pl 2=x 3=25 4=0.166 10=y > $@

displot-d.%.dat: dis.%.out
	cat $< | plotdata.pl 1=64 2=x 3=0.166 6=y > $@

displot-z.%.dat: dis.%.out
	cat $< | plotdata.pl 1=64 2=25 3=x 6=y > $@

### 4.3.1 WORDSUB + ORTOGRAPHIC  experiments(DIS+O):
DISO_NARGS=10 # ntest, nclu, lang, ntok, seed, nsub, ndim, z => scode-logl, wkmeans-rms, m2o, homo, comp, vm, time
DISO_FEAT=test.$*.disofeat.gz

dis+o.%.out: %.words.gz %.pos.gz %.sub.gz 
	feature-table.pl -p -w $*.words.gz | gzip > ${DISO_FEAT}
	dis+f-args.pl ${LANG_CL} ${LANGUAGE} ${DISO_FEAT} | xargs -n ${DISO_NARGS} -P${NCPU} dis+f-run.pl > $@
	rm ${DISO_FEAT}

dis+o-a.%.dat: dis+o.%.out
	cat $< | plotdata.pl 1=x 2=25 3=0.166 6=y > $@.tmp1
	cat $< | plotdata.pl 1=x 2=25 3=0.166 9=y > $@.tmp2
	paste $@.tmp1 $@.tmp2 > $@
	-rm $@.tmp1 $@.tmp2
	cat $@

dis+oplot-s.%.dat: dis+o.%.out
	cat $< | plotdata.pl 1=x 2=25 3=0.166 6=y > $@

dis+oplot-v.%.dat: dis+o.%.out
	cat $< | plotdata.pl 1=x 2=25 3=0.166 9=y > $@


### 4.3.2 WORDSUB + ORTOGRAPHIC + SUFFIX FEATURES experiments(DIS+O+M):
DISOM_NARGS=10 # ntest, nclu, lang, ntok, seed, nsub, ndim, z => scode-logl, wkmeans-rms, m2o, homo, comp, vm, time
DISOM_FEAT=test.$*.disomfeat.gz

dis+om.%.out: %.seg.gz %.words.gz %.pos.gz %.sub.gz 
	feature-table.pl -p -s $< -w $*.words.gz | gzip > ${DISOM_FEAT}
	dis+f-args.pl ${LANG_CL} ${LANGUAGE} ${DISOM_FEAT} | xargs -n ${DISOM_NARGS} -P${NCPU} dis+f-run.pl > $@
	rm ${DISOM_FEAT}

dis+om-a.%.dat: dis+om.%.out
	cat $< | plotdata.pl 1=x 2=25 3=0.166 6=y > $@.tmp1
	cat $< | plotdata.pl 1=x 2=25 3=0.166 9=y > $@.tmp2
	paste $@.tmp1 $@.tmp2 > $@
	-rm $@.tmp1 $@.tmp2
	cat $@

dis+omplot-s.%.dat: dis+om.%.out
	cat $< | plotdata.pl 1=x 2=25 3=0.166 6=y > $@

dis+omplot-v.%.dat: dis+om.%.out
	cat $< | plotdata.pl 1=x 2=25 3=0.166 9=y > $@

### WKMEANS experiments:
KMRUN_NARGS=4 # seed, file, weights, nstart => wkmeans-rms, m2o, homo, comp, vm, time

kmrun.out:
	kmrun-args.pl | xargs -n${KMRUN_NARGS} -P${NCPU} kmrun.pl > $@

### BIGRAM experiments:
BGRUN_NARGS=3 # seed nclu, lang => scode-logl, wkmeans-rms, m2o, homo, comp, vm, time

bgrun.%.out: %.gold.gz %.pos.gz %.words.gz bigram.%.pairs.gz
	bgrun-args.pl ${LANG_CL} ${LANGUAGE} | xargs -n${BGRUN_NARGS} -P${NCPU} bgrun.pl > $@

bgplot-s.%.dat: bgrun.%.out
	cat $< | plotdata.pl 1=x 2=0.166 5=y > $@

bgplot-v.%.dat: bgrun.%.out
	cat $< | plotdata.pl 1=x 2=0.166 8=y > $@

### PLOT generation:
# The dat files contain the following columns after (inputs excluding seed):
# scode-logl-mean scode-logl-std
# wkmeans-rms-mean wkmeans-rms-std
# m2o-mean m2o-std
# homo-mean homo-std
# comp-mean comp-std
# vm-mean vm-std
# time-mean time-std (in seconds)

.SECONDARY: 
	%.lm.gz %.sub.gz %.knn.gz %.vocab.gz %.words.gz %.pos.gz \
           %.pairs.gz %.scode.gz %.kmeans.gz\
           rprun.out wsrun.out kmrun.out bgrun.out

clean:
	-rm -i *.lm.gz *.sub.gz *.knn.gz rprun.out wsrun.out kmrun.out bgrun.out
	-rm *.vocab.gz *.words.gz *.pos.gz
	-rm *.pairs.gz *.scode.gz *.kmeans.gz
	-rm plot-?.dat
	cd ../bin; make clean
	cd ../src; make clean
