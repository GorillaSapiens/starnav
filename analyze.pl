#!/usr/bin/env perl

use strict;
use warnings;

my @clues;
my $mode = 0;
while (<>) {
   s/^[\s]*//g;
   s/[\x0a\x0d]//g;
   s/[\s]+/ /g;

   if ($mode) {
      push @clues, $_;
   }

   if ($mode == 0) {
      print "$_\n";
      if (/==/) {
         $mode = 1;
      }
   }
}

foreach my $clue (@clues) {
   print "$clue\n";
}

print "==\n";
