all: eval.pl fastsubs dists scode wkmeans wordsub

eval.pl: check
	test -e $@ || ln -s ../src/scripts/*.* .

fastsubs: check
	cd ../src/fastsubs; make
	test -e $@ || ln -s ../src/fastsubs/fastsubs .

dists: check
	cd ../src/dists; make
	test -e dists || ln -s ../src/dists/dists .
	test -e preinput.py || ln -s ../src/dists/preinput.py .

scode: check
	cd ../src/scode; make
	test -e $@ || ln -s ../src/scode/scode .

wkmeans: check
	cd ../src/wkmeans; make
	test -e $@ || ln -s ../src/wkmeans/wkmeans .

wordsub: check
	cd ../src/wordsub; make
	test -e $@ || ln -s ../src/wordsub/wordsub .

check:
	true

clean:
	-rm *.pl *.py fastsubs dists scode wkmeans wordsub
