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
   my $aa = $clues[$i] + 0.0;
   for (my $j = $i+1; $j <= $#clues; $j++) {
      my $bb = $clues[$j] + 0.0;
      for (my $k = $j+1; $k <= $#clues; $k++) {
         my @candidates = ();
         my $cc = $clues[$k] + 0.0;

         my $biggest = $aa;
         if ($bb > $biggest) { $biggest = $bb; }
         if ($cc > $biggest) { $biggest = $cc; }

         my @list = ($aa/$biggest, $bb/$biggest, $cc/$biggest);
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

         if ($match == -1) {
            print "?? no match for $list[0] $list[1]\n";
            printf("?? %02x/%02x\n", int($list[0] * 255), int($list[1] * 255));
         }
         else {
            print $candidates[$match];
         }
      }
   }
}
