#!/usr/bin/env perl

use strict;
use warnings;
use Math::Trig qw(deg2rad rad2deg acos);

my @stars;
my %stars;

sub angsep_microdeg {
    my ($ra1_u, $dec1_u, $ra2_u, $dec2_u) = @_;

    # Convert microdegrees -> degrees -> radians
    my $ra1  = deg2rad($ra1_u  / 1e6);
    my $dec1 = deg2rad($dec1_u / 1e6);
    my $ra2  = deg2rad($ra2_u  / 1e6);
    my $dec2 = deg2rad($dec2_u / 1e6);

    # Spherical law of cosines
    my $cos_theta = sin($dec1) * sin($dec2) +
                    cos($dec1) * cos($dec2) * cos($ra1 - $ra2);

    # Clamp against roundoff
    $cos_theta = 1  if $cos_theta > 1;
    $cos_theta = -1 if $cos_theta < -1;

    my $theta = rad2deg(acos($cos_theta));  # degrees

    return int($theta * 1e6 + 0.5);  # return in microdegrees
}

while (<>) {
   s/^[\s]*//g;
   s/[\x0a\x0d]//g;
   s/[\s]+/ /g;

   my ($ra, $dec, $bright, $name) = split /,/;

   if (defined($stars{$name})) {
      print "duplicate name $name\n";
      exit(-1);
   }

   if (length($name)) {
      $stars{$name} = "$ra,$dec,$bright";
   }
}

@stars = keys(%stars);

for (my $i = 0; $i <= $#stars; $i++) {
   my ($ra1, $de1, $bright1) = split /,/, $stars{$stars[$i]};
   for (my $j = $i + 1; $j <= $#stars; $j++) {
      my ($ra2, $de2, $bright2) = split /,/, $stars{$stars[$j]};

      my $sep = angsep_microdeg($ra1, $de1, $ra2, $de2);

      if ($sep > 9 && $sep <= 90_000_000) {
         print "$sep,$stars[$i],$stars[$j]\n";
      }
   }
}
