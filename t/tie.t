#!/usr/bin/perl

use lib qw(. ..);
use Memoize 0.45 qw(memoize unmemoize);
use Fcntl;
use Memoize::AnyDBM_File;

print "1..4\n";

sub i {
  $_[0];
}

sub c119 { 119 }
sub c7 { 7 }
sub c43 { 43 }
sub c23 { 23 }
sub c5 { 5 }

sub n {
  $_[0]+1;
}

$file = '/tmp/ms.db';
unlink $file, "$file.dir", "$file.pag";
tryout('Memoize::AnyDBM_File', $file, 1);  # Test 1..4
unlink $file, "$file.dir", "$file.pag";

sub tryout {
  my ($tiepack, $file, $testno) = @_;


  memoize 'c5', 
  SCALAR_CACHE => ['TIE', $tiepack, $file, O_RDWR | O_CREAT, 0666], 
  LIST_CACHE => 'FAULT'
    ;

  my $t1 = c5();	
  my $t2 = c5();	
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
  
  my $t3 = c23();
  my $t4 = c23();
  $testno++;
  print (($t3 == 5) ? "ok $testno\n" : "not ok $testno\n");
  $testno++;
  print (($t4 == 5) ? "ok $testno\n" : "not ok $testno\n");
  unmemoize 'c23';
}

