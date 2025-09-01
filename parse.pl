#!/usr/bin/env perl

use strict;
use warnings;

while (<>) {
   s/^[\s]*//g;
   s/[\x0a\x0d]//g;
   s/[\s]+/ /g;

   my @parts = split / /;

   if ($parts[0] =~ /^[0-9]+$/) {
      my $ra = $parts[1];
      my $dec = $parts[2];
      my $bright = $parts[6];
      my $name = $parts[0];

      my ($d, $h, $m, $s, $neg);

      ($h,$m,$s) = split /:/, $ra;
      if (!length($h) || !length($m) || !length($s)) {
         next;
      }
      $ra = int(($h * 3600 + $m * 60 + $s) * 360000000 / 86400);

      if ($dec =~ /^-/) {
         $neg = 1;
      }
      else {
         $neg = 0;
      }
      $dec =~ s/^[-\+]//g;
      ($d,$m,$s) = split /:/, $dec;
      if (!length($d) || !length($m) || !length($s)) {
         next;
      }
      $dec = int (($d * 3600 + $m * 60 + $s) * 360000000 / 1296000);
      if ($neg == 1) {
         $dec = -$dec;
      }

      print "$ra $dec $bright $name\n";
   }
}
