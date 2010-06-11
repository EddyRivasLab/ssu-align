#! /usr/bin/perl
#
# SSU-ALIGN's test suite: a simple PERL script
# that executes the itest scripts and prints
# an error if any of them fail.
#
# EPN, Mon Apr 26 10:17:43 2010
#
###################################
# Test scripts for each main script
###################################

@cmdA = ("perl ssu-align-merge-prep.itest.pl ../src/ data/ foo",
	 "perl            ssu-build.itest.pl ../src/ data/ foo",
	 "perl             ssu-draw.itest.pl ../src/ data/ foo",
	 "perl             ssu-mask.itest.pl ../src/ data/ foo");
@nameA = ("ssu-align, ssu-merge, and ssu-prep",
	  "ssu-build", 
	  "ssu-draw", 
	  "ssu-mask");

$ntest = scalar(@cmdA);

$nfailed = 0;
printf("===============================================================================\n");
printf("Running SSU-ALIGN test suite ...\n", ($i+1), $cmdA[$i]);
for($i = 0; $i < $ntest; $i++) { 
    printf("===============================================================================\n");
    printf("Running test script %d with command:\n\t%s\n\n", ($i+1), $cmdA[$i]);
    system("$cmdA[$i]");
    if($? == 0) { printf("\n\nSuccess!: all tests for %s passed.\n\n", $nameA[$i]);          }
    else        { printf("\n\nFailure!: at least one test for %s failed.\n\n", $nameA[$i]);  $nfailed++; }
}

printf("===============================================================================\n");
if ($nfailed > 0) { print "\n$nfailed of $ntest test scripts FAILED.\n"; }
else              { print "\nAll $ntest test scripts passed.\n"; }

# Print info on system, date, etc.
#
print "\n\nSystem information:\n";
print `date`;
print `uname -a`;

