#!/usr/bin/env perl

use strict;
use warnings;
use Math::Trig qw(deg2rad rad2deg acos);

my @stars;
my %stars;

my %angles;

my %hex;
`mkdir -p table`;
for (my $i = 0; $i < 256; $i++) {
   my $n = sprintf("%02x", $i);
   $hex{$i} = $n;
   `mkdir -p table/$n`;
}

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

# Convert RA/Dec (microdegrees) to unit Cartesian vector on the celestial sphere
sub radec_u_to_vec {
    my ($ra_u, $dec_u) = @_;
    my $ra  = deg2rad($ra_u  / 1e6);
    my $dec = deg2rad($dec_u / 1e6);
    my $c   = cos($dec);
    return [ $c*cos($ra), $c*sin($ra), sin($dec) ];
}

sub v_add { [ $_[0]->[0]+$_[1]->[0], $_[0]->[1]+$_[1]->[1], $_[0]->[2]+$_[1]->[2] ] }
sub v_dot { $_[0]->[0]*$_[1]->[0] + $_[0]->[1]*$_[1]->[1] + $_[0]->[2]*$_[1]->[2] }
sub v_cross {
    my ($a,$b)=@_;
    return [ $a->[1]*$b->[2]-$a->[2]*$b->[1],
             $a->[2]*$b->[0]-$a->[0]*$b->[2],
             $a->[0]*$b->[1]-$a->[1]*$b->[0] ];
}
sub v_scale { my ($a,$s)=@_; [ $a->[0]*$s, $a->[1]*$s, $a->[2]*$s ] }
sub v_norm  { my ($a)=@_; my $m=sqrt(v_dot($a,$a)); v_scale($a, 1.0/$m) }

# Orientation of three stars A,B,C given as (RA_u,Dec_u)
# Returns +1 for CCW, -1 for CW in local East(+x)/North(+y)
sub orientation_enu {
    my ($ra1,$de1, $ra2,$de2, $ra3,$de3) = @_;

    my $v1 = radec_u_to_vec($ra1,$de1);
    my $v2 = radec_u_to_vec($ra2,$de2);
    my $v3 = radec_u_to_vec($ra3,$de3);

    # Local "zenith" ~ average direction; normalize
    my $c  = v_norm( v_add( v_add($v1,$v2), $v3 ) );

    # Build local tangent basis at c: North then East
    # North = projection of +Z onto tangent plane at c (fallback if near pole)
    my $Z  = [0,0,1];
    my $north = v_add($Z, v_scale($c, -v_dot($Z,$c)));   # remove component along c
    my $nlen  = sqrt(v_dot($north,$north));
    if ($nlen < 1e-12) {  # too close to pole; use +Y as reference
        my $Y = [0,1,0];
        $north = v_add($Y, v_scale($c, -v_dot($Y,$c)));
    }
    $north = v_norm($north);
    my $east  = v_norm( v_cross($c, $north) );           # right-handed: east

    # Project stars into local EN plane: x=East, y=North
    my @xy = map {
        my $x = v_dot($_, $east);
        my $y = v_dot($_, $north);
        [$x,$y]
    } ($v1,$v2,$v3);

    # Signed area (2D cross) of triangle A->B->C in EN plane
    my ($x1,$y1)=@{$xy[0]}; my ($x2,$y2)=@{$xy[1]}; my ($x3,$y3)=@{$xy[2]};
    my $z = ($x2-$x1)*($y3-$y1) - ($y2-$y1)*($x3-$x1);

    return ($z >= 0) ? +1 : -1;  # +1 = CCW, -1 = CW in East-right, North-up
}

# ---- Example usage (values are placeholders) ----
# my $sign = orientation_enu($raA_u,$deA_u, $raB_u,$deB_u, $raC_u,$deC_u);
# print $sign > 0 ? "CCW\n" : "CW\n";

$| = 1;
print "reading\n";
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

print "angling\n";
for (my $i = 0; $i <= $#stars; $i++) {
   my ($ra1, $de1, $bright1) = split /,/, $stars{$stars[$i]};
   for (my $j = $i + 1; $j <= $#stars; $j++) {
      my ($ra2, $de2, $bright2) = split /,/, $stars{$stars[$j]};

      my $sep = angsep_microdeg($ra1, $de1, $ra2, $de2);

      if ($sep > 9 && $sep <= 90_000_000) {
         #print "$sep,$stars[$i],$stars[$j]\n";
         $angles{"$i,$j"} = $sep;
         $angles{"$j,$i"} = $sep;
      }
   }
}

print "tabling\n";
for (my $i = 0; $i <= $#stars; $i++) {
   my ($rai, $dei) = split /,/,$stars{$stars[$i]};
   for (my $j = $i+1; $j <= $#stars; $j++) {
      if (!defined($angles{"$i,$j"})) {
         next;
      }
      my ($raj, $dej) = split /,/,$stars{$stars[$j]};
      for (my $k = $j+1; $k <= $#stars; $k++) {
         if (!defined($angles{"$i,$k"})) {
            next;
         }
         if (!defined($angles{"$j,$k"})) {
            next;
         }
         my ($rak, $dek) = split /,/,$stars{$stars[$k]};

         my $orientation = orientation_enu($rai,$dei,$raj,$dej,$rak,$dek);

         # three angles exist...
         my $aij = $angles{"$i,$j"};
         my $ajk = $angles{"$j,$k"};
         my $aki = $angles{"$k,$i"};

         my $biggest = $aij;
         if ($ajk > $biggest) { $biggest = $ajk; }
         if ($aki > $biggest) { $biggest = $aki; }

         $aij /= $biggest;
         $ajk /= $biggest;
         $aki /= $biggest;

         my @names;
         my @lengths;

         if ($orientation == 1) {
            @names = ($stars[$i], $stars[$j], $stars[$k]);
            @lengths = ($aij, $ajk, $aki);
         }
         else {
            @names = ($stars[$i], $stars[$k], $stars[$j]);
            @lengths = ($aki, $ajk, $aij);
         }

         while ($lengths[2] != 1.0) {
            my $tmp;
            $tmp = shift @names;
            push @names, $tmp;
            $tmp = shift @lengths;
            push @lengths, $tmp;
         }

         my $p1 = int($lengths[0] * 255);
         my $p2 = int($lengths[1] * 255);
         open FILE, ">>table/$hex{$p1}/$hex{$p2}";
         print FILE "$lengths[0],$lengths[1],$names[0],$names[1],$names[2]\n";
         close FILE;
      }
   }
}
