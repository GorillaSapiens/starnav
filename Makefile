table: catalog.txt table.pl
	./table.pl < catalog.txt

catalog.txt: mag_5_stars.csv parse.pl
	./parse.pl < mag_5_stars.csv > catalog.txt

clean:
	rm -f catalog.txt
	rm -rf table
