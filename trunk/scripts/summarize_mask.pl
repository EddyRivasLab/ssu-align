#!/usr/bin/perl
#
# summarize_mask.pl
# Eric Nawrocki
# EPN, Wed Sep 24 15:59:40 2008
#
# Usage: perl summarize_mask.pl
#             <mask file (1s, 0s, single line, no spaces)>
#             
# Synopsis:
# Determine number of 1's <x> and columns <y> of mask, and
# and print that info to the screen.
# Options from :
#    -L          : the mask file is a list of mask files
#    -I          : list each column that is a '1' on separate line
#    -O          : list each column that is a '0' on separate line
use Getopt::Std;

getopts('LOI');
$do_list = 0;
$list_1s = 0;
$list_0s = 0;
if (defined $opt_L) { $do_list = 1; }
if (defined $opt_I) { $list_1s = 1; }
if (defined $opt_O) { $list_0s = 1; }

$usage = "Usage: perl summarize_mask.pl [-options]\n\t<mask file (1s, 0s, single line, no spaces)>\n\n";
$options_usage  = "Options:\n\t";
$options_usage .= "-L : the mask file is actually a list of mask files\n\t";
$options_usage .= "-I : list each column that is a '1' on a separate line\n\t";
$options_usage .= "-O : list each column that is a '0' on a separate line\n\n";


if(@ARGV != 1)
{
    print $usage;
    print $options_usage;
    exit();
}

($input_lm_file) = @ARGV;

@fileA = ();
if($do_list) { 
    open(IN,  $input_lm_file);
    while($line = <IN>) { 
	chomp $line;
	if($line =~ m/\w+/) { push(@fileA, $line); }
    }
    close(IN);
}
else { $fileA[0] = $input_lm_file; }


foreach $lm_file (@fileA) { 
    $lm_1s = 0;
    if(! -e "$lm_file") { printf("ERROR, $lm_file does not exist!\n"); next; }
    open(IN,  $lm_file);
    $lm = <IN>;
    chomp $lm;
    @lm_A = split("", $lm);
    close(IN);

    if($list_1s || $list_0s) { 
	printf("$lm_file:\n");
    }
    $lm_len = scalar(@lm_A);
    
    for($i = 0; $i < scalar(@lm_A); $i++) {
	if($lm_A[$i] == 1) { 
	    $lm_1s++; 
	    if($list_1s) { printf("%5d: 1\n", ($i+1)); }
	}
	else { 
	    if($list_0s) { printf("%5d: 0\n", ($i+1)); }
	}
    }

    $i = 0;
    $nfive = 0;
    while(($lm_A[$i] == 0) && ($i < scalar(@lm_A))) { $nfive++; $i++; }

    $i = scalar(@lm_A)-1;
    $nthree = 0;
    while(($lm_A[$i] == 0) && ($i >= 0)) { $nthree++; $i--; }

# make sure we only had 1s and 0s
    $lm =~ s/1//g;
    $lm =~ s/0//g;
    if($lm ne "") { printf("ERROR, mask has non-1/0 chars: $lm\n"); exit(1); }

    printf("%-40s  %6s columns %6s 1s %6s 0s %6s 5' 0s %6s 3' 0s\n", $lm_file, $lm_len, $lm_1s, ($lm_len - $lm_1s), $nfive, $nthree);
}


