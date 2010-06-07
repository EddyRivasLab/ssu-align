#! /usr/bin/perl
#
# Integrated test number 1 of the SSU-ALIGN scripts, focusing on ssu-mask.
#
# Usage:     ./ssu-mask.itest.1.pl <directory with all 5 SSU-ALIGN scripts> <data directory with fasta files etc.> <tmpfile and tmpdir prefix> <test number to perform, if blank do all tests>
# Examples:  ./ssu-mask.itest.pl ../src/ data/ foo   (do all tests)
#            ./ssu-mask.itest.pl ../src/ data/ foo 4 (do only test 4)
#
# EPN, Fri Mar  5 08:33:29 2010

$usage = "perl ssu-mask.itest.pl\n\t<directory with all 5 SSU-ALIGN scripts>\n\t<data directory with fasta files etc.>\n\t<tmpfile and tmpdir prefix>\n\t<test number to perform, if blank, do all tests>\n";
$testnum = "";
if(scalar(@ARGV) == 3) { 
    ($scriptdir, $datadir, $dir) = @ARGV;
}
elsif(scalar(@ARGV) == 4) { 
    ($scriptdir, $datadir, $dir, $testnum) = @ARGV;
}
else { 
    printf("$usage\n");
    exit 0;
}

if(($dir eq ".") || ($dir eq "./")) { die "ERROR, the output temporary directory cannot be \."; }
if($dir eq "data") { die "ERROR, the output temporary directory cannot be \"data\""; }

$scriptdir =~ s/\/$//; # remove trailing "/" 
$datadir   =~ s/\/$//; # remove trailing "/" 

$ssualign = $scriptdir . "/ssu-align";
$ssubuild = $scriptdir . "/ssu-build";
$ssudraw  = $scriptdir . "/ssu-draw";
$ssumask  = $scriptdir . "/ssu-mask";
$ssumerge = $scriptdir . "/ssu-merge";
$ssu_itest_module = "ssu.itest.pm";

if (! -e "$ssualign") { die "FAIL: didn't find ssu-mask script $ssualign"; }
if (! -e "$ssubuild") { die "FAIL: didn't find ssu-build script $ssubuild"; }
if (! -e "$ssudraw")  { die "FAIL: didn't find ssu-draw script $ssudraw"; }
if (! -e "$ssumask")  { die "FAIL: didn't find ssu-mask script $ssumask"; }
if (! -e "$ssumerge") { die "FAIL: didn't find ssu-merge script $ssumerge"; }
if (! -x "$ssualign") { die "FAIL: ssu-mask script $ssualign is not executable"; }
if (! -x "$ssubuild") { die "FAIL: ssu-build script $ssubuild is not executable"; }
if (! -x "$ssudraw")  { die "FAIL: ssu-draw script $ssudraw is not executable"; }
if (! -x "$ssumask")  { die "FAIL: ssu-mask script $ssumask is not executable"; }
if (! -x "$ssumerge") { die "FAIL: ssu-merge script $ssumerge is not executable"; }
if (! -e "$ssu_itest_module") { die "FAIL: didn't find required Perl module $ssu_itest_module in current directory"; }

require $ssu_itest_module;

$fafile       = $datadir . "/seed-15.fa";
$trna_stkfile = $datadir . "/trna-5.stk";
$trna_fafile  = $datadir . "/trna-5.fa";
$trna_psfile  = $datadir . "/trna-ssdraw.ps";
@name_A =     ("archaea", "bacteria", "eukarya");
@arc_only_A = ("archaea");
@bac_only_A = ("bacteria");
@euk_only_A = ("eukarya");
$mask_key_in  = "181";
$mask_key_out = "1.8.1";

if (! -e "$fafile")       { die "FAIL: didn't find fasta file $fafile in data dir $datadir"; }
if (! -e "$trna_stkfile") { die "FAIL: didn't find file $trna_stkfile in data dir $datadir"; }
if (! -e "$trna_fafile")  { die "FAIL: didn't find file $trna_fafile in data dir $datadir"; }
if (! -e "$trna_psfile")  { die "FAIL: didn't find file $trna_psfile in data dir $datadir"; }
foreach $name (@name_A) {
    $maskfile = $datadir . "/" . $name . "." . $mask_key_in . ".mask";
    if (! -e "$maskfile") { die "FAIL: didn't find mask file $maskfile in data dir $datadir"; }
}
$testctr = 1;

# Do ssu-align call, required for all tests:
run_align($ssualign, $fafile, $dir, "-f", $testctr);
check_for_files($dir, $dir, $testctr, \@name_A, ".hitlist");
check_for_files($dir, $dir, $testctr, \@name_A, ".fa");
check_for_files($dir, $dir, $testctr, \@name_A, ".stk");
check_for_files($dir, $dir, $testctr, \@name_A, ".ifile");
check_for_files($dir, $dir, $testctr, \@name_A, ".cmalign");

#######################################
# Basic options (single letter options)
#######################################
# Test -h
if(($testnum eq "") || ($testnum == $testctr)) {
    run_mask($ssumask, "", "-h", $testctr);
    if ($? != 0) { die "FAIL: ssu-mask -h failed unexpectedly"; }
}
$testctr++;

# Test default (no options)
if(($testnum eq "") || ($testnum == $testctr)) {
    run_mask                  ($ssumask, $dir, "", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".mask");
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".mask.stk");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".mask.pdf", "mask.ps");
    $output = `cat $dir/$dir.ssu-mask.sum`;
    if($output !~ /$dir.bacteria.mask\s+output\s+mask\s+1582\s+1499\s+83/)      { die "ERROR, problem with masking"; }
    if($output !~ /$dir.bacteria.mask.p\w+\s+output\s+p\w+\s+1582\s+1499\s+83/) { die "ERROR, problem with creating mask diagram"; }
    remove_files              ($dir, "mask");

    # the only test where we do an ssu-draw call (ssu-draw is extensively tested by ssu-draw.itest.pl)
    run_draw                  ($ssudraw, $dir, "", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".drawtab");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".pdf", ".ps");
    remove_files              ($dir, "draw");
    remove_files              ($dir, "\.ps");
    remove_files              ($dir, "\.pdf");
}
$testctr++;

# Test -a (on $dir.archaea.stk in $dir/)
if(($testnum eq "") || ($testnum == $testctr)) {
    run_mask                  ($ssumask, $dir . "/" . $dir . ".bacteria.stk", "-a", $testctr);
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".mask");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".mask.stk");
    check_for_one_of_two_files(".", $dir, $testctr, \@bac_only_A, ".mask.pdf", "mask.ps");
    $output = `cat $dir.bacteria.ssu-mask.sum`;
    if($output !~ /$dir.bacteria.mask\s+output\s+mask\s+1582\s+1499\s+83/)      { die "ERROR, problem with masking"; }
    if($output !~ /$dir.bacteria.mask.p\w+\s+output\s+p\w+\s+1582\s+1499\s+83/) { die "ERROR, problem with creating mask diagram"; }
    remove_files              (".", "bacteria.mask");
    remove_files              (".", "bacteria.ssu-mask");
}
$testctr++;

# Test -a (on $dir.archaea.stk in cwd/)
if(($testnum eq "") || ($testnum == $testctr)) {
    system("cp " . $dir . "/" . $dir . ".bacteria.stk $dir.bacteria.stk");
    run_mask                  ($ssumask, $dir . ".bacteria.stk", "-a", $testctr);
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".mask");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".mask.stk");
    check_for_one_of_two_files(".", $dir, $testctr, \@bac_only_A, ".mask.pdf", "mask.ps");
    $output = `cat $dir.bacteria.ssu-mask.sum`;
    if($output !~ /$dir.bacteria.mask\s+output\s+mask\s+1582\s+1499\s+83/)      { die "ERROR, problem with masking"; }
    if($output !~ /$dir.bacteria.mask.p\w+\s+output\s+p\w+\s+1582\s+1499\s+83/) { die "ERROR, problem with creating mask diagram"; }
    remove_files              (".", "$dir.bacteria.mask");
    remove_files              (".", "$dir.bacteria.ssu-mask");
    remove_files              (".", "$dir.bacteria.stk");
}
$testctr++;

# Test -d
if(($testnum eq "") || ($testnum == $testctr)) {
    # without -a
    run_mask                  ($ssumask, $dir, "-d", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".mask.stk");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".mask.pdf", ".mask.ps");
    $output = `cat $dir/$dir.ssu-mask.sum`;
    if($output !~ /\.mask\s+input/)                              { die "ERROR, problem with masking"; }
    if($output !~ /$dir.archaea.mask.stk+\s+output\s+aln+\s+1376\s+\-\s+\-/)     { die "ERROR, problem with creating mask diagram"; }
    if($output !~ /$dir.bacteria.mask.stk+\s+output\s+aln+\s+1376\s+\-\s+\-/)    { die "ERROR, problem with creating mask diagram"; }
    if($output !~ /$dir.eukarya.mask.stk+\s+output\s+aln+\s+1343\s+\-\s+\-/)     { die "ERROR, problem with creating mask diagram"; }
    remove_files              ($dir, "mask");

    # with -a
    run_mask                  ($ssumask, $dir . "/" . $dir . ".eukarya.stk", "-d -a", $testctr);
    check_for_files           (".", $dir, $testctr, \@euk_only_A, ".mask.stk");
    check_for_one_of_two_files(".", $dir, $testctr, \@euk_only_A, ".mask.pdf", "mask.ps");
    $output = `cat $dir.eukarya.ssu-mask.sum`;
    if($output !~ /\.mask\s+input/)                              { die "ERROR, problem with masking"; }
    if($output !~ /$dir.eukarya.mask.stk\s+output\s+aln\s+1343/) { die "ERROR, problem with masking"; }
    remove_files              (".", "eukarya.mask");
    remove_files              (".", "eukarya.ssu-mask");
}
$testctr++;

# Test -s (only works in combination with -a)
if(($testnum eq "") || ($testnum == $testctr)) {
    # first make the required input mask with the maskkey 
    foreach $name (@arc_only_A) {
	$maskfile        = $datadir . "/" . $name . "." . $mask_key_in . ".mask";
	$maskfile_wo_dir = $name . "." . $mask_key_in . ".mask";
    }
    run_mask                  ($ssumask, $dir . "/" . $dir . ".archaea.stk", "-s $maskfile -a", $testctr);
    check_for_files           (".", $dir, $testctr, \@arc_only_A, ".mask.stk");
    check_for_one_of_two_files(".", $dir, $testctr, \@arc_only_A, ".mask.pdf", "mask.ps");
    $output = `cat $dir.archaea.ssu-mask.sum`;
    if($output !~ /$dir.archaea.mask.stk\s+output\s+aln\s+794/)  { die "ERROR, problem with masking"; }
    if($output !~ /$maskfile_wo_dir\s+input/)                    { die "ERROR, problem with masking"; }
    remove_files              (".", "archaea.mask");
    remove_files              (".", "archaea.ssu-mask");
}
$testctr++;

# Test -k $mask_key_in
if(($testnum eq "") || ($testnum == $testctr)) {
    # first make the required input masks with the maskkey 
    foreach $name (@name_A) {
	$maskfile     = $datadir . "/" . $name . "." . $mask_key_in . ".mask";
	$newmaskfile  = $dir .     "/" . $name . "." . $mask_key_in . ".mask";
	system("cp $maskfile $newmaskfile");
	if ($? != 0) { die "FAIL: cp command failed unexpectedly";}
    }
    # without -a 
    run_mask                  ($ssumask, $dir, "-k $mask_key_in", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".mask.stk");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".mask.pdf", ".mask.ps");
    $output = `cat $dir/$dir.ssu-mask.sum`;
    if($output !~ /$dir.eukarya.mask.stk\s+output\s+aln/)        { die "ERROR, problem with masking"; }
    if($output !~ /eukarya.$mask_key_in.mask\s+input/)           { die "ERROR, problem with masking"; }
    if($output !~ /$dir.eukarya.mask.stk\s+output\s+aln\s+1341/) { die "ERROR, problem with masking"; }
    remove_files              ($dir, "mask");

    # with -a, need to put mask files in cwd first
    foreach $name (@name_A) {
	$maskfile     = $datadir . "/" . $name . "." . $mask_key_in . ".mask";
	$newmaskfile  = $name . "." . $mask_key_in . ".mask";
	system("cp $maskfile $newmaskfile");
	if ($? != 0) { die "FAIL: cp command failed unexpectedly";}
    }
    run_mask                  ($ssumask, $dir . "/" . $dir . ".eukarya.stk", "-k $mask_key_in -a", $testctr);
    check_for_files           (".", $dir, $testctr, \@euk_only_A, ".mask.stk");
    check_for_one_of_two_files(".", $dir, $testctr, \@euk_only_A, ".mask.pdf", "mask.ps");
    $output = `cat $dir.eukarya.ssu-mask.sum`;
    if($output !~ /$dir.eukarya.mask.stk\s+output\s+aln/)        { die "ERROR, problem with masking"; }
    if($output !~ /eukarya.$mask_key_in.mask\s+input/)           { die "ERROR, problem with masking"; }
    if($output !~ /$dir.eukarya.mask.stk\s+output\s+aln\s+1341/) { die "ERROR, problem with masking"; }
    remove_files              (".", "eukarya.mask");
    remove_files              (".", "eukarya.ssu-mask");
    foreach $name (@name_A) {
	$newmaskfile  = $name . "." . $mask_key_in . ".mask";
	remove_files(".", $newmaskfile);
    }

    # now test if mask files they're in the cwd, not in $dir (without -a):
    foreach $name (@name_A) {
	$maskfile     = $datadir . "/" . $name . "." . $mask_key_in . ".mask";
	$newmaskfile  = $name . "." . $mask_key_in . ".mask";
	system("cp $maskfile $newmaskfile");
	if ($? != 0) { die "FAIL: cp command failed unexpectedly";}
    }
    run_mask                  ($ssumask, $dir, "-k $mask_key_in", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".mask.stk");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".mask.pdf", ".mask.ps");
    $output = `cat $dir/$dir.ssu-mask.sum`;
    if($output !~ /$dir.eukarya.mask.stk\s+output\s+aln/)        { die "ERROR, problem with masking"; }
    if($output !~ /eukarya.$mask_key_in.mask\s+input/)           { die "ERROR, problem with masking"; }
    if($output !~ /$dir.eukarya.mask.stk\s+output\s+aln\s+1341/) { die "ERROR, problem with masking"; }
    remove_files              ($dir, "mask");
    foreach $name (@name_A) {
	$newmaskfile  = $name . "." . $mask_key_in . ".mask";
	remove_files(".", $newmaskfile);
    }
}
$testctr++;

# Test -i
if(($testnum eq "") || ($testnum == $testctr)) {
    #without -a 
    run_mask                  ($ssumask, $dir, "-i", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".mask");
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".mask.stk");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".mask.pdf", "mask.ps");
    $output = `cat $dir/$dir.ssu-mask.sum`;
    if($output !~ /$dir.bacteria.mask\s+output\s+mask\s+1582\s+1499\s+83/)      { die "ERROR, problem with masking"; }
    if($output !~ /$dir.bacteria.mask.p\w+\s+output\s+p\w+\s+1582\s+1499\s+83/) { die "ERROR, problem with creating mask diagram"; }
    remove_files              ($dir, "mask");

    # with -a
    run_mask                  ($ssumask, $dir . "/" . $dir . ".bacteria.stk", "-i -a", $testctr);
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".mask");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".mask.stk");
    check_for_one_of_two_files(".", $dir, $testctr, \@bac_only_A, ".mask.pdf", "mask.ps");
    $output = `cat $dir.bacteria.ssu-mask.sum`;
    if($output !~ /$dir.bacteria.mask\s+output\s+mask\s+1582\s+1499\s+83/)      { die "ERROR, problem with masking"; }
    if($output !~ /$dir.bacteria.mask.p\w+\s+output\s+p\w+\s+1582\s+1499\s+83/) { die "ERROR, problem with creating mask diagram"; }
    remove_files              (".", "bacteria.mask");
    remove_files              (".", "bacteria.ssu-mask");
}
$testctr++;

########################################
# Options controlling mask construction:
########################################

# Test --pf
if(($testnum eq "") || ($testnum == $testctr)) {
    # without -a
    run_mask                  ($ssumask, $dir, "--pf 0.75", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".mask");
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".mask.stk");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".mask.pdf", ".mask.ps");
    $output = `cat $dir/$dir.ssu-mask.sum`;
    if($output !~ /$dir.bacteria.mask\s+output\s+mask\s+1582\s+1543\s+39/) { die "ERROR, problem with masking"; }
    remove_files              ($dir, "mask");

    #with -a
    run_mask                  ($ssumask, $dir . "/" . $dir . ".bacteria.stk", "--pf 0.75 -a", $testctr);
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".mask");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".mask.stk");
    check_for_one_of_two_files(".", $dir, $testctr, \@bac_only_A, ".mask.pdf", "mask.ps");
    $output = `cat $dir.bacteria.ssu-mask.sum`;
    if($output !~ /$dir.bacteria.mask\s+output\s+mask\s+1582\s+1543\s+39/) { die "ERROR, problem with masking"; }
    remove_files              (".", "bacteria.mask");
    remove_files              (".", "bacteria.ssu-mask");
}
$testctr++;

# Test --pt
if(($testnum eq "") || ($testnum == $testctr)) {
    run_mask                  ($ssumask, $dir, "--pt 0.5", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".mask");
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".mask.stk");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".mask.pdf", ".mask.ps");
    $output = `cat $dir/$dir.ssu-mask.sum`;
    if($output !~ /$dir.bacteria.mask\s+output\s+mask\s+1582\s+1570\s+12/) { die "ERROR, problem with masking"; }
    remove_files              ($dir, "mask");

    #with -a
    run_mask                  ($ssumask, $dir . "/" . $dir . ".bacteria.stk", "--pt 0.5 -a", $testctr);
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".mask");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".mask.stk");
    check_for_one_of_two_files(".", $dir, $testctr, \@bac_only_A, ".mask.pdf", "mask.ps");
    $output = `cat $dir.bacteria.ssu-mask.sum`;
    if($output !~ /$dir.bacteria.mask\s+output\s+mask\s+1582\s+1570\s+12/) { die "ERROR, problem with masking"; }
    remove_files              (".", "bacteria.mask");
    remove_files              (".", "bacteria.ssu-mask");
}
$testctr++;

# Test --pf and --pt
if(($testnum eq "") || ($testnum == $testctr)) {
    # without -a
    run_mask                  ($ssumask, $dir, "--pt 0.5 --pf 0.75", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".mask");
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".mask.stk");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".mask.pdf", ".mask.ps");
    $output = `cat $dir/$dir.ssu-mask.sum`;
    if($output !~ /$dir.bacteria.mask\s+output\s+mask\s+1582\s+1571\s+11/) { die "ERROR, problem with masking"; }
    remove_files              ($dir, "mask");

    # with -a
    run_mask                  ($ssumask, $dir . "/" . $dir . ".bacteria.stk", "--pt 0.5 --pf 0.75 -a", $testctr);
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".mask");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".mask.stk");
    check_for_one_of_two_files(".", $dir, $testctr, \@bac_only_A, ".mask.pdf", "mask.ps");
    $output = `cat $dir.bacteria.ssu-mask.sum`;
    if($output !~ /$dir.bacteria.mask\s+output\s+mask\s+1582\s+1571\s+11/) { die "ERROR, problem with masking"; }
    remove_files              (".", "bacteria.mask");
    remove_files              (".", "bacteria.ssu-mask");
}
$testctr++;

# Test --rfonly
if(($testnum eq "") || ($testnum == $testctr)) {
    # without -a
    run_mask                  ($ssumask, $dir, "--rfonly", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".mask");
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".mask.stk");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".mask.pdf", ".mask.ps");
    $output = `cat $dir/$dir.ssu-mask.sum`;
    if($output !~ /$dir.archaea.mask\s+output\s+mask\s+1508\s+1508\s+0/)  { die "ERROR, problem with masking"; }
    if($output !~ /$dir.bacteria.mask\s+output\s+mask\s+1582\s+1582\s+0/) { die "ERROR, problem with masking"; }
    if($output !~ /$dir.eukarya.mask\s+output\s+mask\s+1881\s+1881\s+0/)  { die "ERROR, problem with masking"; }
    remove_files              ($dir, "mask");

    #with -a
    run_mask                  ($ssumask, $dir . "/" . $dir . ".archaea.stk", "--rfonly -a ", $testctr);
    check_for_files           (".", $dir, $testctr, \@arc_only_A, ".mask");
    check_for_files           (".", $dir, $testctr, \@arc_only_A, ".mask.stk");
    check_for_one_of_two_files(".", $dir, $testctr, \@arc_only_A, ".mask.pdf", "mask.ps");
    $output = `cat $dir.archaea.ssu-mask.sum`;
    if($output !~ /$dir.archaea.mask\s+output\s+mask\s+1508\s+1508\s+0/)  { die "ERROR, problem with masking"; }
    if($output =~ /$dir.bacteria.mask\s+output\s+mask\s+1582\s+1582\s+0/) { die "ERROR, problem with masking"; }
    if($output =~ /$dir.eukarya.mask\s+output\s+mask\s+1881\s+1881\s+0/)  { die "ERROR, problem with masking"; }
    remove_files              (".", "archaea.mask");
    remove_files              (".", "archaea.ssu-mask");
}
$testctr++;

# Test --gapthresh 0.4
if(($testnum eq "") || ($testnum == $testctr)) {
    # without -a
    run_mask                  ($ssumask, $dir, "--gapthresh 0.4", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".mask");
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".pmask");
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".gmask");
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".mask.stk");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".mask.pdf", ".mask.ps");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".pmask.pdf", ".pmask.ps");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".gmask.pdf", ".gmask.ps");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".maskdiff.pdf", ".maskdiff.ps");
    $output = `cat $dir/$dir.ssu-mask.sum`;
    if($output !~ /$dir.archaea.mask\s+output\s+mask\s+1508\s+1435\s+73/)         { die "ERROR, problem with masking"; }
    if($output !~ /$dir.bacteria.pmask\s+output\s+mask\s+1582\s+1499\s+83/)       { die "ERROR, problem with masking"; }
    if($output !~ /$dir.bacteria.gmask\s+output\s+mask\s+1582\s+1525\s+57/)       { die "ERROR, problem with masking"; }
    if($output !~ /$dir.bacteria.mask.p\w+\s+output\s+p\w+\s+1582\s+1457\s+125/)  { die "ERROR, problem with creating mask diagram"; }
    if($output !~ /$dir.bacteria.maskdiff.p\w+\s+output\s+p\w+\s+1582\s+\-\s+\-/) { die "ERROR, problem with creating mask diagram"; }
    if($output !~ /$dir.bacteria.mask.stk+\s+output\s+aln+\s+1457\s+\-\s+\-/)     { die "ERROR, problem with creating mask diagram"; }
    remove_files              ($dir, "mask");

    #with -a
    run_mask                  ($ssumask, $dir . "/" . $dir . ".bacteria.stk", "--gapthresh 0.4 -a", $testctr);
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".mask");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".pmask");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".gmask");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".mask.stk");
    check_for_one_of_two_files(".", $dir, $testctr, \@bac_only_A, ".mask.pdf", ".mask.ps");
    check_for_one_of_two_files(".", $dir, $testctr, \@bac_only_A, ".pmask.pdf", ".pmask.ps");
    check_for_one_of_two_files(".", $dir, $testctr, \@bac_only_A, ".gmask.pdf", ".gmask.ps");
    check_for_one_of_two_files(".", $dir, $testctr, \@bac_only_A, ".maskdiff.pdf", ".maskdiff.ps");
    $output = `cat $dir.bacteria.ssu-mask.sum`;
    if($output !~ /$dir.bacteria.pmask\s+output\s+mask\s+1582\s+1499\s+83/)       { die "ERROR, problem with masking"; }
    if($output !~ /$dir.bacteria.gmask\s+output\s+mask\s+1582\s+1525\s+57/)       { die "ERROR, problem with masking"; }
    if($output !~ /$dir.bacteria.mask.p\w+\s+output\s+p\w+\s+1582\s+1457\s+125/)  { die "ERROR, problem with creating mask diagram"; }
    if($output !~ /$dir.bacteria.maskdiff.p\w+\s+output\s+p\w+\s+1582\s+\-\s+\-/) { die "ERROR, problem with creating mask diagram"; }
    if($output !~ /$dir.bacteria.mask.stk+\s+output\s+aln+\s+1457\s+\-\s+\-/)     { die "ERROR, problem with creating mask diagram"; }
    remove_files              (".", "bacteria.pmask");
    remove_files              (".", "bacteria.gmask");
    remove_files              (".", "bacteria.mask");
    remove_files              (".", "bacteria.ssu-mask");
}
$testctr++;

# Test --gaponly --gapthresh 0.4
if(($testnum eq "") || ($testnum == $testctr)) {
    # without -a
    run_mask                  ($ssumask, $dir, "--gaponly --gapthresh 0.4", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".mask");
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".mask.stk");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".mask.pdf", ".mask.ps");
    $output = `cat $dir/$dir.ssu-mask.sum`;
    if($output !~ /$dir.archaea.mask\s+output\s+mask\s+1508\s+1467\s+41/)        { die "ERROR, problem with masking"; }
    if($output !~ /$dir.bacteria.mask.p\w+\s+output\s+p\w+\s+1582\s+1525\s+57/)  { die "ERROR, problem with creating mask diagram"; }
    if($output !~ /$dir.bacteria.mask.stk+\s+output\s+aln+\s+1525\s+\-\s+\-/)    { die "ERROR, problem with creating mask diagram"; }
    remove_files              ($dir, "mask");

    # with -a
    run_mask                  ($ssumask, $dir . "/" . $dir . ".bacteria.stk", "--gaponly --gapthresh 0.4 -a", $testctr);
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".mask");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".mask.stk");
    check_for_one_of_two_files(".", $dir, $testctr, \@bac_only_A, ".mask.pdf", ".mask.ps");
    $output = `cat $dir.bacteria.ssu-mask.sum`;
    if($output =~ /$dir.archaea.mask\s+output\s+mask\s+1508\s+1467\s+41/)        { die "ERROR, problem with masking"; }
    if($output !~ /$dir.bacteria.mask.p\w+\s+output\s+p\w+\s+1582\s+1525\s+57/)  { die "ERROR, problem with creating mask diagram"; }
    if($output !~ /$dir.bacteria.mask.stk+\s+output\s+aln+\s+1525\s+\-\s+\-/)    { die "ERROR, problem with creating mask diagram"; }
    remove_files              (".", "bacteria.mask");
    remove_files              (".", "bacteria.ssu-mask");
}
$testctr++;

###############################
# Miscellaneous output options: 
###############################

# Test --afa
if(($testnum eq "") || ($testnum == $testctr)) {
    # without -a
    run_mask                  ($ssumask, $dir, "--afa", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".mask");
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".mask.afa");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".mask.pdf", ".mask.ps");
    $output = `cat $dir/$dir.ssu-mask.sum`;
    if($output !~ /$dir.eukarya.mask.afa\s+output\s+aln\s+1634/) { die "ERROR, problem with masking"; }
    if($output =~ /$dir.eukarya.mask.stk\s+output\s+aln\s+1634/) { die "ERROR, problem with masking"; }
    remove_files              ($dir, "mask");

    # with -a
    run_mask                  ($ssumask, $dir . "/" . $dir . ".eukarya.stk", "--afa -a", $testctr);
    check_for_files           (".", $dir, $testctr, \@euk_only_A, ".mask");
    check_for_files           (".", $dir, $testctr, \@euk_only_A, ".mask.afa");
    check_for_one_of_two_files(".", $dir, $testctr, \@euk_only_A, ".mask.pdf", ".mask.ps");
    $output = `cat $dir.eukarya.ssu-mask.sum`;
    if($output !~ /$dir.eukarya.mask.afa\s+output\s+aln\s+1634/) { die "ERROR, problem with masking"; }
    if($output =~ /$dir.eukarya.mask.stk\s+output\s+aln\s+1634/) { die "ERROR, problem with masking"; }
    remove_files              (".", "eukarya.mask");
    remove_files              (".", "eukarya.ssu-mask");
}
$testctr++;

# Test --dna
if(($testnum eq "") || ($testnum == $testctr)) {
    # without -a
    run_mask                  ($ssumask, $dir, "--dna", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".mask");
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".mask.stk");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".mask.pdf", ".mask.ps");
    $output = `cat $dir/$dir.ssu-mask.sum`;
    if($output !~ /$dir.eukarya.mask.stk\s+output\s+aln\s+1634/) { die "ERROR, problem with masking"; }
    remove_files              ($dir, "mask");

    # with -a
    run_mask                  ($ssumask, $dir . "/" . $dir . ".eukarya.stk", "--dna -a", $testctr);
    check_for_files           (".", $dir, $testctr, \@euk_only_A, ".mask");
    check_for_files           (".", $dir, $testctr, \@euk_only_A, ".mask.stk");
    check_for_one_of_two_files(".", $dir, $testctr, \@euk_only_A, ".mask.pdf", ".mask.ps");
    $output = `cat $dir.eukarya.ssu-mask.sum`;
    if($output !~ /$dir.eukarya.mask.stk\s+output\s+aln\s+1634/) { die "ERROR, problem with masking"; }
    remove_files              (".", "eukarya.mask");
    remove_files              (".", "eukarya.ssu-mask");
}
$testctr++;

# Test --key-out
if(($testnum eq "") || ($testnum == $testctr)) {
    # without -a
    run_mask                  ($ssumask, $dir, "--key-out $mask_key_out", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".$mask_key_out.mask");
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".$mask_key_out.mask.stk");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".$mask_key_out.mask.pdf", ".$mask_key_out.mask.ps");
    $output = `cat $dir/$dir.$mask_key_out.ssu-mask.sum`;
    if($output !~ /$dir.eukarya.$mask_key_out.mask.stk\s+output\s+aln\s+1634/) { die "ERROR, problem with masking"; }
    remove_files              ($dir, "mask");

    # with -a
    run_mask                  ($ssumask, $dir . "/" . $dir . ".eukarya.stk", "--key-out $mask_key_out -a", $testctr);
    check_for_files           (".", $dir, $testctr, \@euk_only_A, ".$mask_key_out.mask");
    check_for_files           (".", $dir, $testctr, \@euk_only_A, ".$mask_key_out.mask.stk");
    check_for_one_of_two_files(".", $dir, $testctr, \@euk_only_A, ".$mask_key_out.mask.pdf", ".$mask_key_out.mask.ps");
    $output = `cat $dir.eukarya.$mask_key_out.ssu-mask.sum`;
    if($output !~ /$dir.eukarya.$mask_key_out.mask.stk\s+output\s+aln\s+1634/) { die "ERROR, problem with masking"; }
    remove_files              (".", "eukarya." . $mask_key_out . ".mask");
    remove_files              (".", "eukarya." . $mask_key_out . ".ssu-mask");
}
$testctr++;

#####################################################################
# Options for creating secondary structure diagrams displaying masks:
#####################################################################
# NOTE: --ps2pdf is not tested, I don't think any test of it would be portable...

# Test --ps-only
if(($testnum eq "") || ($testnum == $testctr)) {
    #without -a
    run_mask                  ($ssumask, $dir, "--ps-only", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".mask");
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".mask.stk");
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".mask.ps");
    $output = `cat $dir/$dir.ssu-mask.sum`;
    if($output !~ /$dir.archaea.mask\s+output\s+mask\s+1508\s+1449\s+59/)      { die "ERROR, problem with masking"; }
    if($output !~ /$dir.bacteria.mask.ps\s+output\s+ps\s+1582\s+1499\s+83/)    { die "ERROR, problem with creating mask diagram"; }
    if($output =~ /$dir.bacteria.mask.pdf\s+output\s+pdf\s+1582\s+1499\s+83/)  { die "ERROR, problem with creating mask diagram"; }
    remove_files              ($dir, "mask");

    #with -a
    run_mask                  ($ssumask, $dir . "/" . $dir . ".bacteria.stk", "--ps-only -a", $testctr);
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".mask");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".mask.stk");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".mask.ps");
    $output = `cat $dir.bacteria.ssu-mask.sum`;
    if($output =~ /$dir.archaea.mask\s+output\s+mask\s+1508\s+1449\s+59/)      { die "ERROR, problem with masking"; }
    if($output !~ /$dir.bacteria.mask.ps\s+output\s+ps\s+1582\s+1499\s+83/)    { die "ERROR, problem with creating mask diagram"; }
    if($output =~ /$dir.bacteria.mask.pdf\s+output\s+pdf\s+1582\s+1499\s+83/)  { die "ERROR, problem with creating mask diagram"; }
    remove_files              (".", "bacteria.mask");
    remove_files              (".", "bacteria.ssu-mask");
}
$testctr++;

# Test --no-draw
if(($testnum eq "") || ($testnum == $testctr)) {
    # without -a 
    remove_files              ($dir, "mask");
    run_mask                  ($ssumask, $dir, "--no-draw", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".mask");
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".mask.stk");
    $output = `cat $dir/$dir.ssu-mask.sum`;
    if($output !~ /$dir.archaea.mask\s+output\s+mask\s+1508\s+1449\s+59/)      { die "ERROR, problem with masking"; }
    if($output =~ /$dir.bacteria.mask.ps\s+output\s+ps\s+1582\s+1499\s+83/)    { die "ERROR, problem with creating mask diagram"; }
    if($output =~ /$dir.bacteria.mask.pdf\s+output\s+pdf\s+1582\s+1499\s+83/)  { die "ERROR, problem with creating mask diagram"; }
    remove_files              ($dir, "mask");

    # with -a
    run_mask                  ($ssumask, $dir . "/" . $dir . ".bacteria.stk", "--no-draw -a", $testctr);
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".mask");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".mask.stk");
    $output = `cat $dir.bacteria.ssu-mask.sum`;
    if($output =~ /$dir.archaea.mask\s+output\s+mask\s+1508\s+1449\s+59/)      { die "ERROR, problem with masking"; }
    if($output !~ /$dir.bacteria.mask\s+output\s+mask\s+1582\s+1499\s+83/)    { die "ERROR, problem with creating mask diagram"; }
    if($output =~ /$dir.bacteria.mask.ps\s+output\s+ps\s+1582\s+1499\s+83/)    { die "ERROR, problem with creating mask diagram"; }
    if($output =~ /$dir.bacteria.mask.pdf\s+output\s+pdf\s+1582\s+1499\s+83/)  { die "ERROR, problem with creating mask diagram"; }
    remove_files              (".", "bacteria.mask");
    remove_files              (".", "bacteria.ssu-mask");
}
$testctr++;

###################################################################################
# Options for listing, converting, or removing sequences (no masking will be done):
###################################################################################
# Test --list
if(($testnum eq "") || ($testnum == $testctr)) {
    # without -a 
    run_mask                  ($ssumask, $dir, "--list", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".list");
    $output = `cat $dir/$dir.ssu-mask.sum`;
    if($output !~ /$dir.archaea.stk\s+$dir.archaea.list\s+5/) { die "ERROR, problem with listing sequences"; }
    if($output !~ /$dir.eukarya.stk\s+$dir.eukarya.list\s+5/) { die "ERROR, problem with listing sequences"; }
    remove_files              ($dir, "mask");

    # with -a 
    run_mask                  ($ssumask, $dir . "/" . $dir . ".eukarya.stk", "--list -a", $testctr);
    check_for_files           (".", $dir, $testctr, \@euk_only_A, ".list");
    $output = `cat $dir.eukarya.ssu-mask.sum`;
    if($output =~ /$dir.archaea.stk\s+$dir.archaea.list\s+5/) { die "ERROR, problem with listing sequences"; }
    if($output !~ /$dir.eukarya.stk\s+$dir.eukarya.list\s+5/) { die "ERROR, problem with listing sequences"; }
    remove_files              (".", "eukarya.mask");
    remove_files              (".", "eukarya.ssu-mask");
}
$testctr++;

# Test --stk2afa
if(($testnum eq "") || ($testnum == $testctr)) {
    # without -a
    run_mask                  ($ssumask, $dir, "--stk2afa", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".afa");
    $output = `cat $dir/$dir.ssu-mask.sum`;
    if($output !~ /$dir.archaea.stk\s+$dir.archaea.afa/) { die "ERROR, problem with stockholm to aligned fasta conversion"; }
    if($output !~ /$dir.eukarya.stk\s+$dir.eukarya.afa/) { die "ERROR, problem with stockholm to aligned fasta conversion"; }
    remove_files              ($dir, "afa");

    # with -a
    run_mask                  ($ssumask, $dir . "/" . $dir . ".eukarya.stk", "--stk2afa -a" , $testctr);
    check_for_files           (".", $dir, $testctr, \@euk_only_A, ".afa");
    $output = `cat $dir.eukarya.ssu-mask.sum`;
    if($output =~ /$dir.archaea.stk\s+$dir.archaea.afa/) { die "ERROR, problem with stockholm to aligned fasta conversion"; }
    if($output !~ /$dir.eukarya.stk\s+$dir.eukarya.afa/) { die "ERROR, problem with stockholm to aligned fasta conversion"; }
    remove_files              (".", $dir . ".eukarya.afa");
    remove_files              (".", $dir . ".eukarya.ssu-mask");
    remove_files              (".", $dir . ".eukarya.ssu-mask");
}
$testctr++;

# Test --seq-k (only possible in combination with -a)
if(($testnum eq "") || ($testnum == $testctr)) {
    # first run --list to get a list
    run_mask                  ($ssumask, $dir . "/" . $dir . ".eukarya.stk", "--list -a", $testctr);
    check_for_files           (".", $dir, $testctr, \@euk_only_A, ".list");
    $list_file = $dir . ".eukarya.list";
    $seqk_file = $dir . ".eukarya.seqk";
    open(LIST, $list_file) || die "TEST SCRIPT ERROR, unable to open file $list_file for reading.";
    $seq1 = <LIST>; chomp $seq1;
    $seq2 = <LIST>; chomp $seq2;
    $seq3 = <LIST>; chomp $seq3;
    $seq4 = <LIST>; chomp $seq4;
    $seq5 = <LIST>; chomp $seq5;
    close(LIST);
    open(SEQK, ">" . $seqk_file) || die "TEST SCRIPT ERROR, unable to open file $seqk_file for writing.";
    printf SEQK ("$seq1\n");
    printf SEQK ("$seq5\n");
    printf SEQK ("$seq4\n");
    close(SEQK);

    # now run ssu-mask --seq-k -a
    run_mask                  ($ssumask, $dir . "/" . $dir . ".eukarya.stk", "--seq-k $seqk_file -a" , $testctr);
    check_for_files           (".", $dir, $testctr, \@euk_only_A, ".seqk.stk");
    $output = `cat $dir.eukarya.ssu-mask.sum`;
    if($output =~ /archaea/)                   { die "ERROR, problem with stockholm to aligned fasta conversion"; }
    if($output !~ /$dir.eukarya.seqk.stk\s+3/) { die "ERROR, problem with stockholm to aligned fasta conversion"; }
    remove_files              (".", $dir . ".eukarya.list");
    remove_files              (".", $dir . ".eukarya.seqk");
    remove_files              (".", $dir . ".eukarya.ssu-mask");
}
$testctr++;

# Test --seq-r (only possible in combination with -a)
if(($testnum eq "") || ($testnum == $testctr)) {
    # first run --list to get a list
    run_mask                  ($ssumask, $dir . "/" . $dir . ".eukarya.stk", "--list -a", $testctr);
    check_for_files           (".", $dir, $testctr, \@euk_only_A, ".list");
    $list_file = $dir . ".eukarya.list";
    $seqr_file = $dir . ".eukarya.seqr";
    open(LIST, $list_file) || die "TEST SCRIPT ERROR, unable to open file $list_file for reading.";
    $seq1 = <LIST>; chomp $seq1;
    $seq2 = <LIST>; chomp $seq2;
    $seq3 = <LIST>; chomp $seq3;
    $seq4 = <LIST>; chomp $seq4;
    $seq5 = <LIST>; chomp $seq5;
    close(LIST);
    open(SEQR, ">" . $seqr_file) || die "TEST SCRIPT ERROR, unable to open file $seqr_file for writing.";
    printf SEQR ("$seq1\n");
    printf SEQR ("$seq4\n");
    printf SEQR ("$seq5\n");
    close(SEQR);

    # now run ssu-mask --seq-r -a
    run_mask                  ($ssumask, $dir . "/" . $dir . ".eukarya.stk", "--seq-r $seqr_file -a" , $testctr);
    check_for_files           (".", $dir, $testctr, \@euk_only_A, ".seqr.stk");
    $output = `cat $dir.eukarya.ssu-mask.sum`;
    if($output =~ /archaea/)                   { die "ERROR, problem with stockholm to aligned fasta conversion"; }
    if($output !~ /$dir.eukarya.seqr.stk\s+2/) { die "ERROR, problem with stockholm to aligned fasta conversion"; }
    remove_files              (".", $dir . ".eukarya.list");
    remove_files              (".", $dir . ".eukarya.seqr");
    remove_files              (".", $dir . ".eukarya.ssu-mask");
}
$testctr++;

####################################
# Test the special -m and -t options
####################################
if(($testnum eq "") || ($testnum == $testctr)) {
    # first, build new v4.cm with 3 v4 CMs
    run_build($ssubuild, "archaea", "-f -d --trunc 525-765  -n arc-v4 -o       v4.cm", $testctr);
    check_for_files           (".", "", $testctr, \@arc_only_A, "-0p1-sb.525-765.stk");
    check_for_one_of_two_files(".", "", $testctr, \@arc_only_A, "-0p1-sb.525-765.ps", "-0p1-sb.525-765.pdf");
    remove_files              (".", "0p1-sb.525-765");

    run_build($ssubuild, "bacteria", "-f -d --trunc 584-824  -n bac-v4 --append v4.cm", $testctr);
    check_for_files           (".", "", $testctr, \@bac_only_A, "-0p1-sb.584-824.stk");
    check_for_one_of_two_files(".", "", $testctr, \@bac_only_A, "-0p1-sb.584-824.ps", "-0p1-sb.584-824.pdf");
    remove_files              (".", "0p1-sb.584-824");

    run_build($ssubuild, "eukarya", "-f -d --trunc 620-1082 -n euk-v4 --append v4.cm", $testctr);
    check_for_files           (".", "", $testctr, \@euk_only_A, "-0p1-sb.620-1082.stk");
    check_for_one_of_two_files(".", "", $testctr, \@euk_only_A, "-0p1-sb.620-1082.ps", "-0p1-sb.620-1082.pdf");
    remove_files              (".", "0p1-sb.620-1082");

    @v4_name_A = ("arc-v4", "bac-v4", "euk-v4");
    @v4_arc_only_A = ("arc-v4");

    # next, call ssu-align with new v4.cm
    run_align($ssualign, $fafile, $dir, "-f -m v4.cm", $testctr);
    check_for_files($dir, $dir, $testctr, \@v4_name_A, ".hitlist");
    check_for_files($dir, $dir, $testctr, \@v4_name_A, ".fa");
    check_for_files($dir, $dir, $testctr, \@v4_name_A, ".stk");
    check_for_files($dir, $dir, $testctr, \@v4_name_A, ".ifile");
    check_for_files($dir, $dir, $testctr, \@v4_name_A, ".cmalign");

    # mask alignments 
    # without -a 
    run_mask($ssumask, $dir, "-m v4.cm", $testctr);
    check_for_files($dir, $dir, $testctr, \@v4_name_A, ".mask");
    check_for_files($dir, $dir, $testctr, \@v4_name_A, ".mask.stk");
    $output = `cat $dir/$dir.ssu-mask.sum`;
    if($output !~ /$dir.bac-v4.mask\s+output\s+mask\s+241\s+237\s+4/) { die "ERROR, problem with masking";}
    remove_files              ($dir, "mask");

    # with -a 
    run_mask($ssumask, $dir . "/" . $dir . ".arc-v4.stk", "-a -m v4.cm", $testctr);
    check_for_files(".", $dir, $testctr, \@v4_arc_only_A, ".mask");
    check_for_files(".", $dir, $testctr, \@v4_arc_only_A, ".mask.stk");
    $output = `cat $dir.arc-v4.ssu-mask.sum`;
    if($output !~ /$dir.arc-v4.mask\s+output\s+mask\s+241\s+241\s+0/) { die "ERROR, problem with masking";}
    remove_files(".", "arc-v4.mask");
    remove_files(".", "arc-v4.ssu-mask");

    remove_files(".", "v4.cm");
}
$testctr++;

if(($testnum eq "") || ($testnum == $testctr)) {
    # first, build new trna.cm 
    $trna_cmfile = "trna-5.cm";
    @trna_only_A = "trna-5";
    run_build($ssubuild, $trna_stkfile, "-f --rf -n $trna_only_A[0] -o $trna_cmfile", $testctr);
    check_for_files           (".", "", $testctr, \@trna_only_A, ".cm");
    check_for_files           (".", "", $testctr, \@trna_only_A, ".ssu-build.log");
    check_for_files           (".", "", $testctr, \@trna_only_A, ".ssu-build.sum");
    remove_files(".", "trna-5.ssu-build");

    # next, call ssu-align with new $trna_cmfile
    run_align($ssualign, $trna_fafile, $dir, "-f -m $trna_cmfile", $testctr);
    check_for_files($dir, $dir, $testctr, \@trna_only_A, ".hitlist");
    check_for_files($dir, $dir, $testctr, \@trna_only_A, ".fa");
    check_for_files($dir, $dir, $testctr, \@trna_only_A, ".stk");
    check_for_files($dir, $dir, $testctr, \@trna_only_A, ".ifile");
    check_for_files($dir, $dir, $testctr, \@trna_only_A, ".cmalign");

    # mask alignments with -t $trna_psfile
    # without -a 
    run_mask($ssumask, $dir, "-t $trna_psfile -m $trna_cmfile", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@trna_only_A, ".mask");
    check_for_files           ($dir, $dir, $testctr, \@trna_only_A, ".mask.stk");
    check_for_one_of_two_files($dir, $dir, $testctr, \@trna_only_A, ".mask.ps", ".mask.pdf");
    $output = `cat $dir/$dir.ssu-mask.sum`;
    if($output !~ /$dir.trna-5.mask\s+output\s+mask\s+71\s+68\s+3/) { die "ERROR, problem with masking";}
    remove_files              ($dir, "mask");

    # with -a 
    run_mask($ssumask, $dir . "/" . $dir . ".trna-5.stk", "-a -t $trna_psfile -m $trna_cmfile", $testctr);
    check_for_files(".", $dir, $testctr, \@trna_only_A, ".mask");
    check_for_files(".", $dir, $testctr, \@trna_only_A, ".mask.stk");
    $output = `cat $dir.trna-5.ssu-mask.sum`;
    if($output !~ /$dir.trna-5.mask\s+output\s+mask\s+71\s+68\s+3/) { die "ERROR, problem with masking";}
    remove_files(".", "trna-5.mask");
    remove_files(".", "trna-5.ssu-mask");
    remove_files(".", "trna-5.cm");
}
$testctr++;

# Clean up
if(-d $dir) { 
    foreach $file (glob("$dir/*")) { 
	unlink $file;
    }
    rmdir $dir;
}

printf("All commands completed successfully.\n");
exit 0;
