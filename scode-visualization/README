demo/scode.html is a 3D demo for an SCODE run in 3 dimensions,
visualized with WebGL using Three.js. Training data for this
demonstration is from English portion of MULTEXT-East dataset.

To create a new demo you can use the (very crude) js-data.py
script. Current version only works with 13 clusters, but can easily be
extended.

Usage:
js-data.py SCALING_FACTOR INIT POS KMEANS UPDATES

SCALING_FACTOR is an integer that multiplied with every floating
coordinate value (smaller data size)

INIT is the file containing type and its initial random vector (tab
separated), i.e.
the	-0.702539	-0.691990	0.166098

POS is the file containing type and its gold tag (tab separated), i.e.
the	D

KMEANS is the file containing type and its cluster id (tab separated),
i.e.
the	2

UPDATES is the file containing all the updates SCODE makes until it
stops, i.e.
the	-0.505556	-0.862696	0.012994
clocks	-0.836744	0.140452	-0.529276
were	-0.862178	-0.304747	0.404696
striking	0.638750	0.769366	0.008604
thirteen	0.039086	-0.605798	0.794657
.	-0.450676	-0.720565	-0.526950
Winston	0.709042	0.693363	0.128475
Smith	-0.003784	0.600984	0.799252
,	0.107069	-0.364476	-0.925037
his	-0.144371	0.877196	-0.457912
chin	0.703353	-0.603366	-0.375824
nuzzled	-0.153626	0.871067	-0.466521
into	-0.775165	-0.527735	-0.347296
