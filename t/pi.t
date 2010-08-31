use Math::MPFI qw(:mpfi);
use Math::MPFR qw(:mpfr);
use warnings;
use strict;

print "1..1\n";

Rmpfr_set_default_prec(60);

my $fr_pi = Math::MPFR->new();

Rmpfr_const_pi($fr_pi, GMP_RNDN);
my $d = Rmpfr_get_d($fr_pi, GMP_RNDN);

Rmpfi_set_default_prec(50);

my $op = Math::MPFI->new();

Rmpfi_const_pi($op);

if($op == $d) {print "ok 1\n"}
else {
  warn "\$op: $op\n\$d: $d\n";
  print "not ok 1\n";
}
