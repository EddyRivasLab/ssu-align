#! /usr/bin/perl
#
# Integrated test of the ssu-build script.
#
# Usage:     ./ssu-build.itest.1.pl <directory with all 5 SSU-ALIGN scripts> <data directory with fasta files etc.> <tmpfile and tmpdir prefix> <test number to perform, if blank do all tests>
# Examples:  ./ssu-build.itest.pl ../src/ data/ foo   (do all tests)
#            ./ssu-build.itest.pl ../src/ data/ foo 4 (do only test 4)
#
# EPN, Fri Mar  5 08:33:29 2010

$usage = "perl ssu-build.itest.pl\n\t<directory with all 5 SSU-ALIGN scripts>\n\t<data directory with fasta files etc.>\n\t<tmpfile and tmpdir prefix>\n\t<test number to perform, if blank, do all tests>\n";
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

if (! -e "$ssualign") { die "FAIL: didn't find ssu-align script $ssualign"; }
if (! -e "$ssubuild") { die "FAIL: didn't find ssu-build script $ssubuild"; }
if (! -e "$ssudraw")  { die "FAIL: didn't find ssu-draw script $ssudraw"; }
if (! -e "$ssumask")  { die "FAIL: didn't find ssu-mask script $ssumask"; }
if (! -e "$ssumerge") { die "FAIL: didn't find ssu-merge script $ssumerge"; }
if (! -x "$ssualign") { die "FAIL: ssu-align script $ssualign is not executable"; }
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
$key_out = "181";
$df_suffix = "-0p1-sb";

if (! -e "$fafile")       { die "FAIL: didn't find fasta file $fafile in data dir $datadir"; }
if (! -e "$trna_stkfile") { die "FAIL: didn't find file $trna_stkfile in data dir $datadir"; }
if (! -e "$trna_fafile")  { die "FAIL: didn't find file $trna_fafile in data dir $datadir"; }
if (! -e "$trna_psfile")  { die "FAIL: didn't find file $trna_psfile in data dir $datadir"; }
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
    run_build($ssubuild, "", "-h", $testctr);
    if ($? != 0) { die "FAIL: ssu-build -h failed unexpectedly"; }
}
$testctr++;

# Test default (no options) building of archaeal model from $dir (we just created above from $fafile) 
if(($testnum eq "") || ($testnum == $testctr)) {
    run_build($ssubuild, $dir . "/" . $dir . ".archaea.stk", "-f", $testctr);
    if(! -e ("$dir.archaea.cm"))            { die "ERROR, problem with building" }
    if(! -e ("$dir.archaea.ssu-build.log")) { die "ERROR, problem with building" }
    if(! -e ("$dir.archaea.ssu-build.sum")) { die "ERROR, problem with building" }
    $output = `cat $dir.archaea.ssu-build.sum`;
    if($output !~ /$dir.archaea.cm\s+$dir.archaea-1\s+5.+1493/) { die "ERROR, problem with building" }
    $output = `cat $dir.archaea.cm`;
    if($output !~ /BCOM.+\-\-enone/) { die "ERROR, problem with building" }
    remove_files(".", "$dir.archaea.ssu-build");
    remove_files(".", "$dir.archaea.cm");
}    
$testctr++;

# Test default (no options) on multi-stk file
if(($testnum eq "") || ($testnum == $testctr)) {
    $key = "three";
    system("cat " . $dir . "/" . $dir . ".bacteria.stk > $dir.$key.stk");
    system("cat " . $dir . "/" . $dir . ".archaea.stk >> $dir.$key.stk");
    system("cat " . $dir . "/" . $dir . ".eukarya.stk >> $dir.$key.stk");

    run_build($ssubuild, $dir . ".$key.stk", "-f", $testctr);
    if(! -e ("$dir.$key.cm"))            { die "ERROR, problem with building" }
    if(! -e ("$dir.$key.ssu-build.log")) { die "ERROR, problem with building" }
    if(! -e ("$dir.$key.ssu-build.sum")) { die "ERROR, problem with building" }
    $output = `cat $dir.$key.ssu-build.sum`;
    if($output !~ /$dir.$key.cm\s+$dir.$key-1\s+5.+1588/) { die "ERROR, problem with building" }
    if($output !~ /$dir.$key.cm\s+$dir.$key-2\s+5.+1493/) { die "ERROR, problem with building" }
    if($output !~ /$dir.$key.cm\s+$dir.$key-3\s+5.+1990/) { die "ERROR, problem with building" }
    remove_files(".", "$dir.$key.ssu-build");
    remove_files(".", "$dir.$key.stk");
    remove_files(".", "$dir.$key.cm");
}    
$testctr++;

# Test -d 
if(($testnum eq "") || ($testnum == $testctr)) {
    run_build($ssubuild, "eukarya", "-f -d", $testctr);
    if(! -e ("eukarya" . $df_suffix . ".cm"))            { die "ERROR, problem with building" }
    if(! -e ("eukarya" . $df_suffix . ".ssu-build.log")) { die "ERROR, problem with building" }
    if(! -e ("eukarya" . $df_suffix . ".ssu-build.sum")) { die "ERROR, problem with building" }
    $output = `cat eukarya$df_suffix.ssu-build.sum`;
    if($output !~ /eukarya$df_suffix.cm\s+eukarya$df_suffix.+1881/) { die "ERROR, problem with building" }
    remove_files(".", "eukarya" . $df_suffix . ".ssu-build");
    remove_files(".", "eukarya" . $df_suffix . ".cm");
}    
$testctr++;

# Test -o 
if(($testnum eq "") || ($testnum == $testctr)) {
    $my_cm_file_name = "my-arc-model";
    run_build($ssubuild, $dir . "/" . $dir . ".archaea.stk", "-f --rf -o $my_cm_file_name", $testctr);
    if(! -e ("my-arc-model"))                  { die "ERROR, problem with building" }
    if(! -e ($dir . ".archaea.ssu-build.sum")) { die "ERROR, problem with building" }
    if(! -e ($dir . ".archaea.ssu-build.log")) { die "ERROR, problem with building" }
    $output = `cat $dir.archaea.ssu-build.sum`;
    if($output !~ /my-arc-model.+1508\s+/) { die "ERROR, problem with building" }
    remove_files(".", "$dir.archaea.ssu-build");
    remove_files(".", $my_cm_file_name);
}
$testctr++;

# Test -n 
if(($testnum eq "") || ($testnum == $testctr)) {
    $my_cm_name = "my-archy";
    run_build($ssubuild, $dir . "/" . $dir . ".archaea.stk", "-f --rf -n $my_cm_name", $testctr);
    if(! -e ($dir . ".archaea.cm"))              { die "ERROR, problem with building" }
    if(! -e ($dir . ".archaea.ssu-build.sum")) { die "ERROR, problem with building" }
    if(! -e ($dir . ".archaea.ssu-build.log")) { die "ERROR, problem with building" }
    $output = `cat $dir.archaea.ssu-build.sum`;
    if($output !~ /$my_cm_name.+1508\s+/) { die "ERROR, problem with building" }
    remove_files(".", "$dir.archaea.ssu-build");
    remove_files(".", "$dir.archaea.cm");
}
$testctr++;

# Test --append 
if(($testnum eq "") || ($testnum == $testctr)) {
    $my_cm_file_name = "appendtest.cm";
    run_build($ssubuild, $dir . "/" . $dir . ".archaea.stk",  "-f --rf -o $my_cm_file_name", $testctr);
    run_build($ssubuild, $dir . "/" . $dir . ".eukarya.stk",  "-f --rf --append $my_cm_file_name", $testctr);
    if(! -e ($my_cm_file_name))                { die "ERROR, problem with building" }
    if(! -e ($dir . ".archaea.ssu-build.sum")) { die "ERROR, problem with building" }
    if(! -e ($dir . ".archaea.ssu-build.log")) { die "ERROR, problem with building" }
    if(! -e ($dir . ".eukarya.ssu-build.sum")) { die "ERROR, problem with building" }
    if(! -e ($dir . ".eukarya.ssu-build.log")) { die "ERROR, problem with building" }
    $output = `cat $my_cm_file_name`;
    if($output !~ /NAME\s+$dir.archaea-1/) { die "ERROR, problem with building" }
    if($output !~ /NAME\s+$dir.eukarya-1/) { die "ERROR, problem with building" }
    remove_files(".", "$dir.archaea.ssu-build");
    remove_files(".", "$dir.eukarya.ssu-build");
    remove_files(".", "$my_cm_file_name");
}
$testctr++;

# Test --key-out
if(($testnum eq "") || ($testnum == $testctr)) {
    $key_out = "181";
    run_build($ssubuild, $dir . "/" . $dir . ".archaea.stk", "-f --key-out $key_out", $testctr);
    if(! -e ("$dir.archaea.$key_out.cm"))            { die "ERROR, problem with building" }
    if(! -e ("$dir.archaea.$key_out.ssu-build.log")) { die "ERROR, problem with building" }
    if(! -e ("$dir.archaea.$key_out.ssu-build.sum")) { die "ERROR, problem with building" }
    $output = `cat $dir.archaea.$key_out.ssu-build.sum`;
    if($output !~ /$dir.archaea.$key_out.cm\s+$dir.archaea-1\s+5.+1493/) { die "ERROR, problem with building" }
    remove_files(".", "$dir.archaea.$key_out.ssu-build");
    remove_files(".", "$dir.archaea.$key_out.cm");

    # with -d
    run_build($ssubuild, "bacteria", "-f -d --key-out $key_out", $testctr);
    if(! -e ("bacteria" . $df_suffix . "." . $key_out . ".cm"))            { die "ERROR, problem with building" }
    if(! -e ("bacteria" . $df_suffix . "." . $key_out . ".ssu-build.log")) { die "ERROR, problem with building" }
    if(! -e ("bacteria" . $df_suffix . "." . $key_out . ".ssu-build.sum")) { die "ERROR, problem with building" }
    $output = `cat bacteria$df_suffix.$key_out.ssu-build.sum`;
    if($output !~ /bacteria$df_suffix.$key_out.cm\s+bacteria$df_suffix.+1582/) { die "ERROR, problem with building" }
    remove_files(".", "bacteria" . $df_suffix . "." . $key_out . ".ssu-build");
    remove_files(".", "bacteria" . $df_suffix . "." . $key_out . ".cm");

    # with --trunc
    $trunc_opt = "525-765";
    run_build($ssubuild, $dir . "/" . $dir . ".archaea.stk", "-f --trunc $trunc_opt --key-out $key_out", $testctr);
    if(! -e ("$dir.archaea.$trunc_opt.$key_out.cm"))            { die "ERROR, problem with building" }
    if(! -e ("$dir.archaea.$trunc_opt.$key_out.ssu-build.log")) { die "ERROR, problem with building" }
    if(! -e ("$dir.archaea.$trunc_opt.$key_out.ssu-build.sum")) { die "ERROR, problem with building" }
    $output = `cat $dir.archaea.$trunc_opt.$key_out.ssu-build.sum`;
    if($output !~ /$dir.archaea.$trunc_opt.$key_out.cm\s+$dir.archaea.$trunc_opt\s+5.+241/) { die "ERROR, problem with building" }
    remove_files(".", "$dir.archaea.$trunc_opt.$key_out.ssu-build");
    remove_files(".", "$dir.archaea.$trunc_opt.$key_out.stk");
    remove_files(".", "$dir.archaea.$trunc_opt.$key_out.cm");
}
$testctr++;

########################################################################
# Option for building a model from a truncated version of the alignment:
########################################################################

# Test --trunc
if(($testnum eq "") || ($testnum == $testctr)) {
    $trunc_opt = "584-824";
    run_build($ssubuild, $dir . "/" . $dir . ".bacteria.stk", "-f --trunc $trunc_opt", $testctr);
    if(! -e ("$dir.bacteria.$trunc_opt.stk"))           { die "ERROR, problem with building" }
    if(! -e ("$dir.bacteria.$trunc_opt.cm"))            { die "ERROR, problem with building" }
    if(! -e ("$dir.bacteria.$trunc_opt.ssu-build.log")) { die "ERROR, problem with building" }
    if(! -e ("$dir.bacteria.$trunc_opt.ssu-build.sum")) { die "ERROR, problem with building" }
    $output = `cat $dir.bacteria.$trunc_opt.ssu-build.sum`;
    if($output !~ /$dir.bacteria.$trunc_opt.cm\s+$dir.bacteria.$trunc_opt\s+5.+241/) { die "ERROR, problem with building" }
    remove_files(".", "$dir.bacteria.$trunc_opt.ssu-build");
    remove_files(".", "$dir.bacteria.$trunc_opt.cm");
    remove_files(".", "$dir.bacteria.$trunc_opt.stk");

    # with -d
    run_build($ssubuild, "bacteria", "-d -f --trunc $trunc_opt", $testctr);
    if(! -e ("bacteria$df_suffix.$trunc_opt.stk"))           { die "ERROR, problem with building" }
    if(! -e ("bacteria$df_suffix.$trunc_opt.mask"))          { die "ERROR, problem with building" }
    if(! -e ("bacteria$df_suffix.$trunc_opt.cm"))            { die "ERROR, problem with building" }
    if((! -e ("bacteria$df_suffix.$trunc_opt.pdf")) && 
       (! -e ("bacteria$df_suffix.$trunc_opt.ps")))          { die "ERROR, problem with building" }
    if(! -e ("bacteria$df_suffix.$trunc_opt.ssu-build.log")) { die "ERROR, problem with building" }
    if(! -e ("bacteria$df_suffix.$trunc_opt.ssu-build.sum")) { die "ERROR, problem with building" }
    $output = `cat bacteria$df_suffix.$trunc_opt.ssu-build.sum`;
    if($output !~ /bacteria$df_suffix.$trunc_opt.cm\s+bacteria$df_suffix.$trunc_opt\s+93.+241/) { die "ERROR, problem with building" }
    remove_files(".", "bacteria$df_suffix.$trunc_opt.ssu-build");
    remove_files(".", "bacteria$df_suffix.$trunc_opt.cm");
    remove_files(".", "bacteria$df_suffix.$trunc_opt.stk");
    remove_files(".", "bacteria$df_suffix.$trunc_opt.pdf");
    remove_files(".", "bacteria$df_suffix.$trunc_opt.ps");
}
$testctr++;

#############################################################################
# Options for numbering alignment consensus columns (no model will be built):
#############################################################################
# Test --num and -i
if(($testnum eq "") || ($testnum == $testctr)) {
    # without -d and without -i
    run_build($ssubuild, $dir . "/" . $dir . ".archaea.stk", "-f --num", $testctr);
    if(! -e ("$dir.archaea.num.stk"))       { die "ERROR, problem with building" }
    if(! -e ("$dir.archaea.ssu-build.log")) { die "ERROR, problem with building" }
    if(! -e ("$dir.archaea.ssu-build.sum")) { die "ERROR, problem with building" }
    $output = `cat $dir.archaea.ssu-build.sum`;
    if($output !~ /$dir.archaea.num.stk/) { die "ERROR, problem with building" }
    $output = `cat $dir.archaea.num.stk`;
    if($output !~ /\#=GC\s+RFCOL/) { die "ERROR, problem with building" }
    remove_files(".", "$dir.archaea.ssu-build");
    remove_files(".", "$dir.archaea.num.stk");

    # without -d and with -i
    run_build($ssubuild, $dir . "/" . $dir . ".archaea.stk", "-f --num -i", $testctr);
    if(! -e ("$dir.archaea.num.stk"))       { die "ERROR, problem with building" }
    if(! -e ("$dir.archaea.ssu-build.log")) { die "ERROR, problem with building" }
    if(! -e ("$dir.archaea.ssu-build.sum")) { die "ERROR, problem with building" }
    $output = `cat $dir.archaea.ssu-build.sum`;
    if($output !~ /$dir.archaea.num.stk/) { die "ERROR, problem with building" }
    $output = `cat $dir.archaea.num.stk`;
    if($output !~ /\#=GC\s+RFCOL/) { die "ERROR, problem with building" }
    remove_files(".", "$dir.archaea.ssu-build");
    remove_files(".", "$dir.archaea.num.stk");

    # with -d 
    run_build($ssubuild, "archaea", "-f -d --num", $testctr);
    if(! -e ("archaea$df_suffix.num.stk"))       { die "ERROR, problem with building" }
    if(! -e ("archaea$df_suffix.ssu-build.log")) { die "ERROR, problem with building" }
    if(! -e ("archaea$df_suffix.ssu-build.sum")) { die "ERROR, problem with building" }
    $output = `cat archaea$df_suffix.ssu-build.sum`;
    if($output !~ /archaea$df_suffix.num.stk/) { die "ERROR, problem with building" }
    $output = `cat archaea$df_suffix.num.stk`;
    if($output !~ /\#=GC\s+RFCOL/) { die "ERROR, problem with building" }
    remove_files(".", "archaea$df_suffix.ssu-build");
    remove_files(".", "archaea$df_suffix.num.stk");
}    
$testctr++;

#########################################
# Options for defining consensus columns:
#########################################
# Test --rf (default with -d, not default without it)
if(($testnum eq "") || ($testnum == $testctr)) {
    run_build($ssubuild, $dir . "/" . $dir . ".archaea.stk", "--rf -f", $testctr);
    if(! -e ("$dir.archaea.cm"))            { die "ERROR, problem with building" }
    if(! -e ("$dir.archaea.ssu-build.log")) { die "ERROR, problem with building" }
    if(! -e ("$dir.archaea.ssu-build.sum")) { die "ERROR, problem with building" }
    $output = `cat $dir.archaea.ssu-build.sum`;
    if($output !~ /$dir.archaea.cm\s+$dir.archaea-1\s+5.+1508/) { die "ERROR, problem with building" }
    remove_files(".", "$dir.archaea.ssu-build");
    remove_files(".", "$dir.archaea.cm");
}
$testctr++;

# Test --gapthresh (default without -d, not default with -d)
if(($testnum eq "") || ($testnum == $testctr)) {
    run_build($ssubuild, "archaea", "--gapthresh 0.5 -d -f", $testctr);
    if(! -e ("archaea" . $df_suffix . ".cm"))            { die "ERROR, problem with building" }
    if(! -e ("archaea" . $df_suffix . ".ssu-build.log")) { die "ERROR, problem with building" }
    if(! -e ("archaea" . $df_suffix . ".ssu-build.sum")) { die "ERROR, problem with building" }
    $output = `cat archaea$df_suffix.ssu-build.sum`;
    if($output !~ /archaea$df_suffix.cm\s+archaea$df_suffix.+1477/) { die "ERROR, problem with building" }
    remove_files(".", "archaea" . $df_suffix . ".ssu-build");
    remove_files(".", "archaea" . $df_suffix . ".cm");
}
$testctr++;

########################################
# Expert options for model construction:
########################################
# Test --eent
if(($testnum eq "") || ($testnum == $testctr)) {
    run_build($ssubuild, $dir . "/" . $dir . ".archaea.stk",  "--eent -f", $testctr);
    if(! -e ("$dir.archaea.cm"))            { die "ERROR, problem with building" }
    if(! -e ("$dir.archaea.ssu-build.log")) { die "ERROR, problem with building" }
    if(! -e ("$dir.archaea.ssu-build.sum")) { die "ERROR, problem with building" }
    $output = `cat $dir.archaea.ssu-build.sum`;
    if($output !~ /$dir.archaea.cm\s+$dir.archaea-1\s+5.+1493/) { die "ERROR, problem with building" }
    $output = `cat $dir.archaea.cm`;
    if($output =~ /BCOM.+\-\-enone/) { die "ERROR, problem with building" }
    remove_files(".", "$dir.archaea.ssu-build");
    remove_files(".", "$dir.archaea.cm");
}
$testctr++;

# Test --ere
if(($testnum eq "") || ($testnum == $testctr)) {
    run_build($ssubuild, $dir . "/" . $dir . ".archaea.stk",  "--eent --ere 1.0 -f", $testctr);
    if(! -e ("$dir.archaea.cm"))            { die "ERROR, problem with building" }
    if(! -e ("$dir.archaea.ssu-build.log")) { die "ERROR, problem with building" }
    if(! -e ("$dir.archaea.ssu-build.sum")) { die "ERROR, problem with building" }
    $output = `cat $dir.archaea.ssu-build.sum`;
    if($output !~ /$dir.archaea.cm\s+$dir.archaea-1\s+5.+1493/) { die "ERROR, problem with building" }
    $output = `cat $dir.archaea.cm`;
    if($output !~ /BCOM.+\-\-ere\s+1\.0/) { die "ERROR, problem with building" }
    remove_files(".", "$dir.archaea.ssu-build");
    remove_files(".", "$dir.archaea.cm");
}
$testctr++;

############################################################################
# options for output of structure diagram, only relevant with -d and --trunc 
############################################################################
# I don't test --ps2pdf because any test of it would not be portable

# Test --ps-only
if(($testnum eq "") || ($testnum == $testctr)) {
    run_build($ssubuild, "bacteria", "--ps-only -d -f --trunc $trunc_opt", $testctr);
    if(! -e ("bacteria$df_suffix.$trunc_opt.stk"))           { die "ERROR, problem with building" }
    if(! -e ("bacteria$df_suffix.$trunc_opt.cm"))            { die "ERROR, problem with building" }
    if(! -e ("bacteria$df_suffix.$trunc_opt.ps"))            { die "ERROR, problem with building" }
    if(! -e ("bacteria$df_suffix.$trunc_opt.ssu-build.log")) { die "ERROR, problem with building" }
    if(! -e ("bacteria$df_suffix.$trunc_opt.ssu-build.sum")) { die "ERROR, problem with building" }
    $output = `cat bacteria$df_suffix.$trunc_opt.ssu-build.sum`;
    if($output !~ /bacteria$df_suffix.$trunc_opt.cm\s+bacteria$df_suffix.$trunc_opt\s+93.+241/) { die "ERROR, problem with building" }
    remove_files(".", "bacteria$df_suffix.$trunc_opt.ssu-build");
    remove_files(".", "bacteria$df_suffix.$trunc_opt.cm");
    remove_files(".", "bacteria$df_suffix.$trunc_opt.stk");
    remove_files(".", "bacteria$df_suffix.$trunc_opt.pdf");
    remove_files(".", "bacteria$df_suffix.$trunc_opt.ps");
}

####################################################################
# A few final tests of the full build -> align -> mask -> draw cycle
####################################################################

# Test -o and -n and do a full align, mask, draw cycle
if(($testnum eq "") || ($testnum == $testctr)) {
    $my_cm_file_name = "my-arc-model";
    $my_cm   = "my-archy";
    run_build($ssubuild, $dir . "/" . $dir . ".archaea.stk", "-f --rf -o $my_cm_file_name -n $my_cm", $testctr);
    if(! -e ("my-arc-model"))                  { die "ERROR, problem with building" }
    if(! -e ($dir . ".archaea.ssu-build.sum")) { die "ERROR, problem with building" }
    if(! -e ($dir . ".archaea.ssu-build.log")) { die "ERROR, problem with building" }
    $output = `cat $dir.archaea.ssu-build.sum`;
    if($output !~ /my-arc-model.+1508\s+/) { die "ERROR, problem with building" }
    remove_files(".", "$dir.archaea.ssu-build");

    # this file does not have '.cm' at the end, test to make sure ssu-align, ssu-mask and ssu-draw all work
    run_align($ssualign, $fafile, $dir, "-m $my_cm_file_name -f", $testctr);
    @my_cm_file_name_only_A = ("my-archy");
    check_for_files($dir, $dir, $testctr, \@my_cm_file_name_only_A, ".hitlist");
    check_for_files($dir, $dir, $testctr, \@my_cm_file_name_only_A, ".fa");
    check_for_files($dir, $dir, $testctr, \@my_cm_file_name_only_A, ".stk");
    check_for_files($dir, $dir, $testctr, \@my_cm_file_name_only_A, ".ifile");
    check_for_files($dir, $dir, $testctr, \@my_cm_file_name_only_A, ".cmalign");

    run_mask($ssumask, $dir, "-m $my_cm_file_name -s archaea-0p1.mask", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@my_cm_file_name_only_A, ".mask.stk");
    check_for_one_of_two_files($dir, $dir, $testctr, \@my_cm_file_name_only_A, ".mask.pdf", "mask.ps");
    $output = `cat $dir/$dir.ssu-mask.sum`;
    if($output !~ /$dir.$my_cm.mask.stk+\s+output\s+aln+\s+1376\s+\-\s+\-/)     { die "ERROR, problem with creating mask diagram"; }
    remove_files              ($dir, "mask");

    run_draw($ssudraw, $dir, "-m $my_cm_file_name -s archaea-0p1.mask", $testctr);
    check_for_files           ($dir, $dir, $testctr, \@my_cm_file_name_only_A, ".drawtab");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".sum");
    check_for_files           ($dir, $dir, $testctr, \@ssudraw_only_A, ".log");
    check_for_one_of_two_files($dir, $dir, $testctr, \@my_cm_file_name_only_A, ".pdf", ".ps");
    $output = `cat $dir/$dir.ssu-draw.sum`;
    if($output !~ /$dir.$my_cm.stk\s+$dir.$my_cm.p\w+/)                 { die "ERROR, problem with drawing"; }
    $output = `cat $dir/$dir.$my_cm.drawtab`;
    if($output !~ /infocontent\s+1\s+2.\d+\s+3\s+6\s+1\s*infocontent/)  { die "ERROR, problem with drawing"; }
    if($output !~ /span\s+1\s+0.2\d+\s+3\s+1\s*span/)                   { die "ERROR, problem with drawing"; } 
    $output = `cat $dir/$dir.ssu-draw.log`;
    if($output !~ /Executing\:\s+ssu-esl-ssdraw.+\-\-mask/) { die "ERROR, problem with drawing"; } 
    remove_files              ($dir, "draw");
    remove_files              ($dir, "\.ps");
    remove_files              ($dir, "\.pdf");
    remove_files(".", $my_cm_file_name);
}    
$testctr++;

if(($testnum eq "") || ($testnum == $testctr)) {
    # first, build new v4.cm with 3 v4 CMs
    run_build($ssubuild, "archaea", "-f -d --trunc 525-765  -n arc-v4 -o       v4.cm", $testctr);
    check_for_files           (".", "", $testctr, \@arc_only_A, "-0p1-sb.525-765.stk");
    check_for_files           (".", "", $testctr, \@arc_only_A, "-0p1-sb.525-765.mask");
    check_for_one_of_two_files(".", "", $testctr, \@arc_only_A, "-0p1-sb.525-765.ps", "-0p1-sb.525-765.pdf");
    remove_files              (".", "0p1-sb.525-765");

    run_build($ssubuild, "bacteria", "-f -d --trunc 584-824  -n bac-v4 --append v4.cm", $testctr);
    check_for_files           (".", "", $testctr, \@bac_only_A, "-0p1-sb.584-824.stk");
    check_for_files           (".", "", $testctr, \@bac_only_A, "-0p1-sb.584-824.mask");
    check_for_one_of_two_files(".", "", $testctr, \@bac_only_A, "-0p1-sb.584-824.ps", "-0p1-sb.584-824.pdf");
    remove_files              (".", "0p1-sb.584-824");

    run_build($ssubuild, "eukarya", "-f -d --trunc 620-1082 -n euk-v4 --append v4.cm", $testctr);
    check_for_files           (".", "", $testctr, \@euk_only_A, "-0p1-sb.620-1082.stk");
    check_for_files           (".", "", $testctr, \@euk_only_A, "-0p1-sb.620-1082.mask");
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


####################################
# Test the special -m and -t options
####################################
# Note: the build parts of these tests are identical to those found in other test scripts: ssu-align.itest.pl, ssu-mask.itest.pl
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

