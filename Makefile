angles.txt: catalog.txt angles.pl
	./angles.pl < catalog.txt | sort -n > angles.txt

catalog.txt: yale.txt parse.pl
	./parse.pl < yale.txt > catalog.txt
