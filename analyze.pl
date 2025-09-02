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

for (my $i = 0; $i <= $#clues; $i++) {
   my $a = $clues[$i] + 0.0;
   for (my $j = $i+1; $j <= $#clues; $j++) {
      my $b = $clues[$j] + 0.0;
      for (my $k = $j+1; $k <= $#clues; $k++) {
         my @candidates = ();
         my $c = $clues[$k] + 0.0;

         my $biggest = $a;
         if ($b > $biggest) { $biggest = $b; }
         if ($c > $biggest) { $biggest = $c; }

         my @list = ($a/$biggest, $b/$biggest, $c/$biggest);
         @list = sort { $a <=> $b } @list;

         my $u = int($list[0] * 255);
         my $v = int($list[1] * 255);

         for (my $du = -1; $du < 2; $du++) {
            my $uu = $u + $du;
            if ($uu < 0 || $uu >= 256) {
               next;
            }
            for (my $dv = -1; $dv < 2; $dv++) {
               my $vv = $v + $dv;
               if ($vv < 0 || $vv >= 256) {
                  next;
               }

               my $fname = sprintf("triangles/%02x/%02x", $uu, $vv);
               if (-e $fname) {
                  open FILE, $fname;
                  push @candidates, <FILE>;
                  close FILE;
               }
            }
         }

         my $match = -1;
         my $mdist = 0;
         for (my $l = 0; $l <= $#candidates; $l++) {
            my ($a, $b, $c, $d, $e) = split / /, $candidates[$l];
            my $dx = $a - $list[0];
            my $dy = $b - $list[1];
            my $distance = $dx*$dx+$dy*$dy;
            if ($match == -1 || $distance < $mdist) {
               $match = $l;
               $mdist = $distance;
            }
         }

         print $candidates[$match];
      }
   }
}
