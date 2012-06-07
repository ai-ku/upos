all: eval.pl fastsubs dists scode wkmeans wordsub

eval.pl: check
	test -e $@ || ln -s ../src/scripts/* .

fastsubs: check
	cd ../src/fastsubs; make
	test -e $@ || ln -s ../src/fastsubs/fastsubs .
	test -e wordsub || ln -s ../src/fastsubs/wordsub .

dists: check
	cd ../src/dist; make
	test -e $@ || ln -s ../src/dist/dists .

scode: check
	cd ../src/scode; make
	test -e $@ || ln -s ../src/scode/scode .

wkmeans: check
	cd ../src/wkmeans; make
	test -e $@ || ln -s ../src/wkmeans/wkmeans .

check:
	true

clean:
	-rm *.pl *.py *.gp fastsubs dists scode wkmeans wordsub
