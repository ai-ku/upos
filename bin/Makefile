all: eval.pl fastsubs dists scode wkmeans wordsub readsparse.mexa64 runsc.m runpca.m runlle.m runiso.m

eval.pl: check
	test -e $@ || ln -s ../src/scripts/* .

fastsubs: check
	cd ../src/fastsubs; make
	test -e $@ || ln -s ../src/fastsubs/fastsubs
	test -e subs || ln -s ../src/fastsubs/subs
	test -e wordsub || ln -s ../src/fastsubs/wordsub .

dists: check
	cd ../src/dist; make
	test -e $@ || ln -s ../src/dist/dists .

runsc.m: check
	cd ../src/spectral;
	test -e $@ || ln -s ../src/spectral/runsc.m
	test -e sc.m || ln -s ../src/spectral/sc.m

runpca.m: check
	cd ../src/pca;
	test -e $@ || ln -s ../src/pca/runpca.m

runlle.m: check
	cd ../src/lle;
	test -e $@ || ln -s ../src/lle/runlle.m
	test -e lle.m || ln -s ../src/lle/lle.m

runiso.m: check
	cd ../src/iso; make
	test -e $@ || ln -s ../src/iso/runiso.m
	test -e IsomapII.m || ln -s ../src/iso/IsomapII.m
	test -e dijkstra.mexa64 || ln -s ../src/iso/dijkstra.mexa64

readsparse.mexa64: check
	cd ../src/readsparse/; make
	test -e readsparse.mexa64 || ln -s ../src/readsparse/readsparse.mexa64
	test -e readsparseidx.mexa64 || ln -s ../src/readsparse/readsparseidx.mexa64

scode: check
	cd ../src/scode; make
	test -e $@ || ln -s ../src/scode/scode .

wkmeans: check
	cd ../src/wkmeans; make
	test -e $@ || ln -s ../src/wkmeans/wkmeans .

check:
	true

clean:
	-rm *.m *.pl *.py *.gp *.sh fastsubs subs dists scode wkmeans wordsub *.mexa64
