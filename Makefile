triangles.txt: angles.txt triangles.pl
	./triangles.pl < angles.txt > triangles.txt

angles.txt: catalog.txt angles.pl
	./angles.pl < catalog.txt > angles.txt

catalog.txt: yale.txt parse.pl
	./parse.pl < yale.txt > catalog.txt

clean:
	rm -f angles.txt catalog.txt
