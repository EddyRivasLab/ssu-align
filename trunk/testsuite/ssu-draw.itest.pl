#! /usr/bin/perl
#
# Integrated test number 1 of the SSU-ALIGN scripts, focusing on ssu-draw.
#
# Usage:     ./ssu-draw.itest.pl <directory with all 5 SSU-ALIGN scripts> <data directory with fasta files etc.> <tmpfile and tmpdir prefix> <test number to perform, if blank do all tests>
# Examples:  ./ssu-draw.itest.pl ../src/ data/ foo   (do all tests)
#            ./ssu-draw.itest.pl ../src/ data/ foo 4 (do only test 4)
#
# EPN, Fri Mar 12 09:51:27 2010

$usage = "perl ssu-draw.itest.pl\n\t<directory with all 5 SSU-ALIGN scripts>\n\t<data directory with fasta files etc.>\n\t<tmpfile and tmpdir prefix>\n\t<test number to perform, if blank, do all tests>\n";
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
if($dir =~ m/draw/) { 
    die "ERROR, <tmpfile and tmpdir prefix> cannot contain 'draw'";
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
@ssudraw_only_A = ("ssu-draw");
$mask_key_in  = "181";
$draw_key_out = "1.8.1";

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
    run_draw($ssudraw, "", "-h", $testctr);
    if ($? != 0) { die "FAIL: ssu-draw -h failed unexpectedly"; }
}
$testctr++;

# Test default (no options)
if(($testnum eq "") || ($testnum == $testctr)) {
    run_draw                  ($ssudraw, $dir, "", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".drawtab");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".sum");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".log");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".pdf", ".ps");
    $output = `cat $dir/$dir.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.p\w+/)        { die "ERROR, problem with drawing"; }
    $output = `cat $dir/$dir.bacteria.drawtab`;
    if($output !~ /infocontent\s+1\s+2.\d+\s+2\s+6\s*infocontent/) { die "ERROR, problem with drawing"; }
    if($output !~ /span\s+1\s+0.4\d+\s+4\s*span/)                  { die "ERROR, problem with drawing"; } 
    remove_files              ($dir, "draw");
    remove_files              ($dir, "\.ps");
    remove_files              ($dir, "\.pdf");
}
$testctr++;

# Test --cnt 
# NOTE: I do the same checks as I did for default (no options),
# so I'm not checking that consensus nt are actually being drawn
if(($testnum eq "") || ($testnum == $testctr)) {
    run_draw                  ($ssudraw, $dir, "--cnt", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".drawtab");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".sum");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".log");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".pdf", ".ps");
    $output = `cat $dir/$dir.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.p\w+/)        { die "ERROR, problem with drawing"; }
    $output = `cat $dir/$dir.bacteria.drawtab`;
    if($output !~ /infocontent\s+1\s+2.\d+\s+2\s+6\s*infocontent/) { die "ERROR, problem with drawing"; }
    if($output !~ /span\s+1\s+0.4\d+\s+4\s*span/)                  { die "ERROR, problem with drawing"; } 
    remove_files              ($dir, "draw");
    remove_files              ($dir, "\.ps");
    remove_files              ($dir, "\.pdf");
}
$testctr++;


# Test default (no options) and --no-mask with freshly created mask files in foo/ (masks should automatically be incorporated into the drawings)
if(($testnum eq "") || ($testnum == $testctr)) {
    run_mask                  ($ssumask, $dir, "", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".mask");
    run_draw                  ($ssudraw, $dir, "", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".drawtab");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".sum");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".log");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".pdf", ".ps");
    $output = `cat $dir/$dir.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.p\w+/)        { die "ERROR, problem with drawing"; }
    $output = `cat $dir/$dir.bacteria.drawtab`;
    if($output !~ /infocontent\s+1\s+2.\d+\s+2\s+6\s+1\s*infocontent/) { die "ERROR, problem with drawing"; }
    if($output !~ /span\s+1\s+0.4\d+\s+4\s+1\s*span/)                 { die "ERROR, problem with drawing"; } 
    $output = `cat $dir/$dir.ssu-draw.log`;
    if($output !~ /Executing\:\s+ssu-esl-ssdraw.+\-\-mask/) { die "ERROR, problem with drawing"; } 
    remove_files              ($dir, "draw");
    remove_files              ($dir, "\.ps");
    remove_files              ($dir, "\.pdf");

    # check that --no-mask works
    run_draw                  ($ssudraw, $dir, "--no-mask", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".drawtab");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".sum");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".log");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".pdf", ".ps");
    $output = `cat $dir/$dir.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.p\w+/)        { die "ERROR, problem with drawing"; }
    $output = `cat $dir/$dir.bacteria.drawtab`;
    if($output !~ /infocontent\s+1\s+2.\d+\s+2\s+6\s*infocontent/) { die "ERROR, problem with drawing"; }
    if($output !~ /span\s+1\s+0.4\d+\s+4\s*span/)                 { die "ERROR, problem with drawing"; } 
    $output = `cat $dir/$dir.ssu-draw.log`;
    if($output =~ /Executing\:\s+ssu-esl-ssdraw.+\-\-mask/) { die "ERROR, problem with drawing"; } 
    remove_files              ($dir, "draw");
    remove_files              ($dir, "\.ps");
    remove_files              ($dir, "\.pdf");

    # test that -a uses the mask
    run_draw                  ($ssudraw, $dir . "/" . $dir . ".bacteria.stk", "-a", $testctr);
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".drawtab");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.sum");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.log");
    check_for_one_of_two_files(".", $dir, $testctr, \@bac_only_A, ".pdf", ".ps");
    $output = `cat $dir.bacteria.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.p\w+/) { die "ERROR, problem with drawing"; }
    $output = `cat $dir.bacteria.drawtab`;
    if($output !~ /infocontent\s+1\s+2.\d+\s+2\s+6\s+1\s*infocontent/) { die "ERROR, problem with drawing"; }
    if($output !~ /span\s+1\s+0.4\d+\s+4\s+1\s*span/)                  { die "ERROR, problem with drawing"; } 
    $output = `cat $dir.bacteria.ssu-draw.log`;
    if($output !~ /Executing\:\s+ssu-esl-ssdraw.+\-\-mask/) { die "ERROR, problem with drawing"; } 
    remove_files              (".", "bacteria.draw");
    remove_files              (".", "bacteria.ssu-draw");

    # and now that -a and --no-mask does not use the mask
    run_draw                  ($ssudraw, $dir . "/" . $dir . ".bacteria.stk", "--no-mask -a", $testctr);
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".drawtab");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.sum");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.log");
    check_for_one_of_two_files(".", $dir, $testctr, \@bac_only_A, ".pdf", ".ps");
    $output = `cat $dir.bacteria.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.p\w+/) { die "ERROR, problem with drawing"; }
    $output = `cat $dir.bacteria.drawtab`;
    if($output !~ /infocontent\s+1\s+2.\d+\s+2\s+6\s*infocontent/) { die "ERROR, problem with drawing"; }
    if($output !~ /span\s+1\s+0.4\d+\s+4\s*span/)                  { die "ERROR, problem with drawing"; } 
    $output = `cat $dir.bacteria.ssu-draw.log`;
    if($output =~ /Executing\:\s+ssu-esl-ssdraw.+\-\-mask/) { die "ERROR, problem with drawing"; } 
    remove_files              (".", "bacteria.draw");
    remove_files              (".", "bacteria.ssu-draw");
    remove_files              (".", "bacteria.pdf");
    remove_files              (".", "bacteria.ps");
    # remove masks
    remove_files              ($dir, "mask");
}
$testctr++;

# Test -a (on $dir.bacteria.stk in $dir/)
if(($testnum eq "") || ($testnum == $testctr)) {
    run_draw                  ($ssudraw, $dir . "/" . $dir . ".bacteria.stk", "-a", $testctr);
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".drawtab");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.sum");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.log");
    check_for_one_of_two_files(".", $dir, $testctr, \@bac_only_A, ".pdf", ".ps");
    $output = `cat $dir.bacteria.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.p\w+/) { die "ERROR, problem with drawing"; }
    $output = `cat $dir.bacteria.drawtab`;
    if($output !~ /infocontent\s+1\s+2.\d+\s+2\s+6\s*infocontent/) { die "ERROR, problem with drawing"; }
    if($output !~ /span\s+1\s+0.4\d+\s+4\s*span/)                  { die "ERROR, problem with drawing"; } 
    remove_files              (".", "bacteria.draw");
    remove_files              (".", "bacteria.ssu-draw");
}
$testctr++;

# Test -a (on $dir.bacteria.stk in cwd/)
if(($testnum eq "") || ($testnum == $testctr)) {
    system("cp " . $dir . "/" . $dir . ".bacteria.stk $dir.bacteria.stk");
    run_draw                  ($ssudraw, $dir . ".bacteria.stk", "-a", $testctr);
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".drawtab");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.sum");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.log");
    check_for_one_of_two_files(".", $dir, $testctr, \@bac_only_A, ".pdf", ".ps");
    $output = `cat $dir.bacteria.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.p\w+/) { die "ERROR, problem with drawing"; }
    $output = `cat $dir.bacteria.drawtab`;
    if($output !~ /infocontent\s+1\s+2.\d+\s+2\s+6\s*infocontent/) { die "ERROR, problem with drawing"; }
    if($output !~ /span\s+1\s+0.4\d+\s+4\s*span/)                  { die "ERROR, problem with drawing"; } 
    remove_files              (".", "bacteria.draw");
    remove_files              (".", "bacteria.ssu-draw");
    remove_files              (".", "$dir.bacteria.stk");
}
$testctr++;

# Test -d
if(($testnum eq "") || ($testnum == $testctr)) {
    # without -a
    run_draw                  ($ssudraw, $dir, "-d", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".drawtab");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".sum");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".log");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".pdf", ".ps");
    $output = `cat $dir/$dir.bacteria.drawtab`;
    if($output !~ /infocontent\s+1\s+2.\d+\s+2\s+6\s+1\s*infocontent/) { die "ERROR, problem with drawing"; }
    if($output !~ /span\s+1\s+0.4\d+\s+4\s+1\s*span/)                  { die "ERROR, problem with drawing"; } 
    $output = `cat $dir/$dir.ssu-draw.log`;
    if($output !~ /Executing\:\s+ssu-esl-ssdraw.+\-\-mask\s+/)         { die "ERROR, problem with drawing"; } 
    remove_files              ($dir, "draw");
    remove_files              ($dir, "\.ps");
    remove_files              ($dir, "\.pdf");

    # with -a
    run_draw                  ($ssudraw, $dir . "/" . $dir . ".bacteria.stk", "-d -a", $testctr);
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".drawtab");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.sum");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.log");
    check_for_one_of_two_files(".", $dir, $testctr, \@bac_only_A, ".pdf", ".ps");
    $output = `cat $dir.bacteria.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.p\w+/) { die "ERROR, problem with drawing"; }
    $output = `cat $dir.bacteria.drawtab`;
    if($output !~ /infocontent\s+1\s+2.\d+\s+2\s+6\s+1\s*infocontent/) { die "ERROR, problem with drawing"; }
    if($output !~ /span\s+1\s+0.4\d+\s+4\s+1\s*span/)                  { die "ERROR, problem with drawing"; } 
    $output = `cat $dir.bacteria.ssu-draw.log`;
    if($output !~ /Executing\:\s+ssu-esl-ssdraw.+\-\-mask\s+/)         { die "ERROR, problem with drawing"; } 
    remove_files              (".", "bacteria.draw");
    remove_files              (".", "bacteria.ssu-draw");
}
$testctr++;

# Test -s with -a (on $dir.bacteria.stk in cwd/ freshly created foo.bacteria.mask in $dir/)
if(($testnum eq "") || ($testnum == $testctr)) {
    run_mask                  ($ssumask, $dir, "", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".mask");
    system("cp " . $dir . "/" . $dir . ".bacteria.stk $dir.bacteria.stk");
    $in_mask_file = $dir . "/" . $dir . ".bacteria.mask";
    run_draw                  ($ssudraw, $dir . ".bacteria.stk", "-a -s $in_mask_file", $testctr);
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".drawtab");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.sum");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.log");
    check_for_one_of_two_files(".", $dir, $testctr, \@bac_only_A, ".pdf", ".ps");
    $output = `cat $dir.bacteria.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.p\w+/) { die "ERROR, problem with drawing"; }
    $output = `cat $dir.bacteria.drawtab`;
    if($output !~ /infocontent\s+1\s+2.\d+\s+2\s+6\s+1\s*infocontent/) { die "ERROR, problem with drawing"; }
    if($output !~ /span\s+1\s+0.4\d+\s+4\s+1\s*span/)                  { die "ERROR, problem with drawing"; } 
    $output = `cat $dir.bacteria.ssu-draw.log`;
    if($output !~ /Executing\:\s+ssu-esl-ssdraw.+\-\-mask\s+$in_mask_file/) { die "ERROR, problem with drawing"; } 
    remove_files              (".", "bacteria.draw");
    remove_files              (".", "bacteria.ssu-draw");
    remove_files              (".", "$dir.bacteria.stk");
    remove_files              ($dir, "mask");

    # test the negative, using no -s should cause ssu-draw to *not* use a mask
    system("cp " . $dir . "/" . $dir . ".bacteria.stk $dir.bacteria.stk");
    run_draw                  ($ssudraw, $dir . ".bacteria.stk", "-a", $testctr);
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".drawtab");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.sum");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.log");
    check_for_one_of_two_files(".", $dir, $testctr, \@bac_only_A, ".pdf", ".ps");
    $output = `cat $dir.bacteria.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.p\w+/) { die "ERROR, problem with drawing"; }
    $output = `cat $dir.bacteria.drawtab`;
    if($output !~ /infocontent\s+1\s+2.\d+\s+2\s+6\s*infocontent/) { die "ERROR, problem with drawing"; }
    if($output !~ /span\s+1\s+0.4\d+\s+4\s*span/)                  { die "ERROR, problem with drawing"; } 
    $output = `cat $dir.bacteria.ssu-draw.log`;
    if($output =~ /Executing\:\s+ssu-esl-ssdraw.+\-\-mask\s+$in_mask_file/) { die "ERROR, problem with drawing"; } 
    remove_files              (".", "bacteria.draw");
    remove_files              (".", "bacteria.ssu-draw");
    remove_files              (".", "$dir.bacteria.stk");
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
    run_draw                  ($ssudraw, $dir, "-k $mask_key_in", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".drawtab");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".sum");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".log");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".pdf", ".ps");
    $output = `cat $dir/$dir.ssu-draw.sum`;
    if($output !~ /$dir.archaea.stk\s+$dir.archaea.p\w+/)    { die "ERROR, problem with drawing"; }
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.p\w+/)  { die "ERROR, problem with drawing"; }
    if($output !~ /$dir.eukarya.stk\s+$dir.eukarya.p\w+/)    { die "ERROR, problem with drawing"; }
    $output = `cat $dir/$dir.bacteria.drawtab`;
    if($output !~ /infocontent\s+1\s+2.\d+\s+2\s+6\s+1\s*infocontent/) { die "ERROR, problem with drawing"; }
    if($output !~ /span\s+1\s+0.4\d+\s+4\s+1\s*span/)                  { die "ERROR, problem with drawing"; } 
    remove_files              ($dir, "draw");
    remove_files              ($dir, "\.ps");
    remove_files              ($dir, "\.pdf");
    foreach $name (@name_A) {
	$newmaskfile  = $dir . "/" . $name . "." . $mask_key_in . ".mask";
	remove_files(".", $newmaskfile);
    }

    # with -a, need to put mask files in cwd first
    foreach $name (@euk_only_A) {
	$maskfile     = $datadir . "/" . $name . "." . $mask_key_in . ".mask";
	$newmaskfile  = $dir . "." . $name . "." . $mask_key_in . ".mask";
	system("cp $maskfile $newmaskfile");
	if ($? != 0) { die "FAIL: cp command failed unexpectedly";}
    }
    run_draw                  ($ssudraw, $dir . "/" . $dir . ".eukarya.stk", "-k $mask_key_in -a", $testctr);
    check_for_files           (".", $dir, $testctr, \@euk_only_A, ".drawtab");
    check_for_files           (".", $dir, $testctr, \@euk_only_A, ".ssu-draw.sum");
    check_for_files           (".", $dir, $testctr, \@euk_only_A, ".ssu-draw.log");
    check_for_one_of_two_files(".", $dir, $testctr, \@euk_only_A, ".pdf", ".ps");
    $output = `cat $dir.eukarya.ssu-draw.sum`;
    if($output !~ /$dir.eukarya.stk\s+$dir.eukarya.p\w+/)    { die "ERROR, problem with drawing"; }
    $output = `cat $dir.eukarya.drawtab`;
    if($output !~ /infocontent\s+1\s+1.08\d+\s+3\s+3\s+1\s*infocontent/) { die "ERROR, problem with drawing"; }
    if($output !~ /span\s+1\s+0.6\d+\s+5\s+1\s*span/)                  { die "ERROR, problem with drawing"; } 
    remove_files              (".", "eukarya.draw");
    remove_files              (".", "eukarya.ssu-draw");
    foreach $name (@euk_only_A) {
	$newmaskfile  = $dir . "." . $name . "." . $mask_key_in . ".mask";
	remove_files(".", $newmaskfile);
    }

    # now test if mask files are in the cwd, not in $dir (without -a):
    foreach $name (@name_A) {
	$maskfile     = $datadir . "/" . $name . "." . $mask_key_in . ".mask";
	$newmaskfile  = $name . "." . $mask_key_in . ".mask";
	system("cp $maskfile $newmaskfile");
	if ($? != 0) { die "FAIL: cp command failed unexpectedly";}
    }
    # without -a 
    run_draw                  ($ssudraw, $dir, "-k $mask_key_in", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".drawtab");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".sum");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".log");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".pdf", ".ps");
    $output = `cat $dir/$dir.ssu-draw.sum`;
    if($output !~ /$dir.archaea.stk\s+$dir.archaea.p\w+/)    { die "ERROR, problem with drawing"; }
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.p\w+/)  { die "ERROR, problem with drawing"; }
    if($output !~ /$dir.eukarya.stk\s+$dir.eukarya.p\w+/)    { die "ERROR, problem with drawing"; }
    $output = `cat $dir/$dir.bacteria.drawtab`;
    if($output !~ /infocontent\s+1\s+2.\d+\s+2\s+6\s+1\s*infocontent/) { die "ERROR, problem with drawing"; }
    if($output !~ /span\s+1\s+0.4\d+\s+4\s+1\s*span/)                  { die "ERROR, problem with drawing"; } 
    remove_files              ($dir, "draw");
    remove_files              ($dir, "\.ps");
    remove_files              ($dir, "\.pdf");
    foreach $name (@name_A) {
	$newmaskfile  = $name . "." . $mask_key_in . ".mask";
	remove_files(".", $newmaskfile);
    }
}
$testctr++;

# Test -i
if(($testnum eq "") || ($testnum == $testctr)) {
    #without -a 
    run_draw                  ($ssudraw, $dir, "-i", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".drawtab");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".sum");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".log");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".pdf", ".ps");
    $output = `cat $dir/$dir.ssu-draw.sum`;
    if($output !~ /$dir.archaea.stk\s+$dir.archaea.p\w+/)    { die "ERROR, problem with drawing"; }
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.p\w+/)  { die "ERROR, problem with drawing"; }
    if($output !~ /$dir.eukarya.stk\s+$dir.eukarya.p\w+/)    { die "ERROR, problem with drawing"; }
    $output = `cat $dir/$dir.bacteria.drawtab`;
    if($output !~ /infocontent\s+1\s+2.\d+\s+2\s+6\s*infocontent/) { die "ERROR, problem with drawing"; }
    if($output !~ /span\s+1\s+0.4\d+\s+4\s*span/)                  { die "ERROR, problem with drawing"; } 
    remove_files              (".", "bacteria.draw");
    remove_files              (".", "bacteria.ssu-draw");

    # with -a
    run_draw                  ($ssudraw, $dir . "/" . $dir . ".eukarya.stk", "-i -a", $testctr);
    check_for_files           (".", $dir, $testctr, \@euk_only_A, ".drawtab");
    check_for_files           (".", $dir, $testctr, \@euk_only_A, ".ssu-draw.sum");
    check_for_files           (".", $dir, $testctr, \@euk_only_A, ".ssu-draw.log");
    check_for_one_of_two_files(".", $dir, $testctr, \@euk_only_A, ".pdf", ".ps");
    $output = `cat $dir.eukarya.ssu-draw.sum`;
    if($output !~ /$dir.eukarya.stk\s+$dir.eukarya.p\w+/)    { die "ERROR, problem with drawing"; }
    $output = `cat $dir.eukarya.drawtab`;
    if($output !~ /infocontent\s+1\s+1.08\d+\s+3\s+3\s*infocontent/) { die "ERROR, problem with drawing"; }
    if($output !~ /span\s+1\s+0.6\d+\s+5\s*span/)                  { die "ERROR, problem with drawing"; } 
    remove_files              (".", "eukarya.draw");
    remove_files              (".", "eukarya.ssu-draw");
    remove_files              (".", "eukarya.pdf");
    remove_files              (".", "eukarya.ps");
}
$testctr++;

####################################
# Miscellaneous input/output options
####################################
# tests only --ifile, --key-out, --mask-key
# --no-mask is tested above.
# --ps2pdf is not tested b/c it is hard to test due to non-portability
# --ps-only is tested below.

# Test --ifile with -a (on $dir.bacteria.stk in cwd/ and $dir.bacteria.ifile in $dir/)
if(($testnum eq "") || ($testnum == $testctr)) {
    system("cp " . $dir . "/" . $dir . ".bacteria.stk $dir.bacteria.stk");
    $ifile = $dir . "/" . $dir . ".bacteria.ifile";
    run_draw                  ($ssudraw, $dir . ".bacteria.stk", "-a --ifile $ifile", $testctr);
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".drawtab");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.sum");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.log");
    check_for_one_of_two_files(".", $dir, $testctr, \@bac_only_A, ".pdf", ".ps");
    $output = `cat $dir.bacteria.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.p\w+/) { die "ERROR, problem with drawing"; }
    $output = `cat $dir.bacteria.drawtab`;
    if($output !~ /infocontent\s+1\s+2.\d+\s+2\s+6\s*infocontent/) { die "ERROR, problem with drawing"; }
    if($output !~ /span\s+1\s+0.4\d+\s+4\s*span/)                  { die "ERROR, problem with drawing"; } 
    $output = `cat $dir.bacteria.ssu-draw.log`;
    if($output !~ /Executing\:\s+ssu-esl-ssdraw.+\-\-ifile\s+$ifile/) { die "ERROR, problem with drawing"; } 
    remove_files              (".", "bacteria.draw");
    remove_files              (".", "bacteria.ssu-draw");
    remove_files              (".", "$dir.bacteria.stk");
}
$testctr++;

# Test --key-out
if(($testnum eq "") || ($testnum == $testctr)) {
    # without -a
    run_draw                  ($ssudraw, $dir, "--key-out $draw_key_out", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".$draw_key_out.drawtab");
    check_for_files           ($dir, $dir . "." . $draw_key_out, $testctr, \@ssudraw_only_A, ".sum");
    check_for_files           ($dir, $dir . "." . $draw_key_out, $testctr, \@ssudraw_only_A, ".log");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".$draw_key_out.pdf", ".$draw_key_out.ps");
    $output = `cat $dir/$dir.$draw_key_out.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.$draw_key_out.p\w+/)   { die "ERROR, problem with drawing"; }
    $output = `cat $dir/$dir.bacteria.$draw_key_out.drawtab`;
    if($output !~ /infocontent\s+1\s+2.\d+\s+2\s+6\s*infocontent/) { die "ERROR, problem with drawing"; }
    if($output !~ /span\s+1\s+0.4\d+\s+4\s*span/)                 { die "ERROR, problem with drawing"; } 
    remove_files              ($dir, "draw");
    remove_files              ($dir, "\.ps");
    remove_files              ($dir, "\.pdf");

    # with -a
    run_draw                  ($ssudraw, $dir . "/" . $dir . ".bacteria.stk", "--key-out $draw_key_out -a", $testctr);
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".$draw_key_out.drawtab");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".$draw_key_out.ssu-draw.sum");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".$draw_key_out.ssu-draw.log");
    check_for_one_of_two_files(".", $dir, $testctr, \@bac_only_A, ".$draw_key_out.pdf", ".$draw_key_out.ps");
    $output = `cat $dir.bacteria.$draw_key_out.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.$draw_key_out.p\w+/) { die "ERROR, problem with drawing"; }
    $output = `cat $dir.bacteria.$draw_key_out.drawtab`;
    if($output !~ /infocontent\s+1\s+2.\d+\s+2\s+6\s*infocontent/) { die "ERROR, problem with drawing"; }
    if($output !~ /span\s+1\s+0.4\d+\s+4\s*span/)                  { die "ERROR, problem with drawing"; } 
    remove_files              (".", "bacteria.$draw_key_out.draw");
    remove_files              (".", "bacteria.$draw_key_out.ssu-draw");
    remove_files              (".", "bacteria.$draw_key_out.pdf");
    remove_files              (".", "bacteria.$draw_key_out.ps");
}
$testctr++;


# Test 'ssu-mask --key-out'; 'ssu-draw --mask-key';
if(($testnum eq "") || ($testnum == $testctr)) {
    $mykey = "test-key";

    # without -a
    run_mask                  ($ssumask, $dir, "--key-out $mykey", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ("." . $mykey . ".mask"));
    run_draw                  ($ssudraw, $dir, "--mask-key $mykey --key-out $mykey", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".$mykey.drawtab");
    check_for_files           ($dir, $dir . "." . $mykey, $testctr, \@ssudraw_only_A, ".sum");
    check_for_files           ($dir, $dir . "." . $mykey, $testctr, \@ssudraw_only_A, ".log");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".$mykey.pdf", ".$mykey.ps");
    $output = `cat $dir/$dir.$mykey.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.$mykey.p\w+/)   { die "ERROR, problem with drawing"; }
    $output = `cat $dir/$dir.bacteria.$mykey.drawtab`;
    if($output !~ /infocontent\s+1\s+2.\d+\s+2\s+6\s+1\s*infocontent/) { die "ERROR, problem with drawing"; }
    if($output !~ /span\s+1\s+0.4\d+\s+4\s+1\s*span/)                 { die "ERROR, problem with drawing"; } 
    remove_files              ($dir, "draw");
    remove_files              ($dir, "\.ps");
    remove_files              ($dir, "\.pdf");
    remove_files              ($dir, "mask");

    # with -a
    run_mask                  ($ssumask, $dir . "/" . $dir . ".bacteria.stk", "--key-out $mykey -a", $testctr);
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ("." . $mykey . ".mask"));
    run_draw                  ($ssudraw, $dir . "/" . $dir . ".bacteria.stk", "--mask-key $mykey --key-out $mykey -a", $testctr);
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".$mykey.drawtab");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".$mykey.ssu-draw.sum");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".$mykey.ssu-draw.log");
    check_for_one_of_two_files(".", $dir, $testctr, \@bac_only_A, ".$mykey.pdf", ".$mykey.ps");
    $output = `cat $dir.bacteria.$mykey.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.$mykey.p\w+/) { die "ERROR, problem with drawing"; }
    $output = `cat $dir.bacteria.$mykey.drawtab`;
    if($output !~ /infocontent\s+1\s+2.\d+\s+2\s+6\s+1\s*infocontent/) { die "ERROR, problem with drawing"; }
    if($output !~ /span\s+1\s+0.4\d+\s+4\s+1\s*span/)                  { die "ERROR, problem with drawing"; } 
    remove_files              (".", "bacteria.$mykey.draw");
    remove_files              (".", "bacteria.$mykey.ssu-draw");
    remove_files              (".", "bacteria.$mykey.mask");
    remove_files              (".", "bacteria.$mykey.ssu-mask");
    remove_files              (".", "bacteria.$mykey.pdf");
    remove_files              (".", "bacteria.$mykey.ps");
}
$testctr++;



###############################################
# Options for 1-page alignment summary diagrams
###############################################

# Test --prob
if(($testnum eq "") || ($testnum == $testctr)) {
    # without -a
    run_draw                  ($ssudraw, $dir, "--prob --no-aln", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".prob.drawtab");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".sum");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".log");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".prob.pdf", ".prob.ps");
    $output = `cat $dir/$dir.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.prob.p\w+\s+1\s*/)     { die "ERROR, problem with drawing"; }
    $output = `cat $dir/$dir.bacteria.prob.drawtab`;
    if($output !~ /avgpostprob\s+1\s+0.97\d+\s+2\s+6\s*avgpostprob/) { die "ERROR, problem with drawing"; }
    remove_files              ($dir, "draw");
    remove_files              ($dir, "\.ps");
    remove_files              ($dir, "\.pdf");

    # with -a
    run_draw                  ($ssudraw, $dir . "/" . $dir . ".bacteria.stk", "--prob --no-aln -a", $testctr);
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".prob.drawtab");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.sum");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.log");
    check_for_one_of_two_files(".", $dir, $testctr, \@bac_only_A, ".prob.pdf", ".prob.ps");
    $output = `cat $dir.bacteria.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.prob.p\w+\s+1\s*/)        { die "ERROR, problem with drawing"; }
    $output = `cat $dir.bacteria.prob.drawtab`;
    if($output !~ /avgpostprob\s+1\s+0.97\d+\s+2\s+6\s*avgpostprob/) { die "ERROR, problem with drawing"; }
    remove_files              (".", "bacteria.prob");
    remove_files              (".", "bacteria.ssu-draw");
}
$testctr++;

# Test --ifreq
if(($testnum eq "") || ($testnum == $testctr)) {
    # without -a
    run_draw                  ($ssudraw, $dir, "--ifreq --no-aln", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".ifreq.drawtab");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".sum");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".log");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".ifreq.pdf", ".ifreq.ps");
    $output = `cat $dir/$dir.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.ifreq.p\w+\s+1\s*/)   { die "ERROR, problem with drawing"; }
    $output = `cat $dir/$dir.bacteria.ifreq.drawtab`;
    if($output !~ /insertfreq\s+73\s+0.33\d+\s+3\s+5\s*insertfreq/) { die "ERROR, problem with drawing"; }
    remove_files              ($dir, "draw");
    remove_files              ($dir, "\.ps");
    remove_files              ($dir, "\.pdf");

    # with -a
    run_draw                  ($ssudraw, $dir . "/" . $dir . ".bacteria.stk", "--ifreq --no-aln -a", $testctr);
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ifreq.drawtab");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.sum");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.log");
    check_for_one_of_two_files(".", $dir, $testctr, \@bac_only_A, ".ifreq.pdf", ".ifreq.ps");
    $output = `cat $dir.bacteria.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.ifreq.p\w+\s+1\s*/)   { die "ERROR, problem with drawing"; }
    $output = `cat $dir.bacteria.ifreq.drawtab`;
    if($output !~ /insertfreq\s+73\s+0.33\d+\s+3\s+5\s*insertfreq/) { die "ERROR, problem with drawing"; }
    remove_files              (".", "bacteria.ifreq");
    remove_files              (".", "bacteria.ssu-draw");
}
$testctr++;

# Test --iavglen
if(($testnum eq "") || ($testnum == $testctr)) {
    # without -a
    run_draw                  ($ssudraw, $dir, "--iavglen --no-aln", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".iavglen.drawtab");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".sum");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".log");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".iavglen.pdf", ".iavglen.ps");
    $output = `cat $dir/$dir.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.iavglen.p\w+\s+1\s*/)               { die "ERROR, iavglenlem with drawing"; }
    $output = `cat $dir/$dir.bacteria.iavglen.drawtab`;
    if($output !~ /insertavglen\s+73\s+1.00\d+\s+0.33\d+\s+3\s+1\s*insertavglen/) { die "ERROR, problem with drawing"; }
    remove_files              ($dir, "draw");
    remove_files              ($dir, "\.ps");
    remove_files              ($dir, "\.pdf");

    # with -a
    run_draw                  ($ssudraw, $dir . "/" . $dir . ".bacteria.stk", "--iavglen --no-aln -a", $testctr);
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".iavglen.drawtab");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.sum");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.log");
    check_for_one_of_two_files(".", $dir, $testctr, \@bac_only_A, ".iavglen.pdf", ".iavglen.ps");
    $output = `cat $dir.bacteria.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.iavglen.p\w+/)               { die "ERROR, problem with drawing"; }
    $output = `cat $dir.bacteria.iavglen.drawtab`;
    if($output !~ /insertavglen\s+73\s+1.00\d+\s+0.33\d+\s+3\s+1\s*insertavglen/) { die "ERROR, problem with drawing"; }
    remove_files              (".", "bacteria.iavglen");
    remove_files              (".", "bacteria.ssu-draw");
}
$testctr++;

# Test --dall
if(($testnum eq "") || ($testnum == $testctr)) {
    # without -a
    run_draw                  ($ssudraw, $dir, "--dall --no-aln", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".dall.drawtab");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".sum");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".log");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".dall.pdf", ".dall.ps");
    $output = `cat $dir/$dir.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.dall.p\w+\s+1\s*/) { die "ERROR, problem with drawing"; }
    $output = `cat $dir/$dir.bacteria.dall.drawtab`;
    if($output !~ /deleteall\s+99\s+0.6\d+\s+6\s*deleteall/)     { die "ERROR, problem with drawing"; }
    remove_files              ($dir, "draw");
    remove_files              ($dir, "\.ps");
    remove_files              ($dir, "\.pdf");

    # with -a 
    run_draw                  ($ssudraw, $dir . "/" . $dir . ".bacteria.stk", "--dall --no-aln -a", $testctr);
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".dall.drawtab");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.sum");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.log");
    check_for_one_of_two_files(".", $dir, $testctr, \@bac_only_A, ".dall.pdf", ".dall.ps");
    $output = `cat $dir.bacteria.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.dall.p\w+\s+1\s*/) { die "ERROR, problem with drawing"; }
    $output = `cat $dir.bacteria.dall.drawtab`;
    if($output !~ /deleteall\s+99\s+0.6\d+\s+6\s*deleteall/)     { die "ERROR, problem with drawing"; }
    remove_files              (".", "bacteria.dall");
    remove_files              (".", "bacteria.ssu-draw");
}
$testctr++;

# Test --dint
if(($testnum eq "") || ($testnum == $testctr)) {
    # without -a
    run_draw                  ($ssudraw, $dir, "--dint --no-aln", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".dint.drawtab");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".sum");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".log");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".dint.pdf", ".dint.ps");
    $output = `cat $dir/$dir.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.dint.p\w+\s+1\s*/) { die "ERROR, problem with drawing"; }
    $output = `cat $dir/$dir.bacteria.dint.drawtab`;
    if($output !~ /deleteint\s+99\s+0.2\d+\s+3\s+4\s*deleteint/) { die "ERROR, problem with drawing"; }
    remove_files              ($dir, "draw");
    remove_files              ($dir, "\.ps");
    remove_files              ($dir, "\.pdf");

    # with -a
    run_draw                  ($ssudraw, $dir . "/" . $dir . ".bacteria.stk", "--dint --no-aln -a", $testctr);
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".dint.drawtab");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.sum");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.log");
    check_for_one_of_two_files(".", $dir, $testctr, \@bac_only_A, ".dint.pdf", ".dint.ps");
    $output = `cat $dir.bacteria.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.dint.p\w+\s+1\s*/) { die "ERROR, problem with drawing"; }
    $output = `cat $dir.bacteria.dint.drawtab`;
    if($output !~ /deleteint\s+99\s+0.2\d+\s+3\s+4\s*deleteint/) { die "ERROR, problem with drawing"; }
    remove_files              (".", "bacteria.dint");
    remove_files              (".", "bacteria.ssu-draw");
}
$testctr++;

# Test --span
if(($testnum eq "") || ($testnum == $testctr)) {
    # without -a
    run_draw                  ($ssudraw, $dir, "--span --no-aln", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".span.drawtab");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".sum");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".log");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".span.pdf", ".span.ps");
    $output = `cat $dir/$dir.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.span.p\w+\s+1\s*/) { die "ERROR, problem with drawing"; }
    $output = `cat $dir/$dir.bacteria.span.drawtab`;
    if($output !~ /span\s+1\s+0.4\d+\s+4\s*span/) { die "ERROR, problem with drawing"; }
    remove_files              ($dir, "draw");
    remove_files              ($dir, "\.ps");
    remove_files              ($dir, "\.pdf");

    # with -a
    run_draw                  ($ssudraw, $dir . "/" . $dir . ".bacteria.stk", "--span --no-aln -a", $testctr);
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".span.drawtab");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.sum");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.log");
    check_for_one_of_two_files(".", $dir, $testctr, \@bac_only_A, ".span.pdf", ".span.ps");
    $output = `cat $dir.bacteria.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.span.p\w+/) { die "ERROR, problem with drawing"; }
    $output = `cat $dir.bacteria.span.drawtab`;
    if($output !~ /span\s+1\s+0.4\d+\s+4\s*span/) { die "ERROR, problem with drawing"; }
    remove_files              (".", "bacteria.span");
    remove_files              (".", "bacteria.ssu-draw");
}
$testctr++;

# Test --info
if(($testnum eq "") || ($testnum == $testctr)) {
    # without -a
    run_draw                  ($ssudraw, $dir, "--info --no-aln", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".info.drawtab");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".sum");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".log");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".info.pdf", ".info.ps");
    $output = `cat $dir/$dir.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.info.p\w+\s+1\s*/) { die "ERROR, problem with drawing"; }
    $output = `cat $dir/$dir.bacteria.info.drawtab`;
    if($output !~ /infocontent\s+1\s+2.0\d+\s+2\s+6\s*infocontent/) { die "ERROR, problem with drawing"; }
    remove_files              ($dir, "draw");
    remove_files              ($dir, "\.ps");
    remove_files              ($dir, "\.pdf");

    # with -a
    run_draw                  ($ssudraw, $dir . "/" . $dir . ".bacteria.stk", "--info --no-aln -a", $testctr);
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".info.drawtab");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.sum");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.log");
    check_for_one_of_two_files(".", $dir, $testctr, \@bac_only_A, ".info.pdf", ".info.ps");
    $output = `cat $dir.bacteria.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.info.p\w+\s+1\s*/) { die "ERROR, problem with drawing"; }
    $output = `cat $dir.bacteria.info.drawtab`;
    if($output !~ /infocontent\s+1\s+2.0\d+\s+2\s+6\s*infocontent/) { die "ERROR, problem with drawing"; }
    remove_files              (".", "bacteria.info");
    remove_files              (".", "bacteria.ssu-draw");
}
$testctr++;

# Test --mutinfo
if(($testnum eq "") || ($testnum == $testctr)) {
    # without -a
    run_draw                  ($ssudraw, $dir, "--mutinfo --no-aln", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".mutinfo.drawtab");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".sum");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".log");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".mutinfo.pdf", ".mutinfo.ps");
    $output = `cat $dir/$dir.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.mutinfo.p\w+\s+1\s*/) { die "ERROR, problem with drawing"; }
    $output = `cat $dir/$dir.bacteria.mutinfo.drawtab`;
    if($output !~ /mutualinfo\s+62\s+140\s+246\s+1.18\d+\s+1.18\d+\s+0.40\d+\s+4\s+3\s*mutualinfo/) { die "ERROR, problem with drawing"; }
    remove_files              ($dir, "draw");
    remove_files              ($dir, "\.ps");
    remove_files              ($dir, "\.pdf");

    # with -a
    run_draw                  ($ssudraw, $dir . "/" . $dir . ".bacteria.stk", "--mutinfo --no-aln -a", $testctr);
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".mutinfo.drawtab");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.sum");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.log");
    check_for_one_of_two_files(".", $dir, $testctr, \@bac_only_A, ".mutinfo.pdf", ".mutinfo.ps");
    $output = `cat $dir.bacteria.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.mutinfo.p\w+\s+1\s*/)                                 { die "ERROR, problem with drawing"; }
    $output = `cat $dir.bacteria.mutinfo.drawtab`;
    if($output !~ /mutualinfo\s+62\s+140\s+246\s+1.18\d+\s+1.18\d+\s+0.40\d+\s+4\s+3\s*mutualinfo/) { die "ERROR, problem with drawing"; }
    remove_files              (".", "bacteria.mutinfo");
    remove_files              (".", "bacteria.ssu-draw");
}
$testctr++;

# Test --mutinfo with a mask
if(($testnum eq "") || ($testnum == $testctr)) {
    # first make the required input masks with the maskkey 
    foreach $name (@name_A) {
	$maskfile     = $datadir . "/" . $name . "." . $mask_key_in . ".mask";
	$newmaskfile  = $dir .     "/" . $name . "." . $mask_key_in . ".mask";
	system("cp $maskfile $newmaskfile");
	if ($? != 0) { die "FAIL: cp command failed unexpectedly";}
    }
    # without -a 
    run_draw                  ($ssudraw, $dir, "--mutinfo --no-aln -k $mask_key_in", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".mutinfo.drawtab");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".sum");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".log");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".mutinfo.pdf", ".mutinfo.ps");
    $output = `cat $dir/$dir.ssu-draw.sum`;
    if($output !~ /$dir.archaea.stk\s+$dir.archaea.mutinfo.p\w+\s+1\s*/)    { die "ERROR, problem with drawing"; }
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.mutinfo.p\w+\s+1\s*/)  { die "ERROR, problem with drawing"; }
    if($output !~ /$dir.eukarya.stk\s+$dir.eukarya.mutinfo.p\w+\s+1\s*/)    { die "ERROR, problem with drawing"; }
    $output = `cat $dir/$dir.bacteria.mutinfo.drawtab`;
    if($output !~ /mutualinfo\s+62\s+140\s+246\s+1.18\d+\s+1.18\d+\s+0.40\d+\s+4\s+3\s+0\s+1\s*mutualinfo/) { die "ERROR, problem with drawing"; }
    remove_files              ($dir, "draw");
    remove_files              ($dir, "\.ps");
    remove_files              ($dir, "\.pdf");
    foreach $name (@name_A) {
	$newmaskfile  = $dir . "/" . $name . "." . $mask_key_in . ".mask";
	remove_files(".", $newmaskfile);
    }

    # with -a, need to put mask files in cwd first
    foreach $name (@bac_only_A) {
	$maskfile     = $datadir . "/" . $name . "." . $mask_key_in . ".mask";
	$newmaskfile  = $dir . "." . $name . "." . $mask_key_in . ".mask";
	system("cp $maskfile $newmaskfile");
	if ($? != 0) { die "FAIL: cp command failed unexpectedly";}
    }
    run_draw                  ($ssudraw, $dir . "/" . $dir . ".bacteria.stk", "--mutinfo --no-aln -k $mask_key_in -a", $testctr);
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".mutinfo.drawtab");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.sum");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.log");
    check_for_one_of_two_files(".", $dir, $testctr, \@bac_only_A, ".mutinfo.pdf", ".mutinfo.ps");
    $output = `cat $dir.bacteria.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.mutinfo.p\w+\s+1\s*/)    { die "ERROR, problem with drawing"; }
    $output = `cat $dir.bacteria.mutinfo.drawtab`;
    if($output !~ /mutualinfo\s+62\s+140\s+246\s+1.18\d+\s+1.18\d+\s+0.40\d+\s+4\s+3\s+0\s+1\s*mutualinfo/) { die "ERROR, problem with drawing"; }
    remove_files              (".", "bacteria.mutinfo");
    remove_files              (".", "bacteria.ssu-draw");
    foreach $name (@bac_only_A) {
	$newmaskfile  = $dir . "." . $name . "." . $mask_key_in . ".mask";
	remove_files(".", $newmaskfile);
    }
}
$testctr++;


##################################################################
# Options for drawing structure diagrams for individual sequences:
##################################################################

# Test --indi
if(($testnum eq "") || ($testnum == $testctr)) {
    # without -a
    run_draw                  ($ssudraw, $dir, "--indi --no-aln", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".sum");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".log");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".indi.ps", ".indi.pdf");
    $output = `cat $dir/$dir.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.indi.p\w+\s+10\s*/) { die "ERROR, problem with drawing"; }
    # NOTE: no drawtab file is created, and the postscript is not checked (I could do that, but don't)
    remove_files              ($dir, "draw");
    remove_files              ($dir, "\.ps");
    remove_files              ($dir, "\.pdf");

    # with -a
    run_draw                  ($ssudraw, $dir . "/" . $dir . ".bacteria.stk", "--indi --no-aln -a", $testctr);
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.sum");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.log");
    check_for_one_of_two_files(".", $dir, $testctr, \@bac_only_A, ".indi.pdf", ".indi.ps");
    $output = `cat $dir.bacteria.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.indi.p\w+\s+10\s*/) { die "ERROR, problem with drawing"; }
    # NOTE: no drawtab file is created, and the postscript is not checked (I could do that, but don't)
    remove_files              (".", "bacteria.indi");
    remove_files              (".", "bacteria.ssu-draw");

    # without -a, but with --no-prob
    run_draw                  ($ssudraw, $dir, "--indi --no-aln --no-prob", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".sum");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".log");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".indi.ps", ".indi.pdf");
    $output = `cat $dir/$dir.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.indi.p\w+\s+5/) { die "ERROR, problem with drawing"; }
    # NOTE: no drawtab file is created, and the postscript is not checked (I could do that, but don't)
    remove_files              ($dir, "draw");
    remove_files              ($dir, "\.ps");
    remove_files              ($dir, "\.pdf");
}
$testctr++;

# Test --cons
if(($testnum eq "") || ($testnum == $testctr)) {
    # without -a
    run_draw                  ($ssudraw, $dir, "--cons --no-aln", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".sum");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".log");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".cons.ps", ".cons.pdf");
    $output = `cat $dir/$dir.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.cons.p\w+\s+1\s*/) { die "ERROR, problem with drawing"; }
    # NOTE: no drawtab file is created, and the postscript is not checked (I could do that, but don't)
    remove_files              ($dir, "draw");
    remove_files              ($dir, "\.ps");
    remove_files              ($dir, "\.pdf");

    # with -a
    run_draw                  ($ssudraw, $dir . "/" . $dir . ".bacteria.stk", "--cons --no-aln -a", $testctr);
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.sum");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.log");
    check_for_one_of_two_files(".", $dir, $testctr, \@bac_only_A, ".cons.pdf", ".cons.ps");
    $output = `cat $dir.bacteria.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.cons.p\w+\s+1\s*/) { die "ERROR, problem with drawing"; }
    # NOTE: no drawtab file is created, and the postscript is not checked (I could do that, but don't)
    remove_files              (".", "bacteria.rf");
    remove_files              (".", "bacteria.ssu-draw");
}
$testctr++;

# Test --rf
if(($testnum eq "") || ($testnum == $testctr)) {
    # without -a
    run_draw                  ($ssudraw, $dir, "--rf --no-aln", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".sum");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".log");
    check_for_one_of_two_files($dir, $dir, $testctr, \@name_A, ".rf.ps", ".rf.pdf");
    $output = `cat $dir/$dir.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.rf.p\w+\s+1\s*/) { die "ERROR, problem with drawing"; }
    # NOTE: no drawtab file is created, and the postscript is not checked (I could do that, but don't)
    remove_files              ($dir, "draw");
    remove_files              ($dir, "\.ps");
    remove_files              ($dir, "\.pdf");

    # with -a
    run_draw                  ($ssudraw, $dir . "/" . $dir . ".bacteria.stk", "--rf --no-aln -a", $testctr);
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.sum");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.log");
    check_for_one_of_two_files(".", $dir, $testctr, \@bac_only_A, ".rf.pdf", ".rf.ps");
    $output = `cat $dir.bacteria.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.rf.p\w+\s+1\s*/) { die "ERROR, problem with drawing"; }
    # NOTE: no drawtab file is created, and the postscript is not checked (I could do that, but don't)
    remove_files              (".", "bacteria.rf");
    remove_files              (".", "bacteria.ssu-draw");
}
$testctr++;

#############################################
# Options for omitting parts of the diagrams: 
#############################################

# Test --no-leg
if(($testnum eq "") || ($testnum == $testctr)) {
    # without -a
    run_draw                  ($ssudraw, $dir, "--no-leg --info --no-aln --ps-only", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".info.drawtab");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".sum");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".log");
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".info.ps");
    $output = `cat $dir/$dir.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.info.ps\s+1\s*/) { die "ERROR, problem with drawing"; }
    $output = `cat $dir/$dir.bacteria.info.drawtab`;
    if($output !~ /infocontent\s+1\s+2.0\d+\s+2\s+6\s*infocontent/) { die "ERROR, problem with drawing"; }
    $output = `cat $dir/$dir.archaea.info.ps`;
    if($output =~ /\(LEGEND\)/)                         { die "ERROR, problem with drawing"; }
    if($output !~ /\(information content per position/) { die "ERROR, problem with drawing"; }
    if($output !~ /\(alignment file\:/)                 { die "ERROR, problem with drawing"; }
    remove_files              ($dir, "draw");
    remove_files              ($dir, "\.ps");

    # with -a
    run_draw                  ($ssudraw, $dir . "/" . $dir . ".bacteria.stk", "--no-leg --info --no-aln --ps-only -a", $testctr);
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".info.drawtab");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.sum");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.log");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".info.ps");
    $output = `cat $dir.bacteria.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.info.ps\s+1\s*/) { die "ERROR, problem with drawing"; }
    $output = `cat $dir.bacteria.info.drawtab`;
    if($output !~ /infocontent\s+1\s+2.0\d+\s+2\s+6\s*infocontent/) { die "ERROR, problem with drawing"; }
    $output = `cat $dir.bacteria.info.ps`;
    if($output =~ /\(LEGEND\)/)                         { die "ERROR, problem with drawing"; }
    if($output !~ /\(information content per position/) { die "ERROR, problem with drawing"; }
    if($output !~ /\(alignment file\:/)                 { die "ERROR, problem with drawing"; }
    remove_files              (".", "bacteria.info");
    remove_files              (".", "bacteria.ssu-draw");
}
$testctr++;

# Test --no-head
if(($testnum eq "") || ($testnum == $testctr)) {
    # without -a
    run_draw                  ($ssudraw, $dir, "--no-head --info --no-aln --ps-only", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".info.drawtab");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".sum");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".log");
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".info.ps");
    $output = `cat $dir/$dir.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.info.ps\s+1\s*/) { die "ERROR, problem with drawing"; }
    $output = `cat $dir/$dir.bacteria.info.drawtab`;
    if($output !~ /infocontent\s+1\s+2.0\d+\s+2\s+6\s*infocontent/) { die "ERROR, problem with drawing"; }
    $output = `cat $dir/$dir.archaea.info.ps`;
    if($output !~ /\(LEGEND\)/)                         { die "ERROR, problem with drawing"; }
    if($output =~ /\(information content per position/) { die "ERROR, problem with drawing"; }
    if($output !~ /\(alignment file\:/)                 { die "ERROR, problem with drawing"; }
    remove_files              ($dir, "draw");
    remove_files              ($dir, "\.ps");

    # with -a
    run_draw                  ($ssudraw, $dir . "/" . $dir . ".bacteria.stk", "--no-head --info --no-aln --ps-only -a", $testctr);
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".info.drawtab");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.sum");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.log");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".info.ps");
    $output = `cat $dir.bacteria.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.info.ps\s+1\s*/) { die "ERROR, problem with drawing"; }
    $output = `cat $dir.bacteria.info.drawtab`;
    if($output !~ /infocontent\s+1\s+2.0\d+\s+2\s+6\s*infocontent/) { die "ERROR, problem with drawing"; }
    $output = `cat $dir.bacteria.info.ps`;
    if($output !~ /\(LEGEND\)/)                         { die "ERROR, problem with drawing"; }
    if($output =~ /\(information content per position/) { die "ERROR, problem with drawing"; }
    if($output !~ /\(alignment file\:/)                 { die "ERROR, problem with drawing"; }
    remove_files              (".", "bacteria.info");
    remove_files              (".", "bacteria.ssu-draw");
}
$testctr++;

# Test --no-foot
if(($testnum eq "") || ($testnum == $testctr)) {
    # without -a
    run_draw                  ($ssudraw, $dir, "--no-foot --info --no-aln --ps-only", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".info.drawtab");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".sum");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".log");
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".info.ps");
    $output = `cat $dir/$dir.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.info.ps\s+1\s*/) { die "ERROR, problem with drawing"; }
    $output = `cat $dir/$dir.bacteria.info.drawtab`;
    if($output !~ /infocontent\s+1\s+2.0\d+\s+2\s+6\s*infocontent/) { die "ERROR, problem with drawing"; }
    $output = `cat $dir/$dir.archaea.info.ps`;
    if($output !~ /\(LEGEND\)/)                         { die "ERROR, problem with drawing"; }
    if($output !~ /\(information content per position/) { die "ERROR, problem with drawing"; }
    if($output =~ /\(alignment file\:/)                 { die "ERROR, problem with drawing"; }
    remove_files              ($dir, "draw");
    remove_files              ($dir, "\.ps");

    # with -a
    run_draw                  ($ssudraw, $dir . "/" . $dir . ".bacteria.stk", "--no-foot --info --no-aln --ps-only -a", $testctr);
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".info.drawtab");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.sum");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.log");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".info.ps");
    $output = `cat $dir.bacteria.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.info.ps\s+1\s*/) { die "ERROR, problem with drawing"; }
    $output = `cat $dir.bacteria.info.drawtab`;
    if($output !~ /infocontent\s+1\s+2.0\d+\s+2\s+6\s*infocontent/) { die "ERROR, problem with drawing"; }
    $output = `cat $dir.bacteria.info.ps`;
    if($output !~ /\(LEGEND\)/)                         { die "ERROR, problem with drawing"; }
    if($output !~ /\(information content per position/) { die "ERROR, problem with drawing"; }
    if($output =~ /\(alignment file\:/)                 { die "ERROR, problem with drawing"; }
    remove_files              (".", "bacteria.info");
    remove_files              (".", "bacteria.ssu-draw");
}
$testctr++;

# Test combination of --no-leg no-head and --no-foot
if(($testnum eq "") || ($testnum == $testctr)) {
    # without -a
    run_draw                  ($ssudraw, $dir, "--no-leg --no-head --no-foot --info --no-aln --ps-only", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".info.drawtab");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".sum");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".log");
    check_for_files           ($dir, $dir, $testctr, \@name_A, ".info.ps");
    $output = `cat $dir/$dir.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.info.ps\s+1\s*/) { die "ERROR, problem with drawing"; }
    $output = `cat $dir/$dir.bacteria.info.drawtab`;
    if($output !~ /infocontent\s+1\s+2.0\d+\s+2\s+6\s*infocontent/) { die "ERROR, problem with drawing"; }
    $output = `cat $dir/$dir.archaea.info.ps`;
    if($output =~ /\(LEGEND\)/)                         { die "ERROR, problem with drawing"; }
    if($output =~ /\(information content per position/) { die "ERROR, problem with drawing"; }
    if($output =~ /\(alignment file\:/)                 { die "ERROR, problem with drawing"; }
    remove_files              ($dir, "draw");
    remove_files              ($dir, "\.ps");

    # with -a
    run_draw                  ($ssudraw, $dir . "/" . $dir . ".bacteria.stk", "--no-leg --no-head --no-foot --info --no-aln --ps-only -a", $testctr);
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".info.drawtab");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.sum");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".ssu-draw.log");
    check_for_files           (".", $dir, $testctr, \@bac_only_A, ".info.ps");
    $output = `cat $dir.bacteria.ssu-draw.sum`;
    if($output !~ /$dir.bacteria.stk\s+$dir.bacteria.info.ps\s+1\s*/) { die "ERROR, problem with drawing"; }
    $output = `cat $dir.bacteria.info.drawtab`;
    if($output !~ /infocontent\s+1\s+2.0\d+\s+2\s+6\s*infocontent/) { die "ERROR, problem with drawing"; }
    $output = `cat $dir.bacteria.info.ps`;
    if($output =~ /\(LEGEND\)/)                         { die "ERROR, problem with drawing"; }
    if($output =~ /\(information content per position/) { die "ERROR, problem with drawing"; }
    if($output =~ /\(alignment file\:/)                 { die "ERROR, problem with drawing"; }
    remove_files              (".", "bacteria.info");
    remove_files              (".", "bacteria.ssu-draw");
    remove_files              (".", "bacteria.pdf");
    remove_files              (".", "bacteria.ps");
}
$testctr++;

####################################
# Test the special -m and -t options
####################################
# Note: the build parts of these tests are identical to those found in other test scripts: ssu-align-merge-prep.itest.pl, ssu-mask.itest.pl
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

    # draw alignments with -t $trna_psfile
    # without -a
    run_draw($ssudraw, $dir, "-t $trna_psfile -m $trna_cmfile", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@trna_only_A, ".drawtab");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".sum");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".log");
    check_for_one_of_two_files($dir, $dir, $testctr, \@trna_only_A, ".ps", ".pdf");
    $output = `cat $dir/$dir.ssu-draw.sum`;
    if($output !~ /$dir.trna-5.stk\s+$dir.trna-5.p\w+/)              { die "ERROR, problem with drawing"; }
    $output = `cat $dir/$dir.trna-5.drawtab`;
    if($output !~ /infocontent\s+1\s+1.00\d+\s+4\s+3\s*infocontent/) { die "ERROR, problem with drawing"; }
    if($output !~ /span\s+1\s+1.00\d+\s+1\s*span/)                   { die "ERROR, problem with drawing"; }
    remove_files              ($dir, "draw");
    remove_files              ($dir, "\.ps");
    remove_files              ($dir, "\.pdf");

    # mask alignments with -t $trna_psfile
    # again, without -a
    run_mask($ssumask, $dir, "-t $trna_psfile -m $trna_cmfile", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@trna_only_A, ".mask");
    check_for_files           ($dir, $dir, $testctr, \@trna_only_A, ".mask.stk");
    check_for_one_of_two_files($dir, $dir, $testctr, \@trna_only_A, ".mask.ps", ".mask.pdf");
    $output = `cat $dir/$dir.ssu-mask.sum`;
    if($output !~ /$dir.trna-5.mask\s+output\s+mask\s+71\s+68\s+3/) { die "ERROR, problem with masking";}

    # now draw again, should see same output files, but now the diagrams will have masks
    run_draw($ssudraw, $dir, "-t $trna_psfile -m $trna_cmfile", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@trna_only_A, ".drawtab");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".sum");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".log");
    check_for_one_of_two_files($dir, $dir, $testctr, \@trna_only_A, ".ps", ".pdf");
    $output = `cat $dir/$dir.ssu-draw.sum`;
    if($output !~ /$dir.trna-5.stk\s+$dir.trna-5.p\w+/)              { die "ERROR, problem with drawing"; }
    $output = `cat $dir/$dir.trna-5.drawtab`;
    if($output !~ /infocontent\s+1\s+1.00\d+\s+4\s+3\s+1\s*infocontent/) { die "ERROR, problem with drawing"; }
    if($output !~ /span\s+1\s+1.00\d+\s+1\s+1\s*span/)                   { die "ERROR, problem with drawing"; }
    remove_files              ($dir, "draw");
    remove_files              ($dir, "\.ps");
    remove_files              ($dir, "\.pdf");

    # remove mask files
    remove_files($dir, "mask");

    # now repeat the same thing but not with -a
    # draw alignments with -t $trna_psfile
    run_draw($ssudraw, $dir . "/" . $dir . ".trna-5.stk", "-t $trna_psfile -m $trna_cmfile -a", $testctr);
    check_for_files           (".", $dir, $testctr, \@trna_only_A, ".drawtab");
    check_for_files           (".", $dir, $testctr, \@trna_only_A, ".ssu-draw.sum");
    check_for_files           (".", $dir, $testctr, \@trna_only_A, ".ssu-draw.log");
    check_for_one_of_two_files(".", $dir, $testctr, \@trna_only_A, ".ps", ".pdf");
    $output = `cat $dir.trna-5.ssu-draw.sum`;
    if($output !~ /$dir.trna-5.stk\s+$dir.trna-5.p\w+/)              { die "ERROR, problem with drawing"; }
    $output = `cat $dir.trna-5.drawtab`;
    if($output !~ /infocontent\s+1\s+1.00\d+\s+4\s+3\s*infocontent/) { die "ERROR, problem with drawing"; }
    if($output !~ /span\s+1\s+1.00\d+\s+1\s*span/)                   { die "ERROR, problem with drawing"; }
    remove_files              (".", "trna-5.draw");
    remove_files              (".", "trna-5.ps");
    remove_files              (".", "trna-5.pdf");

    # mask alignments with -t $trna_psfile
    # again, now with -a
    run_mask($ssumask, $dir . "/" . $dir . ".trna-5.stk", "-a -t $trna_psfile -m $trna_cmfile", $testctr);
    check_for_files(".", $dir, $testctr, \@trna_only_A, ".mask");
    check_for_files(".", $dir, $testctr, \@trna_only_A, ".mask.stk");
    $output = `cat $dir.trna-5.ssu-mask.sum`;
    if($output !~ /$dir.trna-5.mask\s+output\s+mask\s+71\s+68\s+3/) { die "ERROR, problem with masking";}

    # now draw again, should see same output files, but now the diagrams will have masks
    run_draw($ssudraw, $dir . "/" . $dir . ".trna-5.stk", "-t $trna_psfile -m $trna_cmfile -a", $testctr);
    check_for_files           (".", $dir, $testctr, \@trna_only_A, ".drawtab");
    check_for_files           (".", $dir, $testctr, \@trna_only_A, ".ssu-draw.sum");
    check_for_files           (".", $dir, $testctr, \@trna_only_A, ".ssu-draw.log");
    check_for_one_of_two_files(".", $dir, $testctr, \@trna_only_A, ".ps", ".pdf");
    $output = `cat $dir.trna-5.ssu-draw.sum`;
    if($output !~ /$dir.trna-5.stk\s+$dir.trna-5.p\w+/)              { die "ERROR, problem with drawing"; }
    $output = `cat $dir.trna-5.drawtab`;
    if($output !~ /infocontent\s+1\s+1.00\d+\s+4\s+3\s+1\s*infocontent/) { die "ERROR, problem with drawing"; }
    if($output !~ /span\s+1\s+1.00\d+\s+1\s+1\s*span/)                   { die "ERROR, problem with drawing"; }
    remove_files              (".", "trna-5.draw");
    remove_files              (".", "trna-5.ps");
    remove_files              (".", "trna-5.pdf");

    # now remove mask files
    remove_files(".", "trna-5.mask");
    remove_files(".", "trna-5.ssu-mask");
    remove_files(".", "trna-5.ssu-draw");
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
