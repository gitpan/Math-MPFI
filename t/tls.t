use warnings;
use strict;
use Math::MPFI qw(:mpfi);

my $cut = eval 'use threads; 1';

print "1..1\n";

print  "# Using Math::MPFI version ", $Math::MPFI::VERSION, "\n";
print  "# Using mpfr library version ", MPFR_VERSION_STRING, "\n";
print  "# Using gmp library version ", Math::MPFI::gmp_v(), "\n";

my ($tls, $ok, $pid);
eval {$tls =  Math::MPFI::Rmpfr_buildopt_tls_p();};

my $cut_mess = $cut ? '' : "ithreads not available with this build of perl\n";
my $tls_mess = $tls ? '' :
                           $@ ? "Unable to determine whether mpfr was built with '--enable-thread-safe'\n"
                              : "Your mpfr library was not built with '--enable-thread-safe'\n";

if($cut && $tls) {   # perform tests

  Rmpfi_set_default_prec(101);
  my $thr1 = threads->create(
                      sub {
                          Rmpfi_set_default_prec(201);
                          return Rmpfi_get_default_prec();
                          } );
  my $res = $thr1->join();

  if($res == 201 && Rmpfi_get_default_prec() == 101) {$ok .= 'a'}
  else {warn "\n1a: \$res: $res\n    prec: ", Rmpfi_get_default_prec(), "\n"}

  # Needs TLS to work correctly on MS Windows
  if($pid = fork()) {
    Rmpfi_set_default_prec(102);
    waitpid($pid,0);
  } else {
    sleep 1;
    Rmpfi_set_default_prec(202);
    _save(Rmpfi_get_default_prec());
    exit(0);
  }

  sleep 2;

  if(Rmpfi_get_default_prec() == 102) {$ok .= 'b'}
  else {warn "\n1b: prec: ", Rmpfi_get_default_prec(), "\n"}

  my $f = _retrieve();

  if($f == 999999) {
    warn "Skipping test 1c - couldn't open 'save_child_setting.txt'";
    $ok .= 'c';
  }
  elsif($f == 202) {
    $ok .= 'c';
  }
  else {
    warn "\n1c: prec: $f\n";
  }

  if($ok eq 'abc') {print "ok 1\n"}
  else {
    warn "\$ok: $ok\n";
    print "not ok 1\n";
  }

}
else {
  warn "Skipping all tests: ${cut_mess}${tls_mess}";
  print "ok 1\n";
} 


sub _save {
    unless (open(WR, '>', 'save_child_setting.txt')) {
      warn "Can't open file 'save_child_setting.txt' for writing : $!";
      return 0;
    }
    print WR $_[0];
    return 1;
}

sub _retrieve {
    unless (open (RD, '<', 'save_child_setting.txt')) {
      warn "Can't open file 'save_child_setting.txt' for reading: $!";
      return 999999;
    }
    my @ret;
    my $ret = <RD>;
    chomp $ret;
    if($ret =~ / /) {
      @ret = split / /, $ret;
      return @ret;
    } 
    return $ret;
}

