#!/usr/bin/env perl

use strict;
use warnings;

# see https://www.johnpratt.com/items/astronomy/mag_5_stars.html
#0  1    2  3 4   5   6    7   8  9   10 1112  13 14 15   16  17  18      19   20  21       22 23      24      25      26
#HR,Name,ID,#,Ltr,Dbl,Con#,Con,RA,RAm,RAs,,Dec,Dm,Ds,Vmag,B-V,U-B,Sp Type,pmRA,pmD,Distance,RV,Sid Lat,Sid Lon,Zod lon,Zod
my $count = 0;
while (<>) {
   if ($count > 0) {
      s/^[\s]*//g;
      s/[\x0a\x0d]//g;
      s/[\s]+/ /g;

      my @parts = split /,/;

      if ($parts[0] =~ /^[0-9]+$/) {
         my $bright = $parts[15];
         my $name = length($parts[1]) ? $parts[1] : $parts[2];
         $name .= " / HR $parts[0]";

         my $ra = int(($parts[8] * 3600 + $parts[9] * 60 + $parts[10]) * 360000000 / 86400);
         my $dec = int (($parts[12] * 3600 + $parts[13] * 60 + $parts[14]) * 360000000 / 1296000);
         if ($parts[11] eq "S") {
            $dec = -$dec;
         }

         print "$ra,$dec,$bright,$name\n";
      }
   }
   $count++;
}
