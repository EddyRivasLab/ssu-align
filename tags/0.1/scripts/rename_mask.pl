#!/usr/bin/perl
#
# rename_mask.pl
# Eric Nawrocki
# EPN, Wed Sep 24 15:59:40 2008
#
# Usage: perl rename_mask.pl
#             <mask (1s, 0s, single line, no spaces)>
#             
# Synopsis:
# Determine number of 1's <x> and columns <y> of mask, and
# rename it to "<x>-1s.<y>c.mask" if and only if that file
# doesn't already exist.
# Options from :
#    -L          : the mask file is a list of mask files
#    -P <x>      : use <x> as a prefix for the name
#    -F          : append the number of 5' 0s (0s before the first 1) as suffix
#    -T          : append the number of 3' 0s (0s after  the final 1) as suffix
use Getopt::Std;

getopts('LP:FT');
$do_list = 0;
$do_five = 0;
$do_three = 0;
$prefix = "";
if (defined $opt_L) { $do_list = 1; }
if (defined $opt_P) { $prefix = $opt_P; };
if (defined $opt_F) { $do_five = 1; }
if (defined $opt_T) { $do_three = 1; }

$usage = "Usage: perl rename_mask.pl [-options]\n\t<mask (1s, 0s, single line, no spaces) with <x> 1s of length <y>>\n\n\tFile will be copied to a new file named \"<x>-1s.<y>c.mask\n\n";
$options_usage  = "Options:\n\t";
$options_usage .= "-L     : the mask file is actually a list of mask files\n\t";
$options_usage .= "-P <x> : use <x> as a prefix for the name\n\t";
$options_usage .= "-F     : append the number of 5' 0s (0s before the first 1) as suffix\n\t";
$options_usage .= "-T     : append the number of 3' 0s (0s after  the final 1) as suffix\n\n";

if(@ARGV != 1)
{
    print $usage;
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
    
    $lm_len = scalar(@lm_A);
    
    for($i = 0; $i < scalar(@lm_A); $i++) {
	if($lm_A[$i] == 1) { $lm_1s++; }
    }
    $i = 0;
    $nfive = 0;
    while(($lm_A[$i] == 0) && ($i < scalar(@lm_A))) { $nfive++; $i++ }
    $i = scalar(@lm_A)-1;
    $nthree = 0;
    while(($lm_A[$i] == 0) && ($i >= 0)) { $nthree++; $i-- }

# make sure we only had 1s and 0s
    $lm =~ s/1//g;
    $lm =~ s/0//g;
    if($lm ne "") { printf("ERROR, mask has non-1/0 chars: $lm\n"); exit(1); }
    
    $new_file = $prefix . $lm_1s . "-1s." . $lm_len . "c.";
    if($do_five)  { $new_file .= $nfive . "-5."; }
    if($do_three) { $new_file .= $nthree . "-3." }
    $new_file .= "mask";

    if(-e "$new_file") { printf("ERROR, a file named $new_file already exists!\n"); }
    else { 
	system("cp $lm_file $new_file"); 
	printf("Created new file $new_file: a copy of $lm_file.\n");
    }
}


