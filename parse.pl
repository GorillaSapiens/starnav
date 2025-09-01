#!/usr/bin/env perl

while (<>) {
   s/^[\s]*//g;
   s/[\x0a\x0d]//g;
   s/[\s]+/ /g;

   @parts = split / /;

   if ($parts[0] =~ /^[0-9]+$/) {
      $ra = $parts[1];
      $dec = $parts[2];
      $bright = $parts[6];
      $name = $parts[7];

      ($h,$m,$s) = split /:/, $ra;
      $ra = int(($h * 3600 + $m * 60 + $s) * 360000000 / 86400);

      if ($dec =~ /^-/) {
         $neg = 1;
      }
      else {
         $neg = 0;
      }
      $dec =~ s/^[-\+]//g;
      ($d,$m,$s) = split /:/, $dec;
      $dec = int (($d * 3600 + $m * 60 + $s) * 360000000 / 1296000);
      if ($neg == 1) {
         $dec = -$dec;
      }

      print "$ra $dec $bright $name\n";
   }
}
