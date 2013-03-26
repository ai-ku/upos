## ### INSTALLATION:
bin:
	cd ../../bin; make

## ### GENERAL setup:
SEED=1 # Random seed
NCPU=10 # Number of threads/processes to use for parallel computations
SRILM_PATH=/opt/srilm/bin/i686-m64
export PATH := ../../bin:.:${SRILM_PATH}:${PATH} # Binaries in the bin directory
LM_DISCOUNT=-kndiscount
## ### INPUT files:
## # WSJ training data from CSR-3.  wc=5187874 126170376 690948662
## NTEST=118424 # Number of test instances of English

### SMALLER DATA for distance, dimensionality reduction and clustering sections
#Top MINI_SIZE words of the data are extracted
MINI_SIZE=24000
mini.tok.gz: ${LANGUAGE}.tok.gz
	zcat $< | perl -lane 'if($$c < ${MINI_SIZE}) { print "$$_";} else {exit(0);}; $$c+=@F' | gzip > $@
	zcat ${LANGUAGE}.gold.gz | perl -lane 'exit(0) if $$c > ${MINI_SIZE} && !$$_; $$c+=@F/2; print;' | gzip > mini.gold.gz

### MINI-SRILM options:

mini.vocab.gz: train.${LANGUAGE}.tok.gz ## LM_VOCAB=2: time=1m16s, wc=78498   78498  672284
	zcat $< | ngram-count -write-order 1 -text - -write - | \
	perl -lane 'print $$F[0] if $$F[1] >= ${MINI_LM_VOCAB}' | gzip > $@

mini.lm.gz: mini.vocab.gz train.${LANGUAGE}.tok.gz mini.tok.gz  ## LM_NGRAM=4, LM_VOCAB=20: time=6m10s, wc=27427373 118077512 847912087
	zcat train.${LANGUAGE}.tok.gz | ngram-count -order ${LM_NGRAM} ${LM_DISCOUNT} -interpolate -unk -vocab $< -text - -lm $@

#ALLSUB Computes the all subs of a given test file
%.allsub.gz: %.tok.gz %.ppl.gz %.unk ## FS_NSUB=100 FS_PSUB=1: time=4h47m, wc=1222974 245817774 2350067125
	zcat $< | subs $*.lm.gz | gzip > $@

#DISTANCE METRICS

MINI_KNN=1000 # number of nearest neighbors to compute
#KNN_METRIC=2 # 0=euclid, 1=cosine 2=manhattan 3=maximum 4=jensen 5=zero-mean covariance
#MINI_KNN_OPTIONS=-k ${KNN} -d ${KNN_METRIC} -p ${NCPU} -v

mini.knnlog%.gz: mini.allsub.gz  ## KNN=1000 KNN_METRIC=1 NCPU=24: time=21h40m, wc=1173766 2348705766 18877273290
	zcat $< | preinput.py | dists -k ${MINI_KNN} -v -g -d $* -p ${NCPU} 2> knnlog$*.err | gzip > mini.knnlog$*.gz 

mini.knn%.gz: mini.allsub.gz  ## KNN=1000 KNN_METRIC=1 NCPU=24: time=21h40m, wc=1173766 2348705766 18877273290
	zcat $< | preinput.py | dists -k ${MINI_KNN} -v -d $* -p ${NCPU}2> knn$*.err  | gzip > mini.knn$*.gz 

## DISTANCE TABLE
SUP_KNN=30
mini.dist: mini.knn0.gz mini.knn1.gz mini.knn2.gz mini.knn3.gz mini.knn4.gz mini.tok.gz
	for label in 0 1 2 3 4 5 log0 log1 log2 log3; do \
		echo "log0_logeuclid log1_logcosine log2_logmanhattan log3_logmaximum 0_euclid 1_cosine 2_manhattan 3_maximum 4_jensen 5_kl2" | sed "s/.*$${label}_\([a-z]*\).*/\1/" >> $@; \
		zcat mini.knn$$label.gz | knnsparse.py mini.gold.gz ${SUP_KNN} >> $@ ; \
	done

## DIM REDUCTION
# Spectral clustering runs on KL2 distance file with 1000NN
DIM_KNN_OPTIONS=-k ${KNN} -v -d 1 -p ${NCPU}

MATLAB_PATH=/mnt/opt/matlab/linux64/R2011a/bin/matlab -nojvm -nodisplay
## knn5 (KL2) is used since it is the best one on full matrix
mini.spectral: mini.knn5.gz
	${MATLAB_PATH} < ../../bin/runsc.m > mini.spectral 2> mini.spectral.err
	gzip mini.spectral.c*

mini.pca: mini.allsub.gz
	${MATLAB_PATH} < ../../bin/runpca.m > mini.pca 2> mini.pca.err
	gzip mini.pca.c*

mini.lle: mini.knn5.gz
	${MATLAB_PATH} < ../../bin/runlle.m > mini.lle 2> mini.lle.err
	gzip mini.lle.c*

mini.iso: mini.knn5.gz
	${MATLAB_PATH} < ../../bin/runiso.m > mini.iso 2> mini.iso.err
	gzip mini.iso.c*

mini.spectral.c%.knn.gz: mini.spectral.c%.gz
	zcat $< | perl -ane 'print scalar(@F); print  " ".$$c++." $$_" foreach @F; print "\n";$$c = 0;' | dists ${DIM_KNN_OPTIONS}  2> mini.spectral.c$*.knn.err | gzip > $@

mini.pca.c%.knn.gz: mini.pca.c%.gz
	zcat $< | perl -ane 'print scalar(@F); print  " ".$$c++." $$_" foreach @F; print "\n";$$c = 0;' | dists ${DIM_KNN_OPTIONS}  2> mini.pca.c$*.knn.err | gzip > $@

mini.lle.c%.knn.gz: mini.lle.c%.gz
	zcat $< | perl -ane 'print scalar(@F); print  " ".$$c++." $$_" foreach @F; print "\n";$$c = 0;' | dists ${DIM_KNN_OPTIONS}  2> mini.lle.c$*.knn.err | gzip > $@

mini.iso.c%.knn.gz: mini.iso.c%.gz
	zcat $< | perl -ane 'print scalar(@F); print  " ".$$c++." $$_" foreach @F; print "\n";$$c = 0;' | dists ${DIM_KNN_OPTIONS}  2> mini.iso.c$*.knn.err | gzip > $@

%.dist: mini.%.c2.knn.gz mini.%.c4.knn.gz mini.%.c8.knn.gz mini.%.c16.knn.gz mini.%.c32.knn.gz mini.%.c64.knn.gz mini.%.c128.knn.gz mini.%.c256.knn.gz mini.%.c512.knn.gz mini.%.c1024.knn.gz mini.%.c2048.knn.gz
	for label in 2 4 8 16 32 64 128 256 512 1024 2048; do \
		echo "$*_c$$label" >> $@; \
		zcat mini.$*.c$$label.knn.gz | knnsparse.py mini.gold.gz ${SUP_KNN} >> $@ ; \
	done

## CLUSTERING

## Spectral clustering
# A distance matrix is available. 
# Top 500 entries of each nearest neighbor is used since it is the
# best working threshold according to my previous experience
# knn2 is used since it is the best on sparse inputs

%.spectral: %.knn2.gz
	${MATLAB_PATH} < ../../bin/runsc1M.m > $*.spectral 2> $*.spectral.err
	gzip $*.spectral.c*

### SRILM options:
LM_NGRAM=4 # n-gram order
#LM_VOCAB=2 # words seen less than this in GETTRAIN will be replaced with <unk>
LM_MTYPE=i686-m64 # architecture for compiling srilm
LM_DISCOUNT=-kndiscount
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

### Distances

KNN=1000 # number of nearest neighbors to compute
KNN_METRIC=2 # 0=euclid, 1=cosine 2=manhattan 3=maximum 4=jensen 5=zero-mean covariance
KNN_OPTIONS=-k ${KNN} -d ${KNN_METRIC} -p ${NCPU} -v

%.knn.gz: %.sub.gz  ## KNN=1000 KNN_METRIC=1 NCPU=24: time=21h40m, wc=1173766 2348705766 18877273290
	zcat $< | preinput.py | dists ${KNN_OPTIONS} | gzip > $@

### FASTSUBS options:
FS_NSUB=100 # go until you have this many substitutes
FS_PSUB=1.0 # or this much cumulative probability
FS_OPTIONS=-n ${FS_NSUB} -p ${FS_PSUB}

%.sub.gz: %.tok.gz %.lm.gz  %.ppl.gz %.unk ## FS_NSUB=100 FS_PSUB=1: time=4h47m, wc=1222974 245817774 2350067125	
	zcat $< | fastsubs ${FS_OPTIONS} $*.lm.gz | gzip > $@

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
RPART_DIST_FILE=knn2
RP_OPTIONS=-n ${NTEST} -p ${RPART} -s ${SEED}

%.words.gz: %.gold.gz  ## time=1s, wc=1173766 1173766 6412448
	zcat $< | perl -lane 'print $$F[0] if /\S/' | gzip > $@

rpart.%.pairs.gz: %.${RPART_DIST_FILE}.gz %.words.gz ## RPART=65536: time=2m55s wc=1173766 2347532 14694702
	zcat $< | rpart.pl ${RP_OPTIONS} | join.pl $*.words.gz - | gzip > $@

RPC_OPTIONS=-r 1 -i 50 -d 25 -z 0.166 -p 50 -u 0.2 -s ${SEED} -v

rpart.%.scode.gz: rpart.%.pairs.gz 
	zcat $< | scode ${RPC_OPTIONS} | gzip > $@

### EXPERIMENTAL-KMEANS ###
rparte.%.scode.gz: rpart.%.pairs.gz 
	zcat $< | scode ${RPC_OPTIONS} -e 1 | gzip > $@

REKM_OPTIONS=-k ${LANG_CL} -r 1 -s ${SEED} -v

rparte.%.kmeans.gz: rpart.%.scode.gz
	zcat $< | wkmeans ${REKM_OPTIONS} | gzip > $@

rparte.%.eval: rparte.%.kmeans.gz
	zcat $< | eval.pl -m -v -g $*.pos.gz

### WORDSUB options:
WORDSUB=12 # Number of random substitutes per word
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
WSC_OPTIONS=-r 1 -i 9 -d 25 -z 0.166 -p 50 -u 0.2 -s ${SEED} -v -a
wordsub.%.scode.gz: wordsub.%.pairs.gz 
	zcat $< | scode ${WSC_OPTIONS} | gzip > $@

KM_OPTIONS=-k ${LANG_CL} -r 128 -l -w  -s ${SEED}
wordsube.%.kmeans.gz: wordsub.%.scode.gz
	zcat $< | wkmeans ${KM_OPTIONS} | gzip > $@

wordsube.%.eval: wordsube.%.kmeans.gz
	zcat $< | eval.pl -m -v -g $*.pos.gz


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

BSC_OPTIONS=-r 1 -i 50 -d 25 -z 0.166 -p 50 -u 0.2 -s ${SEED} -v

bigram.%.scode.gz: bigram.%.pairs.gz
	zcat $< | scode -m  ${BSC_OPTIONS} | gzip > $@
BIKM_OPTIONS=-k ${LANG_CL} -r 128 -l -w  -s ${SEED}
bigram.${LANGUAGE}.kmeans.gz: bigram.${LANGUAGE}.scode.gz
	zcat $< | wkmeans ${BIKM_OPTIONS} | gzip > $@

### Frame Experiments

frame.%.pairs.gz: enw.tok.gz
	frame.py $* $< | gzip > $@

FSC_OPTIONS=-r 1 -i 50 -d 25 -z 0.166 -p 50 -u 0.2 -s ${SEED}

frame.%.scode.gz: frame.%.pairs.gz
	zcat $< | scode  ${FSC_OPTIONS} | gzip > $@

frame.%.yscode.gz: frame.%.pairs.gz
	zcat $< | scode  ${FSC_OPTIONS} -e 1 | gzip > $@

FRKM_OPTIONS=-k ${LANG_CL} -r 128 -l -w  -s ${SEED}
frame.%.kmeans.gz: framke.%.scode.gz
	zcat $< | wkmeans ${FRKM_OPTIONS} | gzip > $@

FRKME_OPTIONS=-k ${LANG_CL} -r 1 -s ${SEED}
frame.%.ykmeans.gz: frame.%.yscode.gz
	zcat $< | wkmeans ${FRKME_OPTIONS} | gzip > $@

frame.%.yeval: frame.%.ykmeans.gz
	zcat $< | eval.pl -m -v -g ${LANGUAGE}.pos.gz


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
	feature-table.pl ${DIS_FEAT_OPT} -w $< | gzip > ${DISO_FEAT}
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
	cat $< | plotdata.pl 1=x 3=25 3=0.166 9=y > $@


### 4.3.2 WORDSUB + ORTOGRAPHIC + SUFFIX FEATURES experiments(DIS+O+M):
DISOM_NARGS=10 # ntest, nclu, lang, ntok, seed, nsub, ndim, z => scode-logl, wkmeans-rms, m2o, homo, comp, vm, time
DISOM_FEAT=test.$*.disomfeat.gz

dis+om.%.out: %.seg.gz %.words.gz %.pos.gz %.sub.gz 
	feature-table.pl ${DIS_FEAT_OPT} -s $< -w $*.words.gz | gzip > ${DISOM_FEAT}
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

### TYPE-TOKEN EXPERIMENTS

### FRAME:
FRAME_NARGS=5
###LEFT BIGRAM experiments
%.lbi.gz: %.tok.gz 
	frame.py lbi $< | gzip > $@

### LEFT X+Y
frame-lbi+xy.%.out: %.lbi.gz %.words.gz %.pos.gz
	frame-args.pl ${LANG_CL} ${LANGUAGE} lbi token | xargs -n${FRAME_NARGS} -P${NCPU} frame-run.pl > $@

lbi+xyplot-s.%.dat: frame-lbi+xy.%.out
		cat $< | plotdata.pl 1=x 4=y > $@

lbi+xyplot-v.%.dat: frame-lbi+xy.%.out
		cat $< | plotdata.pl 1=x 7=y > $@

### LEFT X
frame-lbi+x.%.out: %.lbi.gz %.words.gz %.pos.gz
	frame-args.pl ${LANG_CL} ${LANGUAGE} lbi type | xargs -n${FRAME_NARGS} -P${NCPU} frame-run.pl > $@

lbi+xplot-s.%.dat: frame-lbi+x.%.out
		cat $< | plotdata.pl 1=x 4=y > $@

lbi+xplot-v.%.dat: frame-lbi+x.%.out
		cat $< | plotdata.pl 1=x 7=y > $@

### LEFT Y
frame-lbi+y.%.out: %.lbi.gz %.words.gz %.pos.gz
	frame-args.pl ${LANG_CL} ${LANGUAGE} lbi ytoken | xargs -n${FRAME_NARGS} -P${NCPU} frame-run.pl > $@

lbi+yplot-s.%.dat: frame-lbi+y.%.out
		cat $< | plotdata.pl 1=x 4=y > $@

lbi+yplot-v.%.dat: frame-lbi+y.%.out
		cat $< | plotdata.pl 1=x 7=y > $@

###RIGHT BIGRAM experiments
%.rbi.gz: %.tok.gz
	frame.py rbi $< | gzip > $@

### RIGHT X+Y
frame-rbi+xy.%.out: %.rbi.gz %.words.gz %.pos.gz
	frame-args.pl ${LANG_CL} ${LANGUAGE} rbi token | xargs -n${FRAME_NARGS} -P${NCPU} frame-run.pl > $@

rbi+xyplot-s.%.dat: frame-rbi+xy.%.out
		cat $< | plotdata.pl 1=x 4=y > $@

rbi+xyplot-v.%.dat: frame-rbi+xy.%.out
		cat $< | plotdata.pl 1=x 7=y > $@

### RIGHT X
frame-rbi+x.%.out: %.rbi.gz %.words.gz %.pos.gz
	frame-args.pl ${LANG_CL} ${LANGUAGE} rbi type | xargs -n${FRAME_NARGS} -P${NCPU} frame-run.pl > $@

rbi+xplot-s.%.dat: frame-rbi+x.%.out
		cat $< | plotdata.pl 1=x 4=y > $@

rbi+xplot-v.%.dat: frame-rbi+x.%.out
		cat $< | plotdata.pl 1=x 7=y > $@

### RIGHT Y
frame-rbi+y.%.out: %.rbi.gz %.words.gz %.pos.gz
	frame-args.pl ${LANG_CL} ${LANGUAGE} rbi ytoken | xargs -n${FRAME_NARGS} -P${NCPU} frame-run.pl > $@

rbi+yplot-s.%.dat: frame-rbi+y.%.out
		cat $< | plotdata.pl 1=x 4=y > $@

rbi+yplot-v.%.dat: frame-rbi+y.%.out
		cat $< | plotdata.pl 1=x 7=y > $@

###FLE BIGRAM experiments
%.fle.gz: %.tok.gz
	frame.py fle $< | gzip > $@

### FLE X+Y
frame-fle+xy.%.out: %.fle.gz %.words.gz %.pos.gz
	frame-args.pl ${LANG_CL} ${LANGUAGE} fle token | xargs -n${FRAME_NARGS} -P${NCPU} frame-run.pl > $@

fle+xyplot-s.%.dat: frame-fle+xy.%.out
		cat $< | plotdata.pl 1=x 4=y > $@

fle+xyplot-v.%.dat: frame-fle+xy.%.out
		cat $< | plotdata.pl 1=x 7=y > $@

### FLE X
frame-fle+x.%.out: %.fle.gz %.words.gz %.pos.gz
	frame-args.pl ${LANG_CL} ${LANGUAGE} fle type | xargs -n${FRAME_NARGS} -P${NCPU} frame-run.pl > $@
	paste fletype*.out | gzip > fletype.out.gz
	-rm fletype*.out

fle+xplot-s.%.dat: frame-fle+x.%.out
		cat $< | plotdata.pl 1=x 4=y > $@

fle+xplot-v.%.dat: frame-fle+x.%.out
		cat $< | plotdata.pl 1=x 7=y > $@

###FRE BIGRAM experiments
%.fre.gz: %.tok.gz
	frame.py fre $< | gzip > $@

### FRE X+Y
frame-fre+xy.%.out: %.fre.gz %.words.gz %.pos.gz
	frame-args.pl ${LANG_CL} ${LANGUAGE} fre token | xargs -n${FRAME_NARGS} -P${NCPU} frame-run.pl > $@
	paste fretoken*.out | gzip > fretoken.out.gz
	-rm fretoken*.out

fre+xyplot-s.%.dat:  frame-fre+xy.%.out
		cat $< | plotdata.pl 1=x 4=y > $@

fre+xyplot-v.%.dat: frame-fre+xy.%.out
		cat $< | plotdata.pl 1=x 7=y > $@

### FRE X
frame-fre+x.%.out: %.fre.gz %.words.gz %.pos.gz
	frame-args.pl ${LANG_CL} ${LANGUAGE} fre type | xargs -n${FRAME_NARGS} -P${NCPU} frame-run.pl > $@
	paste fretype*.out | gzip > fretype.out.gz
	-rm fretype*.out

fre+xplot-s.%.dat: frame-fre+x.%.out
		cat $< | plotdata.pl 1=x 4=y > $@

fre+xplot-v.%.dat: frame-fre+x.%.out
		cat $< | plotdata.pl 1=x 7=y > $@

### FRE Y

frame-fre+y.%.out: %.fre.gz %.words.gz %.pos.gz
	frame-args.pl ${LANG_CL} ${LANGUAGE} fre ytoken | xargs -n${FRAME_NARGS} -P${NCPU} frame-run.pl > $@
	paste freytoken*.out | gzip > freytoken.out.gz
	-rm freytoken*.out

fre+yplot-s.%.dat: frame-fre+y.%.out
		cat $< | plotdata.pl 1=x 4=y > $@

fre+yplot-v.%.dat: frame-fre+y.%.out
		cat $< | plotdata.pl 1=x 7=y > $@

### SCODE
### SCODE X experiments
DISX_NARGS=10
DISX_NSUB=64

dis+x.%.out:  %.pos.gz %.words.gz %.sub.gz
		disrun-args.pl ${LANG_CL} ${LANGUAGE} | perl -lane 'print if $$F[5] == ${DISX_NSUB}' |xargs -n${DISX_NARGS} -P${NCPU} disrun.pl > $@
		paste type*.out | gzip > type.out.gz
		-rm type*.out

dis+xplot-s.%.dat: dis+x.%.out
	cat $< | plotdata.pl 1=x 4=y > $@

dis+xplot-v.%.dat: dis+x.%.out
	cat $< | plotdata.pl 1=x 7=y > $@

### SCODE Y experiments
DISY_NARGS=4
DISY_NSUB=64

dis+y.%.out:  %.pos.gz %.words.gz %.sub.gz
		dis+y-args.pl ${LANG_CL} ${LANGUAGE} ${DISY_NSUB} | xargs -n${DISY_NARGS} -P${NCPU} dis+y-run.pl > $@
		paste context*.out | gzip > context.out.gz
		-rm context*.out

dis+yplot-s.%.dat: dis+y.%.out
	cat $< | plotdata.pl 1=x 4=y > $@

dis+yplot-v.%.dat: dis+y.%.out
	cat $< | plotdata.pl 1=x 7=y > $@

### SCODE X+Y experiments
DISXY_NARGS=4
DISXY_NSUB=64

dis+xy.%.out: %.sub.gz %.words.gz %.pos.gz
	dis+xy-args.pl ${LANG_CL} ${LANGUAGE} ${DISXY_NSUB} | xargs -n${DISXY_NARGS} -P${NCPU} dis+xy-run.pl > $@
	paste xytoken*.out | gzip > xytoken.out.gz
	-rm xytoken*.out

dis+xyplot-s.%.dat: dis+xy.%.out
	cat $< | plotdata.pl 1=x 4=y > $@

dis+xyplot-v.%.dat: dis+xy.%.out
	cat $< | plotdata.pl 1=x 7=y > $@

### SCODE X+Y Featuresexperiments
DISFXY_NARGS=5
DISFXY_NSUB=64
DISFXY_FEAT=test.$*.dis+omxyfeat.gz

dis+omxy.%.out: %.seg.gz %.sub.gz %.words.gz %.pos.gz 
	feature-table.pl ${DIS_FEAT_OPT} -s $< -w $*.words.gz | gzip > ${DISFXY_FEAT}
	dis+omxy-args.pl ${LANG_CL} ${LANGUAGE} ${DISFXY_NSUB} ${DISFXY_FEAT} | xargs -n${DISFXY_NARGS} -P${NCPU} dis+omxy-run.pl > $@
	paste xyftoken*.out | gzip > xyftoken.out.gz
	-rm xyftoken*.out
	-rm ${DISFXY_FEAT}

dis+omxyplot-s.%.dat: dis+omxy.%.out
	cat $< | plotdata.pl 1=x 4=y > $@

dis+omxyplot-v.%.dat: dis+omxy.%.out
	cat $< | plotdata.pl 1=x 7=y > $@

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

plotall: displot-s.${LANGUAGE}.dat displot-v.${LANGUAGE}.dat dis+oplot-s.${LANGUAGE}.dat dis+oplot-v.${LANGUAGE}.dat dis+omplot-s.${LANGUAGE}.dat dis+omplot-v.${LANGUAGE}.dat

### Analysis:
# m2o-analysis.py and cluster-analysis.py in upos/src/scripts are
# interactive analysis scripts.  They are used during the paper
# writing and included in the repository however not in the makefile.
#

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
