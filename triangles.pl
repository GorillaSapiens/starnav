#!/usr/bin/env perl

use strict;
use warnings;
use Math::Trig qw(deg2rad rad2deg acos);

my %stars;
my %angles;

while (<>) {
   s/[\x0a\x0d]//g;
   my ($angle, $a, $b) = split / /;

   $angles{"$a:$b"} = $angle;
   if (defined($stars{$a})) {
      $stars{$a} = $stars{$a} . "," . $b;
   }
   else {
      $stars{$a} = $b;
   }

   $angles{"$b:$a"} = $angle;
   if (defined($stars{$b})) {
      $stars{$b} = $stars{$b} . "," . $a;
   }
   else {
      $stars{$b} = $a;
   }
}

my @stars = keys(%stars);

for (my $i = 0; $i <= $#stars; $i++) {
   my $iname = $stars[$i];
   my @i_neighbors = split /,/, $stars{$iname};
   foreach my $jname (@i_neighbors) {
      my @j_neighbors = split /,/, $stars{$jname};
      foreach my $kname (@j_neighbors) {
         if (grep { $_ eq $kname } @i_neighbors) {
            # $iname, $jname, $kname form a triangle!
            my $aij = $angles{"$iname:$jname"};
            my $ajk = $angles{"$jname:$kname"};
            my $aki = $angles{"$kname:$iname"};

            my $biggest = $aij;
            if ($ajk > $biggest) { $biggest = $ajk; }
            if ($aki > $biggest) { $biggest = $aki; }

            $aij /= $biggest;
            $ajk /= $biggest;
            $aki /= $biggest;

            my @list = ($aij, $ajk, $aki);
            @list = sort { $a <=> $b } @list;

            print "$list[0] $list[1] $iname $jname $kname\n";
         }
      }
   }
}
