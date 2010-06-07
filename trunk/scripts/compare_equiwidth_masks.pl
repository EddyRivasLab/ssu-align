#!/usr/bin/perl
#
# compare_equiwidth_masks.pl
# Eric Nawrocki
# EPN, Fri Sep 26 08:55:44 2008
#
# Usage: perl compare_equiwidth_masks.pl
#             <mask 1 (1s, 0s, single line, no spaces) of length <x> with <y> 1s>
#             <mask 2 (1s, 0s, single line, no spaces) of length <x> with <z> 1s>
#             
# Synopsis:
# Compare 2 identically lengthed masks. Output intersection masks in three possible 
# widths.
#
# Options from :
#    -X <f>         : save intersection mask of 1 and 2 of width <x> file <f>
#    -Y <f>         : save intersection mask of 1 and 2 of width <y> file <f>
#    -Z <f>         : save intersection mask of 1 and 2 of width <z> file <f>
use Getopt::Std;

getopts('X:Y:Z:');
$do_x_intersection = 0;
$do_y_intersection = 0;
$do_z_intersection = 0;
if (defined $opt_X) { $do_x_intersection = 1; $x_intersection_file = $opt_X; }
if (defined $opt_Y) { $do_y_intersection = 1; $y_intersection_file = $opt_Y; }
if (defined $opt_Z) { $do_z_intersection = 1; $z_intersection_file = $opt_Z; }

$usage = "Usage: perl compare_equiwidth_masks.pl [-options]\n\t<mask 1 (1s, 0s, single line, no spaces) of length <x> with <y> 1s>\n\t<mask 2 (1s, 0s, single line, no spaces) of length <x> with <z> 1s>\n\n";
$options_usage  = "Options:\n\t";
$options_usage .= "-X <f> : save intersection mask of 1 and 2 of width <x> to file <f>\n\t";
$options_usage .= "-Y <f> : save intersection mask of 1 and 2 of width <y> to file <f>\n\t";
$options_usage .= "-Z <f> : save intersection mask of 1 and 2 of width <z> to file <f>\n\n";

if(@ARGV != 2)
{
    print $usage;
    print $options_usage;
    exit();
}

($lm1_file, $lm2_file) = @ARGV;

open(IN,  $lm1_file);
$lm1 = <IN>;
chomp $lm1;
@lm1_A = split("", $lm1);
close(IN);

open(IN,  $lm2_file);
$lm2 = <IN>;
chomp $lm2;
@lm2_A = split("", $lm2);
close(IN);

if(scalar(@lm1_A) != scalar(@lm2_A)) { printf("ERROR, mask 1 $lm1_file is (length %d) != length of mask 2 (%d)\n", scalar(@lm1_A), scalar(@lm2_A)); exit(1); }
$lm_len = scalar(@lm1_A);

$new_x_lm = ""; #only printed if -X option enabled
$new_y_lm = ""; #only printed if -Y option enabled
$new_z_lm = ""; #only printed if -Z option enabled
for($i = 0; $i < scalar(@lm1_A); $i++) {
    $combo = $lm1_A[$i] . $lm2_A[$i];
    if($combo eq "11") { 
	$overlap++;
	$new_x_lm .= '1';
	$new_y_lm .= '1';
	$new_z_lm .= '1';
	$lm1_1s++;
	$lm2_1s++;
    }
    elsif($combo eq "10") { 
	$new_x_lm .= '0';
	$new_y_lm .= '0';
	$lm1_1s++;
    }
    elsif($combo eq "01") { 
	$new_x_lm .= '0';
	$new_z_lm .= '0';
	$lm2_1s++;
    }
    elsif($combo eq "00") { 
	$new_x_lm .= '0';
    }
}
# make sure we only had 1s and 0s
$lm1 =~ s/1//g;
$lm2 =~ s/1//g;
$lm1 =~ s/0//g;
$lm2 =~ s/0//g;
if($lm1 ne "") { printf("ERROR, mask 1 has non-1/0 chars: $lm1\n"); exit(1); }
if($lm2 ne "") { printf("ERROR, mask 1 has non-1/0 chars: $lm2\n"); exit(1); }

printf("Mask length                    %4d\n", $lm_len);
printf("Mask 1                         %4d 1s\t%4d 0s\n", $lm1_1s, ($lm_len - $lm1_1s));
printf("Mask 2                         %4d 1s\t%4d 0s\n", $lm2_1s, ($lm_len - $lm2_1s));
printf("Overlap of 1s                  %4d\n", $overlap);
printf("Overlap of 1s fraction total   %.4f\n", ($overlap/$lm_len));
printf("Overlap of 1s fraction mask 1  %.4f\n", ($overlap/$lm1_1s));
printf("Overlap of 1s fraction mask 2  %.4f\n", ($overlap/$lm2_1s));

if($do_x_intersection || $do_y_intersection || $do_z_intersection) { printf("\n"); }
if($do_x_intersection) 
{
    open(OUT, ">" . $x_intersection_file);
    print OUT $new_x_lm . "\n";
    close(OUT);
    printf("%-30s: new mask of %5d columns, %5d 1s, %5d 0s\n", $x_intersection_file, $lm_len, $overlap, $lm_len-$overlap);
}

if($do_y_intersection) 
{
    open(OUT, ">" . $y_intersection_file);
    print OUT $new_y_lm . "\n";
    close(OUT);
    printf("%-30s: new mask of %5d columns, %5d 1s, %5d 0s\n", $y_intersection_file, $lm1_1s, $overlap, $lm1_1s-$overlap);
}

if($do_z_intersection) 
{
    open(OUT, ">" . $z_intersection_file);
    print OUT $new_z_lm . "\n";
    close(OUT);
    printf("%-30s: new mask of %5d columns, %5d 1s, %5d 0s\n", $z_intersection_file, $lm2_1s, $overlap, $lm2_1s-$overlap);
}

