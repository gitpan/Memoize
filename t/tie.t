#!/usr/bin/perl

use lib qw(. ..);
use Memoize 0.52 qw(memoize unmemoize);
use Fcntl;
use Memoize::AnyDBM_File;

print "1..4\n";

sub i {
  $_[0];
}

$ARG = 'Keith Bostic is a pinhead';

sub c119 { 119 }
sub c7 { 7 }
sub c43 { 43 }
sub c23 { 23 }
sub c5 { 5 }

sub n {
  $_[0]+1;
}

$tmpdir = $ENV{TMP} || $ENV{TMPDIR} ||  '/tmp';  
if (eval {require File::Spec::Functions}) {
 File::Spec::Functions->import();
} else {
  *catfile = sub { join '/', @_ };
}
$file = catfile($tmpdir, "md$$");
@files = ($file, "$file.db", "$file.dir", "$file.pag");
{ 
  my @present = grep -e, @files;
  if (@present && (@failed = grep { not unlink } @present)) {
    warn "Can't unlink @failed!  ($!)";
  }
}


tryout('Memoize::AnyDBM_File', $file, 1);  # Test 1..4
# tryout('DB_File', $file, 1);  # Test 1..4
unlink $file, "$file.dir", "$file.pag";

sub tryout {
  my ($tiepack, $file, $testno) = @_;


  memoize 'c5', 
  SCALAR_CACHE => ['TIE', $tiepack, $file, O_RDWR | O_CREAT, 0666], 
  LIST_CACHE => 'FAULT'
    ;

  my $t1 = c5($ARG);	
  my $t2 = c5($ARG);	
  print (($t1 == 5) ? "ok $testno\n" : "not ok $testno\n");
  $testno++;
  print (($t2 == 5) ? "ok $testno\n" : "not ok $testno\n");
  unmemoize 'c5';
  
  # Now something tricky---we'll memoize c23 with the wrong table that
  # has the 5 already cached.
  memoize 'c23', 
  SCALAR_CACHE => ['TIE', $tiepack, $file, O_RDWR, 0666], 
  LIST_CACHE => 'FAULT'
    ;
  
  my $t3 = c23($ARG);
  my $t4 = c23($ARG);
  $testno++;
  print (($t3 == 5) ? "ok $testno\n" : "not ok $testno  #   Result $t3\n");
  $testno++;
  print (($t4 == 5) ? "ok $testno\n" : "not ok $testno  #   Result $t4\n");
  unmemoize 'c23';
}

{ 
  my @present = grep -e, @files;
  if (@present && (@failed = grep { not unlink } @present)) {
    warn "Can't unlink @failed!  ($!)";
  }
}