triangles: angles.txt triangles.pl
	./triangles.pl < angles.txt > triangles.txt

angles.txt: catalog.txt angles.pl
	./angles.pl < catalog.txt > angles.txt

catalog.txt: mag_5_stars.csv parse.pl
	./parse.pl < mag_5_stars.csv > catalog.txt

clean:
	rm -f angles.txt catalog.txt
	rm -rf triangles
