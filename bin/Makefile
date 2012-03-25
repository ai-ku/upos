all: eval.pl fastsubs dists scode kmeans 


eval.pl: check
	test -e $@ || ln -s ../src/perl/*.pl .

fastsubs: check
	cd ../src/fastsubs; make
	test -e $@ || ln -s ../src/fastsubs/fastsubs .

dists: check
	cd ../src/dists; make
	test -e $@ || ln -s ../src/dists/{dists,preinput.py} .

scode: check
	cd ../src/scode; make
	test -e $@ || ln -s ../src/scode/scode .

wkmeans: check
	cd ../src/wkmeans; make
	test -e $@ || ln -s ../src/wkmeans/wkmeans .

check:
	true

clean:
	-rm *.pl *.py fastsubs dists scode wkmeans
