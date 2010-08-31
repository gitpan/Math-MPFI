use warnings;
use strict;
use Math::MPFR qw(:mpfr);
use Math::MPFI qw(:mpfi);

print "1..4\n";

print STDERR "\n# Using Math::MPFI version ", $Math::MPFI::VERSION, "\n";
#print STDERR "# Using mpfi library version ", MPFI_VERSION_STRING, "\n";
print STDERR "# Math::MPFR uses mpfr library version ", MPFR_VERSION_STRING, "\n";
print STDERR "# Math::MPFI uses mpfr library version ", Math::MPFI::mpfr_v(), "\n";
print STDERR "# Math::MPFR uses gmp library version ", Math::MPFR::gmp_v(), "\n";
print STDERR "# Math::MPFI uses gmp library version ", Math::MPFI::gmp_v(), "\n";
print STDERR "# Using gmp library version ", Math::MPFI::gmp_v(), "\n";

if($Math::MPFI::VERSION eq '0.01') {print "ok 1\n"}
else {print "not ok 1 $Math::MPFI::VERSION\n"}

my $prec = 101;

Rmpfi_set_default_prec($prec);

if(Rmpfr_get_default_prec() == $prec && Rmpfi_get_default_prec() == $prec) {print "ok 2\n"}
else {
  warn "Rmpfr_get default_prec == ", Rmpfr_get_default_prec(),
       "\nRmpfi_get default_prec == ", Rmpfi_get_default_prec(), "\n";
  print "not ok 2\n";
}

my $fi = Rmpfi_init();

if(Rmpfi_get_prec($fi) == $prec) {print "ok 3\n"}
else {
  warn "Rmpfi_get_prec(\$fi) == ", Rmpfi_get_prec($fi), "\n";
  print "not ok 3 \n";
} 

if(Rmpfi_get_version() < 1.5) {
  warn Rmpfi_get_version(), "\n";
  print "not ok 4\n";
}
else {print "ok 4\n"}
