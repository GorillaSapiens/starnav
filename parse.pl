#!/usr/bin/env perl

use strict;
use warnings;

# see https://www.johnpratt.com/items/astronomy/mag_5_stars.html
# see https://johnpratt.com/items/astronomy/mag_5_stars.html

# A	Bright Star (HR) Number
# B	Star Name
# C	Star Designation
# D	Flamsteed Number
# E	Letter Designation
# F	Double Star Component
# G	Constellation Number
# H	Constellation Name
# I	2000 R.A. (hours)
# J	2000 R.A. (minutes)
# K	2000 R.A. (seconds)
# L	Declination (North or South)
# M	Declination (°)
# N	Declination (')
# O	Declination (")
# P	Visual Magnitude
# Q	B-V Color Index
# R	U-B Color Index
# S	Spectral Classification
# T	Proper Motion (R.A.)
# U	Proper Motion (Dec.)
# V	Distance (light years)
# W	Radial Velocity (km/sec)
# X	Sidereal Latitude
# Y	Sidereal Longitude
# Z	Zodiac Longitude
# AA	Zodiac Sector

sub debur($) {
   my $arg = shift @_;
   $arg =~ s/\"//g;
   $arg =~ s/,/%2c/g;
   return ",$arg";
}

my @abbrevs;
my $count = 0;
while (<>) {

   s/,(\"[^\"]*\")/debur($1)/ge;
   s/^[\s]*//g;
   s/[\x0a\x0d]//g;
   s/[\s]+/ /g;

   my @parts = split /,/;
   my %current;

   if ($count > 0) {
      if ($#parts != $#abbrevs) {
         print STDERR "ERROR!!!\n";
         print STDERR $_ . "\n";
         exit 0;
      }

      for (my $i = 0; $i <= $#parts; $i++) {
         $current{$abbrevs[$i]} = $parts[$i];
      }

      if ($parts[0] =~ /^[0-9]+$/) {
         my $bright = $current{"Vmag"};

         my $name = length($current{"Name"}) ?
            $current{"Name"} : $current{"ID"};
         $name .= " / HR " . $current{"HR"};

         my $lat = int($current{"Sid Lat"} * 1e6);

         my $lon = int($current{"Sid Lon"} * 1e6);

         print "$lon,$lat,$bright,$name\n";
      }
   }
   else {
      @abbrevs = @parts;

      # NS for Dec is nameless???
      for (my $i = 0; $i <= $#abbrevs; $i++) {
         if (!length($abbrevs[$i])) {
            $abbrevs[$i] = "Dns";
         }
      }
   }

   $count++;
}
