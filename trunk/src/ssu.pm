#!/usr/bin/perl
#
# ssu.pm
# Eric Nawrocki
# EPN, Thu Nov  5 05:39:37 2009
#
# Perl module used by SSU-ALIGN v0.1 perl scripts. This module
# contains subroutines called by > 1 of the SSU-ALIGN perl scripts:
# ssu-align, ssu-build, ssu-draw, ssu-mask, ssu-merge, ssu-prep.
#
# List of subroutines in this file:
#
# GetGlobals():                      fill a hash with global variables, called by all SSU-ALIGN scripts
# PrintBanner():                     prints SSU-ALIGN banner given a script description.
# PrintConclusion():                 prints final lines of SSU-ALIGN script output
# PrintTiming():                     prints run time to stdout and summary file.
# PrintStringToFile():               prints string to a file and optionally stdout.
# RunCommand():                      runs an executable using system(), prints output to log file
# ActuallyRunCommand():              runs an executable using system()
# ValidateRequiredExecutable():      validate that a required executable can be executed by user
# TempFilename():                    create a name for a temporary file
# UnlinkFile():                      unlinks a file, and updates log file.
# UnlinkDir():                       removes an empty directory, and updates log file.
# DetermineNumSeqsFasta():           determine the number of sequences in a FASTA file.
# DetermineNumSeqsStockholm():       determine the number of sequences in a Stockholm aln file.
# MaxArray():                        determine the maximum value scalar in an array
# ArgmaxArray():                     determine the index of the max value scalar in an array
# MaxLengthScalarInArray():          determine the max length scalar in an array.
# SumArrayElements():                return sum of values in a numeric array
# SumHashElements():                 return sum of values in a numeric hash 
# TryPs2Pdf():                       attempt to run 'ps2pdf' to convert ps to pdf file.
# SwapOrAppendFileSuffix():          given a file name, return a new name with a suffix swapped.
# RemoveDirPath():                   remove the leading directory path of a filename
# ReturnDirPath():                   return the leading directory path of a filename
# UseModuleIfItExists():             use 'use()' to use a module, if it exists on the system
# SecondsSinceEpoch():               return number of seconds since the epoch 
# FileOpenFailure():                 called if an open() call fails, print error msg and exit
# PrintErrorAndExit():               print an error message and call exit to kill the program
# PrintSearchAndAlignStatistics():   print ssu-align summary statistics on search and alignment
# NumberOfDigits():                  determine number of digits before decimal point in a number
# FindPossiblySharedFile():          given a file, determine if that file exists in cwd or $ENV(SSUALIGNDIR)
# SeqstatSeqFilePerSeq():            get per-sequence statistics on a sequence file using 'esl-seqstat'
# InitializeSsuAlignOptions():       initialize ssu-align options in 'ssu-align' and 'ssu-prep'        
# CheckSsuAlignOptions():            check for incompatible ssu-align options in 'ssu-align' and 'ssu-prep'        
# ValidateAndSetupSsuAlignOrPrep():  validate that 'ssu-align' or 'ssu-prep' can run 
# CreateSsuAlignOutputDir():         create the master output directory for 'ssu-align' or 'ssu-prep'
# AppendSsuAlignOptionsUsage():      append usage strings for options common to 'ssu-align' and 'ssu-prep'

use strict;
use warnings;

#####################################################################
# Subroutine: GetGlobals()
# Incept:     EPN, Wed Nov 18 08:45:53 2009
# 
# Purpose:    Define global variables in a hash that is passed in
#             by reference. This is called early on all SSU-ALIGN 
#             scripts
# 
#             It is possible to change these definitions to suit
#             one's on local environment. But only do so if you
#             know what you're doing.
#
# Arguments: 
#    $globals_HR:       reference to the hash to fill with global variables
#    $ssualigndir:      where the library files (CM file, template file) are 
#                       determined prior to entering this subroutine by 
#                       $ENV{"SSUALIGNDIR"} by the caller.
#
# Returns:    Nothing.
# 
####################################################################
sub GetGlobals { 
    my $narg_expected = 2;
    if(scalar(@_) != $narg_expected) { printf STDERR ("ERROR, GetGlobals() entered with %d != %d input arguments.\n", scalar(@_), $narg_expected); exit(1); } 
    my ($globals_HR, $ssualigndir) = @_;

    # default values, files and parameters
    $globals_HR->{"VERSION"}                 = "0.1";                                  # original value: "0.1"
    $globals_HR->{"VERSION_PSTR"}            = "0p1";                                  # original value: "0p1"
    $globals_HR->{"DF_CM_FILE"}              = $ssualigndir . "/ssu-align-0p1.cm";     # original value: $ssualigndir . "/ssu-align-0p1.cm"
    $globals_HR->{"DF_TEMPLATE_FILE"}        = $ssualigndir . "/ssu-align-0p1.ps";     # original value: $ssualigndir . "/ssu-align-0p1.ps"
    $globals_HR->{"DF_MASK_FILE"}            = $ssualigndir . "/ssu-align-0p1.mask";   # original value: $ssualigndir . "/ssu-align-0p1.mask"
    $globals_HR->{"DF_MINBIT"}               = 50;                                     # original value: "50"
    $globals_HR->{"DF_MINLEN"}               = 1;                                      # original value: "1"
    $globals_HR->{"DF_MXSIZE"}               = 4096;                                   # original value: "4096"
    $globals_HR->{"DF_CMSEARCH_T"}           = -1;                                     # original value: "-1"
    $globals_HR->{"DF_CMBUILD_GAPTHRESH"}    = 0.80;                                   # original value: 0.80
    $globals_HR->{"DF_NO_NAME"}              = "<NONE>";                               # original value: <NONE>
    $globals_HR->{"DF_CMSEARCH_OPTS"}        = " --hmm-cW 1.5 --no-null3 --noalign ";  # original value: " --hmm-cW 1.5 --no-null3 --noalign "
    $globals_HR->{"DF_CMSEARCH_ALG_FLAG"}    = " --viterbi";                           # original value: " --viterbi"
    $globals_HR->{"DF_CMALIGN_OPTS"}         = " --no-null3 --sub ";                   # original value: " --no-null3 --sub"
    $globals_HR->{"DF_ALIMASK_PFRACT"}       = 0.95;                                   # original value: 0.95
    $globals_HR->{"DF_ALIMASK_PTHRESH"}      = 0.95;                                   # original value: 0.95
    $globals_HR->{"DF_MERGE_INIT_WAIT_SECS"} = 3;                                      # original value: 3

    # executable programs
    $globals_HR->{"cmalign"}      = "ssu-cmalign";                              # original value: "ssu-cmalign"
    $globals_HR->{"cmbuild"}      = "ssu-cmbuild";                              # original value: "ssu-cmbuild"
    $globals_HR->{"cmsearch"}     = "ssu-cmsearch";                             # original value: "ssu-cmsearch"
    $globals_HR->{"esl-alimanip"} = "ssu-esl-alimanip";                         # original value: "ssu-esl-alimanip"
    $globals_HR->{"esl-alimask"}  = "ssu-esl-alimask";                          # original value: "ssu-esl-alimask"
    $globals_HR->{"esl-alimerge"} = "ssu-esl-alimerge";                         # original value: "ssu-esl-alimerge"
    $globals_HR->{"esl-alistat"}  = "ssu-esl-alistat";                          # original value: "ssu-esl-alistat"
    $globals_HR->{"esl-reformat"} = "ssu-esl-reformat";                         # original value: "ssu-esl-reformat"
    $globals_HR->{"esl-seqstat"}  = "ssu-esl-seqstat";                          # original value: "ssu-esl-seqstat"
    $globals_HR->{"esl-sfetch"}   = "ssu-esl-sfetch";                           # original value: "ssu-esl-sfetch"
    $globals_HR->{"esl-ssdraw"}   = "ssu-esl-ssdraw";                           # original value: "ssu-esl-ssdraw"
    $globals_HR->{"esl-weight"}   = "ssu-esl-weight";                           # original value: "ssu-esl-weight"
    $globals_HR->{"ps2pdf"}       = "ps2pdf";                                   # original value: "ps2pdf"
    $globals_HR->{"ssu-align"}    = "ssu-align";                                # original value: "ssu-align"
    $globals_HR->{"ssu-merge"}    = "ssu-merge";                                # original value: "ssu-merge"

    return;
}


#####################################################################
# Subroutine: PrintGlobalsToFile()
# Incept:     EPN, Wed Nov 18 10:09:45 2009
# 
# Purpose:    Print global variables to a file, usually a log file.
#
# Arguments: 
#    $globals_HR:       reference to the hash of global variables
#    $out_file:         file to append list of global variables to
#
# Returns:    Nothing.
# 
####################################################################
sub PrintGlobalsToFile { 
    my $narg_expected = 2;
    if(scalar(@_) != $narg_expected) { printf STDERR ("ERROR, PrintGlobalsToFile() entered with %d != %d input arguments.\n", scalar(@_), $narg_expected); exit(1); } 
    my ($globals_HR, $out_file) = @_;

    my @sorted_keys = sort (keys(%{$globals_HR}));
    my $key;
    PrintStringToFile($out_file, 0, "\n");
    PrintStringToFile($out_file, 0, "Printing global hask key as read from ssu.pm:\n");
    PrintStringToFile($out_file, 0, "\n");
    foreach $key (@sorted_keys) { 
	PrintStringToFile($out_file, 0, sprintf("Global hash key: %-20s value: %s\n", $key, $globals_HR->{$key}));
    }
    PrintStringToFile($out_file, 0, "\n");

    return;
}


#####################################################################
# Subroutine: PrintBanner()
# Incept:     EPN, Thu Sep 24 14:40:39 2009
# 
# Purpose:    Print the ssu-* banner.
#
# Arguments: 
#    $script_call:       command used to invoke this script
#    $script_desc:       short description of script, printed to stdout
#    $date:              date to print
#    $opt_HR:            REFERENCE to hash of command-line options
#    $opt_takes_arg_HR:  REFERENCE to hash telling if each option takes an argument (1) or not (0)
#    $opt_order_AR:      REFERENCE to array specifying order of options
#    $argv_R:            REFERENCE to @ARGV, command-line arguments
#    $print_to_stdout:   '1' to print to stdout, '0' not to
#    $enabled_options_R: RETURN: a string of all enabled options
#    $out_file:          file to print to, "" for not any file
#
# Returns:    Nothing, if it returns, everything is valid.
# 
####################################################################
sub PrintBanner { 
    my $narg_expected = 10;
    if(scalar(@_) != $narg_expected) { printf STDERR ("ERROR, PrintBanner() entered with %d != %d input arguments.\n", scalar(@_), $narg_expected); exit(1); } 
    my ($script_call, $script_desc, $date, $opt_HR, $opt_takes_arg_HR, $opt_order_AR, $argv_R, $print_to_stdout, $enabled_options_R, $out_file) = @_;

    my ($i, $script_name, $start_log_line, $opt);
    $script_call =~ s/^\.+\///;
    $script_name = $script_call;
    $script_name =~ s/.+\///;
    my $enabled_options = "";
    foreach $opt (@{$opt_order_AR}) { 
	if($opt_takes_arg_HR->{$opt}) { if($opt_HR->{$opt} ne "") { $enabled_options .= " " . $opt . " " . $opt_HR->{$opt}; } }
	else                  	      { if($opt_HR->{$opt})       { $enabled_options .= " " . $opt; } }
    }

    PrintStringToFile($out_file, $print_to_stdout, sprintf("\# $script_name :: $script_desc\n"));
    PrintStringToFile($out_file, $print_to_stdout, sprintf("\# SSU-ALIGN 0.1 (May 2010)\n"));
    PrintStringToFile($out_file, $print_to_stdout, sprintf("\# Copyright (C) 2010 HHMI Janelia Farm Research Campus\n"));
    PrintStringToFile($out_file, $print_to_stdout, sprintf("\# Freely distributed under the GNU General Public License (GPLv3)\n"));
    PrintStringToFile($out_file, $print_to_stdout, sprintf("\# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\n"));
    PrintStringToFile($out_file, $print_to_stdout, sprintf("%-10s %s ", "# command:", $script_name . $enabled_options));
#    PrintStringToFile($out_file, $print_to_stdout, sprintf("%-10s %s ", "# command:", $script_call . $enabled_options));
    for($i = 0; $i < (scalar(@{$argv_R}) - 1); $i++) { 
	PrintStringToFile($out_file, $print_to_stdout, sprintf("%s ", $argv_R->[$i]));
    }
    if(scalar(@{$argv_R}) > 0) { 
	PrintStringToFile($out_file, $print_to_stdout, sprintf("%s\n", $argv_R->[(scalar(@{$argv_R})-1)])); 
    }
    else { 
	PrintStringToFile($out_file, $print_to_stdout, sprintf("\n"));
    }
    PrintStringToFile($out_file, $print_to_stdout, sprintf("%-10s ", "# date:"));
    PrintStringToFile($out_file, $print_to_stdout, sprintf($date));
    PrintStringToFile($out_file, $print_to_stdout, sprintf("\n"));

    $$enabled_options_R = $enabled_options;
    return;
}


#######################################################################
# Subroutine: PrintConclusion()
# Incept:     EPN, Thu Nov  5 18:25:31 2009
# 
# Purpose:    Print the final few lines of output and optionally the 
#             run time timing to the summary file. Print date and
#             system information to the log file.
#
# Arguments: 
#    $sum_file:               full path to summary file
#    $log_file:               full path to log file
#    $sum_file2print:         name of summary file
#    $log_file2print:         name of log file
#    $total_time:             total number of seconds, "" to not print timing
#    $time_hires_installed:   '1' if Time:HiRes is installed (we'll print milliseconds)
#    $out_dir:                output directory where output files were put,
#                             "" if it is current dir. '-1' to not print notice about
#                             which directory files were created in.
#    $globals_HR:             REFERENCE to the globals hash
#
# Returns:    Nothing.
# 
####################################################################
sub PrintConclusion { 
    my $narg_expected = 8;
    if(scalar(@_) != $narg_expected) { printf STDERR ("ERROR, PrintConclusion() entered with %d != %d input arguments.\n", scalar(@_), $narg_expected); exit(1); } 
    my ($sum_file, $log_file, $sum_file2print, $log_file2print, $total_time, $time_hires_installed, $out_dir, $globals_HR) = @_;

    PrintStringToFile($sum_file, 1, sprintf("#\n"));
    #PrintStringToFile($sum_file, 1, sprintf("# Commands executed by this script written to log file:  $log_file2print.\n"));
    #PrintStringToFile($sum_file, 1, sprintf("# This output printed to screen written to summary file: $sum_file2print.\n"));
    PrintStringToFile($sum_file, 1, sprintf("# List of executed commands saved in:     $log_file2print.\n"));
    PrintStringToFile($sum_file, 1, sprintf("# Output printed to the screen saved in:  $sum_file2print.\n"));
    PrintStringToFile($sum_file, 1, sprintf("#\n"));
    if($out_dir eq "") { 
	PrintStringToFile($sum_file, 1, sprintf("# All output files created in the current working directory.\n"));
	PrintStringToFile($sum_file, 1, sprintf("#\n"));
    }
    elsif($out_dir ne -1) { 
	PrintStringToFile($sum_file, 1, sprintf("# All output files created in directory \.\/%s\/\n", $out_dir));
	PrintStringToFile($sum_file, 1, sprintf("#\n"));
    }
    if($total_time ne "") { # don't print this if ssu-align is caller
	PrintTiming("# CPU time: ", $total_time, $time_hires_installed, 1, $sum_file); 
	PrintStringToFile($sum_file, 1, sprintf("#            hh:mm:ss\n"));
	PrintStringToFile($sum_file, 1, sprintf("# \n"));
	PrintStringToFile($sum_file, 0, "# SSU-ALIGN-SUCCESS\n");
    }
    PrintStringToFile($log_file, 0, `date`);
    PrintStringToFile($log_file, 0, `uname -a`);
    if($total_time ne "") { # don't print this if ssu-align is caller
	PrintStringToFile($log_file, 0, "# SSU-ALIGN-SUCCESS\n");
    }
    return;
}


#####################################################################
# Subroutine: PrintTiming()
# Incept:     EPN, Tue Jun 16 08:52:08 2009
# 
# Purpose:    Print a timing in hhhh:mm:ss format to 1 second precision.
# 
# Arguments:
# $prefix:                 string to print before the hhhh:mm:ss time info.
# $inseconds:              number of seconds
# $time_hires_installed: '1' if Time:HiRes is installed (we'll print milliseconds)
# $print_to_stdout:        '1' to print to stdout, '0' not to
# $sum_file:               file to print output file notices to
#
# Returns:    Nothing, if it returns, everything is valid.
# 
####################################################################
sub PrintTiming { 
    my $narg_expected = 5;
    if(scalar(@_) != $narg_expected) { printf STDERR ("ERROR, print_timing() entered with %d != %d input arguments.\n", scalar(@_), $narg_expected); exit(1); } 
    my ($prefix, $inseconds, $time_hires_installed, $print_to_stdout, $sum_file) = @_;
    my ($i, $hours, $minutes, $seconds, $thours, $tminutes, $tseconds, $ndig_hours);

    $hours = int($inseconds / 3600);
    $inseconds -= ($hours * 3600);
    $minutes = int($inseconds / 60);
    $inseconds -= ($minutes * 60);
    $seconds = $inseconds;
    $thours   = sprintf("%02d", $hours);
    $tminutes = sprintf("%02d", $minutes);
    $ndig_hours = NumberOfDigits($hours);
    if($ndig_hours < 2) { $ndig_hours = 2; }

    if($time_hires_installed) { 
	$tseconds = sprintf("%05.2f", $seconds);
	PrintStringToFile($sum_file, $print_to_stdout, sprintf("%s %*s:%2s:%5s\n", $prefix, $ndig_hours, $thours, $tminutes, $tseconds));
    }
    else { 
	$tseconds = sprintf("%02d", $seconds);
	PrintStringToFile($sum_file, $print_to_stdout, sprintf("%s %*s:%2s:%2s\n", $prefix, $ndig_hours, $thours, $tminutes, $tseconds));
    }
}


###########################################################
# Subroutine: PrintStringToFile()
# Incept: EPN, Thu Oct 29 10:47:25 2009
#
# Purpose: Given a string and a file name, append the 
#          string to the file, and potentially to stdout
#          as well. If $filename is the empty string,
#          don't print to a file. 
#
# Returns: Nothing. If the file can't be written to 
#          an error message is printed and the program
#          exits.
#
###########################################################
sub PrintStringToFile {
    my $narg_expected = 3;
    if(scalar(@_) != $narg_expected) { printf STDERR ("ERROR, PrintStringToFile() entered with %d != %d input arguments.\n", scalar(@_), $narg_expected); exit(1); } 
    my ($filename, $print_to_stdout, $string) = @_;

    if($filename ne "") { 
	open(OUT, ">>" . $filename) || die "ERROR, PrintStringToFile() couldn't open $filename for appending.\n";
	printf OUT $string;
	close(OUT);
    }

    if($print_to_stdout) { printf($string); }
    return;
}


###########################################################
# Subroutine: RunCommand
# Incept: EPN, Fri Oct 30 06:05:37 2009
#
# Purpose: Run a command using the system() command.
#          Command is actually executed using ActuallyRunCommand(),
#          code wrapping that call is complex. Its purpose is
#          to capture the output and stderr of the command 
#          in temporary files and regurgitate that output/stderr
#          if the command fails.
#
#          A new file is created temporarily for the command's
#          standard error output (STDERR). An additional temp
#          file is created for the command's standard output
#          (STDOUT) unless the command is already handling that.
#
#          Unless <$cmd> includes redirection to an output file 
#          set by caller, we print STDOUT output to $log_file.
#          STDERR output is always printed to $log_file.
#
#          If the command fails (returns non-zero exit status),
#          we print <$errmsg> to STDERR and to <$log_file>.
#          If <$die_if_fails> == 1 we then
#          die, or if not, we set <$returned_zero_R> to 0 
#          and return. If <$errmsg> is "", we use a generic
#          one.
#  
#          Temp files created here are removed using Perl's
#          unlink function, but only if we got a zero exit 
#          status.
#
#          If <$cmd> matches /\s+2\s*\>\s*\&\s*1/ (2>&1) to
#          redirect stderr and output to same place, we 
#          die in error. Caller shouldn't do that.
#
# Arguments:
#   $cmd:                       command to execute
#   $key:                       string to add to temp file names
#   $die_if_fails:              '1' to die if command returns non-zero status
#   $print_output_upon_failure: '1' to print command output to STDERR if it fails
#   $sum_file:                  sum file to print error to (if nec)
#   $log_file:                  log file to print command and output to
#   $returned_zero_R:           set to '1' if command works (returns 0), else set to '0'         
#   $errmsg:                    message to print if command returns non-0 exit status
#                               and $die_if_fails==1, if this is "", print generic error.
# Returns: Nothing.
#
###########################################################
sub RunCommand {
    my $narg_expected = 8;
    if(scalar(@_) != $narg_expected) { printf STDERR ("ERROR, RunCommand() entered with %d != %d input arguments.\n", scalar(@_), $narg_expected); exit(1); } 
    my ($cmd, $key, $die_if_fails, $print_output_upon_failure, $sum_file, $log_file, $returned_zero_R, $errmsg) = @_;

    my $have_tmp_stdout = 0;
    my ($stdout_file, $tmp_stderr_file, $line, $returned_zero, $status, $retval);

    # contract check, $log_file must not be the empty string
    if($log_file eq "") { PrintErrorAndExit("ERROR, in RunCommand with empty log file.", $sum_file, $log_file, 1); }
    # contract check, if caller had stderr and output redirected, we die, caller shouldn't do that.
    if($cmd =~ /\s+2\s*>\s*&\s*1/) { PrintErrorAndExit("ERROR, in RunCommand with illegal substring that matches \"2\>\&1\".", $sum_file, $log_file, 1); }

    # replace multi-spaces due to blank options from caller with single spaces, solely so $log_file output doesn't contain odd looking commands
    $cmd =~ s/\s+/ /g;

    if($cmd !~ />/) { 
	# add stdout redirection
	$stdout_file = TempFilename($sum_file, $log_file, $key . "out");
	$have_tmp_stdout = 1;
	$cmd = "$cmd > $stdout_file"
    }
    elsif($cmd =~ m/\>\s*(\S+)\s*$/) { 
	$stdout_file = $1;
    }
    else { 
	PrintErrorAndExit("ERROR, in RunCommand command: $cmd has output redirection, but unable to parse its output file.", $sum_file, $log_file, 1); 
    }
    $tmp_stderr_file = TempFilename($sum_file, $log_file, $key . "err");
    
    # add stderr redirection
    $cmd  = "$cmd  2> $tmp_stderr_file";

    PrintStringToFile($log_file, 0, ("Executing:      " . $cmd . "\n"));
    ActuallyRunCommand($cmd, \$retval);
    PrintStringToFile($log_file, 0, ("Returned:       " . $retval . "\n"));

    # get output from $stdout_file and $tmp_stderr_file
    my $stdout2print = "";
    if(($retval != 0) || ($have_tmp_stdout)) { # we'll print stdout to log file
	if($stdout_file ne "/dev/null") { 
	    if(-e $stdout_file) { 
		if(open(IN, $stdout_file)) { 
		    while($line = <IN>) { $stdout2print .= $line; }
		    close(IN);
		}
		else { $stdout2print = "***UNEXPECTEDLY, THE FILE DOES NOT EXIST***"; }
	    }
	    else { $stdout2print = "***UNEXPECTEDLY, THE FILE DOES NOT EXIST***"; }
	}
	if($stdout2print eq "") { $stdout2print = "***NONE***"; }
	else                    { $stdout2print = "\n" . $stdout2print; }
    }
    my $stderr2print = "";
    if(-e $tmp_stderr_file) { 
	if(open(IN, $tmp_stderr_file)) { 
	    while($line = <IN>) { $stderr2print .= $line; }
	    close(IN);
	}
	else { $stderr2print = "***UNEXPECTEDLY, THE FILE DOES NOT EXIST***"; }
    }
    else { $stderr2print = "***UNEXPECTEDLY, THE FILE DOES NOT EXIST***"; }
    if($stderr2print eq "") { $stderr2print = "***NONE***"; }
    else                    { $stderr2print = "\n" . $stderr2print; }

    my ($stdout_file_message, $stderr_file_message);
    if($stdout_file eq "/dev/null") { $stdout_file_message = "sent to /dev/null"; }
    else                            { $stdout_file_message = "saved in file $stdout_file"; }
    $stderr_file_message = "saved in file $tmp_stderr_file.";

    if($retval != 0) { 
	if($errmsg eq "") { $errmsg = "ERROR, the command \(\"$cmd\"\) unexpectedly returned non-zero exit status: $retval."; }
	if($die_if_fails) { 
	    PrintStringToFile($log_file, 0, "FATAL: Failed command: $cmd\n"); 
	    PrintStringToFile($log_file, 0, ("Output (STDOUT) ($stdout_file_message): " . $stdout2print . "\n"));
	    PrintStringToFile($log_file, 0, ("Output (STDERR) ($stderr_file_message): " . $stderr2print . "\n"));
	}
	else { 
	    PrintStringToFile($log_file, 0, ("Output (STDOUT): " . $stdout2print . "\n"));
	    PrintStringToFile($log_file, 0, ("Output (STDERR): " . $stderr2print . "\n"));
	}
	PrintStringToFile($log_file, 0, ("\n$errmsg\n"));
	if($print_output_upon_failure) { 
	    if($die_if_fails) { printf STDERR ("FATAL: Failed command: $cmd\n"); }
	    printf STDERR ("Output (STDOUT):" . $stdout2print . "\n");
	    printf STDERR ("Output (STDERR):" . $stderr2print . "\n");
	}
	if($die_if_fails) { exit(1); }
	$returned_zero = 0;
    }
    else { # $retval == 0
	if(! $have_tmp_stdout) { PrintStringToFile($log_file, 0, ("Output (STDOUT) $stdout_file_message.\n")); }
	else                   { PrintStringToFile($log_file, 0, ("Output (STDOUT): " . $stdout2print . "\n")); }
	PrintStringToFile($log_file, 0, ("Output (STDERR): " . $stderr2print . "\n\n"));
	$returned_zero = 1;
    }

    # unlink temporary files we created here
    if($have_tmp_stdout) { 
	if(-e $stdout_file) { UnlinkFile($stdout_file, $log_file); }
    }
    if(-e $tmp_stderr_file) { UnlinkFile($tmp_stderr_file, $log_file); }
    
    $$returned_zero_R = $returned_zero;
    return;
}


###########################################################
# Subroutine: ActuallyRunCommand
# Incept: EPN, Tue Mar 23 06:22:56 2010
#
# Purpose: Run a command using the system() command and return
#          the return value in $retval_R.
#
# Arguments:
#   $cmd:                       command to execute with system()
#   $retval_R:                  RETURN: return value of $cmd
#
# Returns: Nothing (except fills $retval_R).
#
###########################################################
sub ActuallyRunCommand {
    my $narg_expected = 2;
    if(scalar(@_) != $narg_expected) { printf STDERR ("ERROR, RunCommand() entered with %d != %d input arguments.\n", scalar(@_), $narg_expected); exit(1); } 
    my ($cmd, $retval_R) = @_;

    my ($status, $retval);

    system "$cmd";

    $status = $?;
    if   (($status&255) != 0) { $retval = $status&255; }
    elsif(($status>>8)  != 0) { $retval = $status>>8;  }
    else                      { $retval = 0; }
    
    $$retval_R = $retval;
    return;
}


###########################################################
# Subroutine: ValidateRequiredExecutable()
# Incept: EPN, Wed Apr 14 09:04:42 2010
#
# Purpose: Validate a required executable exists by trying to 
#          execute it and making sure it returned 0 exit status.
#
# Arguments:
#   $x:        name of executable
#   $key:      keyword for naming tmp output files
#   $options:  string of options to supply to executable when testing
#   $sum_file: the summary file (to print error to, if nec)
#   $log_file: the log file (to print error to, if nec)
# 
# Returns: Nothing. Dies if "$x $options" returns non-0 
#          exit status.
#
###########################################################
sub ValidateRequiredExecutable {
    my $narg_expected = 5;
    if(scalar(@_) != $narg_expected) { printf STDERR ("ERROR, RunCommand() entered with %d != %d input arguments.\n", scalar(@_), $narg_expected); exit(1); } 
    my ($x, $key, $options, $sum_file, $log_file) = @_;

    my $command_worked;
    # Execute the command, this will die if it fails
    RunCommand("$x $options > /dev/null", $key, 
	       1, # die_if_fails, '1' == TRUE, die if we fail
	       1, # print_output_upon_failure, '1' == TRUE, print it
	       $sum_file, $log_file, 
	       \$command_worked, # this is not used, we'll die if the command fails
	       "ERROR, the required executable $x is not in your PATH environment\nvariable or can't run on this system. See the User's Guide Installation section.");
    return;
}

###########################################################
# Subroutine: TempFilename()
# Incept: EPN, Thu Nov 19 13:19:16 2009
#         Based on Sean Eddy's tempname()
#         from his sqc script from Easel.
#
# Purpose: Return a unique temporary filename.
#
#          Sean's (modified) notes:
#          Uses the pid as part of the temp name to prevent other
#          processes from clashing. A two-letter code is also added,
#          so a given process can request up to 676 temp file names
#          (26*26). An "ssutmp" code is also added to distinguish
#          these temp files from those made by other programs.
#          Temporary files are always created in cwd.
#
#          Additionally, a (hopefully unique) string "$key"
#          that gets passed in is included in the file name after
#          "ssutmp" as an additional safeguard against creating 
#          two file with identical names. 
#      
#          Temp file will be put in the same directory
#          that $sum_file exists in.
# 
# Arguments:
# $sum_file: summary file to print error to if we can't open the
#            file, "" if none;
# $log_file: log file to print error to if we can't open the
#            file, "" if none;
# $key:      added to temp file name, to possibly make it 
#            even more unique
#
# Returns: Temporary file name. Nothing if unable to get a
#          name. Prints error message to $sum_file and
#          $log_file exits if it can't create the temp file.
#
###########################################################
sub TempFilename {
    my $narg_expected = 3;
    if(scalar(@_) != $narg_expected) { printf STDERR ("ERROR, TempFilename() entered with %d != %d input arguments.\n", scalar(@_), $narg_expected); exit(1); } 
    my ($sum_file, $log_file, $key) = @_;

    my ($name, $suffix, $out_dir);

    if($sum_file !~ m/\//) { 
	$out_dir = ""; 
    }
    else { 
	$out_dir = $sum_file;
	$out_dir =~ s/\/.+$/\//; # replace final '/' plus file name with full dir path and final '/'
    }

    foreach $suffix ("aa".."zz") {
        $name = $out_dir . "ssutmp".$key.$suffix.$$;
        if (! (-e $name)) { 
            open (TMP,">$name") || FileOpenFailure($name, $sum_file, 1, "writing");
            close(TMP);
            return "$name"; 
        }
    }
    # if we get here we couldn't open any tmp file, exit
    PrintErrorAndExit("ERROR, unable to create temporary file, 26*26=676 already exist!.", $sum_file, $log_file, 1);
}


###########################################################
# Subroutine: UnlinkFile()
# Incept: EPN, Wed Nov  4 18:19:29 2009
#
# Purpose: Unlink (remove) a file. Print info to log file 
#          saying it's been unlinked. 
#
# Returns: Nothing. If the file can't be unlinked, we die.
#
###########################################################
sub UnlinkFile {
    my $narg_expected = 2;
    if(scalar(@_) != $narg_expected) { printf STDERR ("ERROR, UnlinkFile() entered with %d != %d input arguments.\n", scalar(@_), $narg_expected); exit(1); } 
    my ($file, $log_file) = @_;

    PrintStringToFile($log_file, 0, ("About to remove file ($file) with perl's unlink function ... "));
    if(! -e $file) { 
	PrintStringToFile($log_file, 0, ("(doesn't exist!).\n\n"));
	return;
    }
    if(! unlink($file)) { 
	PrintStringToFile($log_file, 0, ("ERROR, couldn't unlink it."));
	# EPN, Thu Jan 21 10:59:06 2010 Decided not to die in this case.
	# die "\nERROR, couldn't remove file $file with unlink function.\n";
    }
    PrintStringToFile($log_file, 0, ("done.\n\n"));
    
    return;
}


###########################################################
# Subroutine: UnlinkDir()
# Incept: EPN, Fri Nov 27 17:55:41 2009
#
# Purpose: Remove an empty directory.
#
# Returns: '1' if the directory was removed. 
#          '0' if it was not (possibly b/c it
#          is not empty).
#
###########################################################
sub UnlinkDir {
    my $narg_expected = 2;
    if(scalar(@_) != $narg_expected) { printf STDERR ("ERROR, UnlinkDir() entered with %d != %d input arguments.\n", scalar(@_), $narg_expected); exit(1); } 
    my ($dir, $log_file) = @_;

    if($log_file ne "") { PrintStringToFile($log_file, 0, ("About to remove presumed empty directory ($dir) with perl's rmdir function ... ")); }
    if(! rmdir($dir)) { 
	if($log_file ne "") { PrintStringToFile($log_file, 0, ("ERROR, couldn't remove it (it may not be empty).\n")); }
	return 0;
    }
    # if we get here it was removed 
    if($log_file ne "") { PrintStringToFile($log_file, 0, ("done.\n\n")); }
    return 1;
}


#####################################################################
# Subroutine: DetermineNumSeqsFasta()
# Incept:     EPN, Mon Nov  3 15:18:52 2008
# 
# Purpose:    Count the number of sequences in the fasta file 
#             <$fasta_file>.
#
# Arguments: 
# $fasta_file: the target sequence file (FASTA format)
#
# 
# Returns:    Number of sequences in FASTA file <$fasta_file>. 
#             -1 if first non-whitespace character is not a '>',
#             in this case <$fasta_file> is not legal FASTA.
# 
####################################################################
sub DetermineNumSeqsFasta { 
    my $narg_expected = 1;
    if(scalar(@_) != $narg_expected) { printf STDERR ("ERROR, determine_num_seqs() entered with %d != %d input arguments.\n", scalar(@_), $narg_expected); exit(1); } 
    my ($file) = $_[0];

    my $nseq = 0;
    my $line;
    if(!(-e $file)) { printf STDERR ("ERROR, determine_num_seqs(), file $file does not exist.\n"); exit(1); }
    open(IN, $file) || die "ERROR, couldn't open file $file to determine the number of sequences within it.\n"; 
    #find first '>'
    while(($nseq == 0) && ($line = <IN>)) { 
	if($line =~ m/^\>/)   { $nseq++; }
	elsif($line =~ m/\W/) { return -1; } # ERROR, first non-whitespace character is not '>', this is not valid FASTA
    }
    while($line = <IN>) { 
	if($line =~ m/^\>/) { $nseq++; }
    }
    close(IN);
    return $nseq;
}


#####################################################################
# Subroutine: DetermineNumSeqsStockholm()
# Incept:     EPN, Thu Nov  5 11:44:34 2009
# 
# Purpose:    Use esl-alistat to determine the number of sequences
#             and number of alignments in a Stockholm file.
#
# Arguments: 
#   $alistat:   path and name of ssu-esl-alistat executable
#   $alifile:   Stockholm sequence file
#   $ileaved:   '1' if alignment is interleaved Stockholm else '0'
#   $key:       string to add to temp file name
#   $sum_file:  sum file 
#   $log_file:  log file to print commands to
#   $nseq_AR:   reference to array to fill with num seqs for each
#               alignment in $alifile
#   $nali_R:    reference to scalar to 
#
# 
# Returns:    Nothing. 
#             Number of sequences in each alignment will be filled
#             in @{$nseq_AR}, with $nali_R elements.
# 
####################################################################
sub DetermineNumSeqsStockholm { 
    my $narg_expected = 8;
    if(scalar(@_) != $narg_expected) { printf STDERR ("\nERROR, DetermineNumSeqsStockholm() entered with %d != %d input arguments.\n", scalar(@_), $narg_expected); exit(1); } 
    my($alistat, $alifile, $ileaved, $key, $sum_file, $log_file, $nseq_AR, $nali_R) = @_;

    my ($nseq, $command, $line, $command_worked, $output, $small_opt);
    my $tmp_alistat_file = TempFilename($sum_file, $log_file, $key);
    if($ileaved) { $small_opt = ""; } 
    else         { $small_opt = " --rna --informat pfam --small"; } 
    $command = "$alistat $small_opt $alifile > $tmp_alistat_file";
    $output = RunCommand("$command", $key, 1, 1, $sum_file, $log_file, \$command_worked, "");

    $nseq = 0;
    @{$nseq_AR} = ();
    my $nali = 0;

    open(IN, $tmp_alistat_file) || FileOpenFailure($tmp_alistat_file, $log_file, $!, "reading");
    while($line = <IN>) { 
	chomp $line;
	if($line =~ /Number of sequences\:\s+(\d+)/) { 
	    $nseq = $1;
	    push(@{$nseq_AR}, $nseq);
	    $nali++;
	}
    }
    close(IN);
    
    if($nali == 0) { PrintErrorAndExit("ERROR parsing esl-alistat output in file $tmp_alistat_file, couldn't determine number of sequences in $alifile.", $sum_file, $log_file, 1); }

    UnlinkFile($tmp_alistat_file, $log_file); 
    $$nali_R = $nali;
    return;
}


#################################################################
# Subroutine : MaxArray()
# Incept:      EPN, Wed Apr 14 11:52:44 2010
# 
# Purpose:     Return the max value in an array.
#
# Arguments:
# $arr_R: reference to the array
# 
# Returns:     The max value in the array.
#
################################################################# 
sub MaxArray
{
    my $narg_expected = 1;
    if(scalar(@_) != $narg_expected) { printf STDERR ("ERROR, MaxArr() entered with %d != %d input arguments.\n", scalar(@_), $narg_expected); exit(1); } 
    my ($arr_R) = $_[0];
    if(scalar(@{$arr_R}) == 0) { printf STDERR ("ERROR, MaxArr() called with empty array."); exit(1); }

    my ($max, $i);

    $max = $arr_R->[0];
    for($i = 1; $i < scalar(@{$arr_R}); $i++) { 
	if($arr_R->[$i] > $max) { $max = $arr_R->[$i]; };
    }
    return $max;
}

#################################################################
# Subroutine : ArgmaxArray()
# Incept:      EPN, Tue Nov  4 14:33:23 2008
# 
# Purpose:     Return the index of the max value in an array.
#
# Arguments:
# $arr_R: reference to the array
# 
# Returns:     The index of the max value in the array.
#
################################################################# 
sub ArgmaxArray
{
    my $narg_expected = 1;
    if(scalar(@_) != $narg_expected) { printf STDERR ("ERROR, ArgmaxArr() entered with %d != %d input arguments.\n", scalar(@_), $narg_expected); exit(1); } 
    my ($arr_R) = $_[0];
    if(scalar(@{$arr_R}) == 0) { printf STDERR ("ERROR, ArgmaxArr() called with empty array."); exit(1); }

    my ($max, $i, $argmax);

    $max = $arr_R->[0];
    $argmax = 0;
    for($i = 1; $i < scalar(@{$arr_R}); $i++) { 
	if($arr_R->[$i] > $max) { $max = $arr_R->[$i]; $argmax = $i; }
    }
    return $argmax;
}


#################################################################
# Subroutine : MaxLengthScalarInArray()
# Incept:      EPN, Tue Nov  4 15:19:44 2008
# 
# Purpose:     Return the maximum length of a scalar in an array
#
# Arguments: 
#   $arr_R: reference to the array
# 
# Returns:     The length of the maximum length scalar.
#
################################################################# 
sub MaxLengthScalarInArray {
    my $narg_expected = 1;
    if(scalar(@_) != $narg_expected) { printf STDERR ("ERROR, MaxLengthScalarInArray() entered with %d != %d input arguments.\n", scalar(@_), $narg_expected); exit(1); } 
    my ($arr_R) = $_[0];

    my ($max, $i);
    $max = length($arr_R->[0]);
    for($i = 1; $i < scalar(@{$arr_R}); $i++) { 
	if(length($arr_R->[$i]) > $max) { $max = length($arr_R->[$i]); }
    }
    return $max;
}


#################################################################
# Subroutine : SumArrayElements()
# Incept:      EPN, Wed Nov 11 16:59:26 2009
# 
# Purpose:     Return the sum of all elements in a numeric array.
#
# Arguments:
# $arr_R: reference to the array
# 
# Returns:     The sum.
#
################################################################# 
sub SumArrayElements 
{
    my $narg_expected = 1;
    if(scalar(@_) != $narg_expected) { printf STDERR ("ERROR, SumArrayElements() entered with %d != %d input arguments.\n", scalar(@_), $narg_expected); exit(1); } 
    my ($arr_R) = $_[0];

    my $nels = scalar(@{$arr_R}); 
    my $sum = 0.;
    my $i;

    for($i = 1; $i < $nels; $i++) { $sum += $arr_R->[$i]; } 
    return $sum;
}


#################################################################
# Subroutine : SumHashElements()
# Incept:      EPN, Wed Nov 11 17:01:19 2009
# 
# Purpose:     Return the sum of all elements in a numerich hash.
#
# Arguments:
# $hash_R: reference to the hash
# 
# Returns:     The sum.
#
################################################################# 
sub SumHashElements 
{
    my $narg_expected = 1;
    if(scalar(@_) != $narg_expected) { printf STDERR ("ERROR, SumHashElements() entered with %d != %d input arguments.\n", scalar(@_), $narg_expected); exit(1); } 
    my ($hash_R) = $_[0];

    my $key;
    my $sum = 0.;
    foreach $key (keys %{$hash_R}) { $sum += $hash_R->{$key}; }

    return $sum;
}


#################################################################
# Subroutine : TryPs2Pdf
# Incept:      EPN, Fri Nov  6 05:50:40 2009
# 
# Purpose:     Try running $ps2pdf command to convert a postscript 
#              file into a pdf file. If $ps2pdf == "", use command
#              'ps2pdf', else use $ps2pdf. 
# Arguments: 
#   $ps2pdf:                    command to execute, if "", use 'ps2pdf'
#   $ps_file:                   postscript file
#   $pdf_file:                  pdf file to create
#   $key:                       string for temp file name
#   $die_if_fails:              '1' to die if command returns non-zero status
#   $print_output_upon_failure: '1' to print command output to STDERR if it fails
#   $sum_file:                  file to print command and output to
#   $log_file:                  file to print command and output to
#   $command_worked_ref:        set to '1' if command works (returns 0), else set to '0'         
#   $errmsg:                    message to print if command returns non-0 exit status
# 
# Returns:     Nothing. $command_worked_ref is filled with
#              '1' if command worked (return 0), '0' otherwise.
#
################################################################# 
sub TryPs2Pdf {
    my $narg_expected = 10;
    if(scalar(@_) != $narg_expected) { printf STDERR ("ERROR, TryPs2Pdf() entered with %d != %d input arguments.\n", scalar(@_), $narg_expected); exit(1); } 
    my ($ps2pdf, $ps_file, $pdf_file, $key, $die_if_fails, $print_output_upon_failure, $sum_file, $log_file, $command_worked_ref, $errmsg) = @_;

    # contract check
    if(! (-e $ps_file)) { die "\nERROR, in TryPs2Pdf(), ps file $ps_file doesn't exist.\n"; }

    my $command_worked;
     if($ps2pdf eq "") { $ps2pdf = "ps2pdf"; }

    my $command = "$ps2pdf $ps_file $pdf_file";
    RunCommand("$command", $key, $die_if_fails, $print_output_upon_failure, $sum_file, $log_file, \$command_worked, $errmsg);

    $$command_worked_ref = $command_worked;
    return;
}


#################################################################
# Subroutine : SwapOrAppendFileSuffix
# Incept:      EPN, Mon Nov  9 14:21:07 2009
#
# Purpose:     Given a file name, possible original suffixes it may 
#              have (such as '.stk', '.sto'), and a new suffix: 
#              if the name has any of the original suffixes replace them
#              with the new one, else simply append the new suffix.
#              Also, if <$use_orig_dir> == 1, then include
#              the same dir path to the new file, else remove
#              the dir path (in this case, it is assumed that we
#              want the new file in the CWD.
#
# Arguments: 
#   $orig_file:       name of original file
#   $orig_suffix_AR:  reference to array of original suffixes 
#   $new_suffix:      new suffix to include in new file
#   $use_orig_dir:    '1' to place new file in same dir as old one
#                     '0' to always place new file in CWD.
# 
# Returns:     The name of the new file, with $new_suffix appended
#              or swapped.
#
################################################################# 
sub SwapOrAppendFileSuffix {
    my $narg_expected = 4;
    if(scalar(@_) != $narg_expected) { printf STDERR ("ERROR, SwapOrAppendFileSuffix() entered with %d != %d input arguments.\n", scalar(@_), $narg_expected); exit(1); } 
    my ($orig_file, $orig_suffix_AR, $new_suffix, $use_orig_dir) = @_;

    my $new_file;
    my $suffix;
    my $did_swap = 0;
    $new_file = $orig_file;
    foreach $suffix (@{$orig_suffix_AR}) { 
	if($new_file =~ s/$suffix$/$new_suffix/) { $did_swap = 1; last; } #only remove final suffix (if ".stk.sto", remove only ".sto")
    }
    if(! $did_swap) { # we couldn't find one of the orig suffixes in @{$orig_suffix_AR}, append $new_suffix
	$new_file .= $new_suffix;
    }
    if(! $use_orig_dir) { 
	$new_file = RemoveDirPath($new_file); # remove dir path
    }
    return $new_file;
}


#################################################################
# Subroutine : RemoveDirPath()
# Incept:      EPN, Mon Nov  9 14:30:59 2009
#
# Purpose:     Given a file name remove the directory path.
#              For example: "foodir/foodir2/foo.stk" becomes "foo.stk".
#
# Arguments: 
#   $orig_file: name of original file
# 
# Returns:     The string $orig_file with dir path removed.
#
################################################################# 
sub RemoveDirPath {
    my $narg_expected = 1;
    if(scalar(@_) != $narg_expected) { printf STDERR ("ERROR, RemoveDirPath() entered with %d != %d input arguments.\n", scalar(@_), $narg_expected); exit(1); } 
    my $orig_file = $_[0];

    $orig_file =~ s/^.+\///;
    return $orig_file;
}



#################################################################
# Subroutine : ReturnDirPath()
# Incept:      EPN, Mon Mar 15 10:17:11 2010
#
# Purpose:     Given a file name return the directory path, with the final '/'
#              For example: "foodir/foodir2/foo.stk" becomes "foodir/foodir2/".
#
# Arguments: 
#   $orig_file: name of original file
# 
# Returns:     The string $orig_file with actual file name removed
#
################################################################# 
sub ReturnDirPath {
    my $narg_expected = 1;
    if(scalar(@_) != $narg_expected) { printf STDERR ("ERROR, RemoveDirPath() entered with %d != %d input arguments.\n", scalar(@_), $narg_expected); exit(1); } 
    my $orig_file = $_[0];

    if($orig_file !~ m/\//) { $orig_file = "/" . $orig_file; } # add '/' to beginning if it doesn't exist

    $orig_file =~ s/\/.+$//; # remove everything after first '/' as well as first '/'

    if($orig_file eq "") { return "./";             }
    else                 { return $orig_file . "/"; }
}


#################################################################
# Subroutine : UseModuleIfItExists()
# Incept:      EPN, Tue Nov 10 17:36:16 2009
#
# Purpose:     If a module exists on the system, use it (with use())
#              and return '1', else return '0'.
#
# Arguments: 
#   $module: name of module to check for (ex: "Time::HiRes qw(gettimeofday)")
# 
# Returns:     '1' if module is installed and used, '0' if not.
#
################################################################# 
sub UseModuleIfItExists { 
    my $narg_expected = 1;
    if(scalar(@_) != $narg_expected) { printf STDERR ("ERROR, UseModuleIfItExists() entered with %d != %d input arguments.\n", scalar(@_), $narg_expected); exit(1); } 
    my $module = $_[0];

    eval "use $module";

    if ($@) { return 0; }
    else    { return 1; }
}



#################################################################
# Subroutine : SecondsSinceEpoch()
# Incept:      EPN, Tue Nov 10 17:38:11 2009
#
# Purpose:     Return number of seconds since the epoch, this
#              will be different precision depending on if
#              <$time_hires_installed>.
#
# Arguments: 
#   $time_hires_installed: '1' if we can use gettimeofday
#                          to get high precision timings.
# 
# Returns:     Number of seconds since the epoch.
#
################################################################# 
sub SecondsSinceEpoch { 
    my $narg_expected = 1;
    if(scalar(@_) != $narg_expected) { printf STDERR ("ERROR, GetSecondsSinceEpoch() entered with %d != %d input arguments.\n", scalar(@_), $narg_expected); exit(1); } 
    my $time_hires_installed = $_[0];

    if($time_hires_installed) { 
	my ($seconds, $microseconds) = gettimeofday();
	return ($seconds + ($microseconds / 1000000.));
    }
    else { # this will be one-second precision
	return time();
    }
}


#################################################################
# Subroutine : FileOpenFailure()
# Incept:      EPN, Wed Nov 11 05:39:56 2009
#
# Purpose:     Called if a open() call fails on a file.
#              Print an informative error message
#              to <$sum_file>, <$log_file> and to STDERR, 
#              then exit with <$status>.
#
# Arguments: 
#   $file_to_open: file that we couldn't open
#   $sum_file:     summary file to write errmsg to, "" for none
#   $log_file:     log file to write errmsg to, "" for none
#   $status:       error status
#   $action:       "reading", "writing", "appending"
# 
# Returns:     Nothing, this function will exit the program.
#
################################################################# 
sub FileOpenFailure { 
    my $narg_expected = 5;
    if(scalar(@_) != $narg_expected) { printf STDERR ("ERROR, FileOpenForReadingFailure() entered with %d != %d input arguments.\n", scalar(@_), $narg_expected); exit(1); } 
    my ($file_to_open, $sum_file, $log_file, $status, $action) = @_;

    my $errmsg;
    if(($action eq "reading") && (! (-e $file_to_open))) { 
	$errmsg = "\nERROR, could not open $file_to_open for reading. It does not exist.\n";
    }
    else { 
	$errmsg = "\nERROR, could not open $file_to_open for $action.\n";
    }
    PrintErrorAndExit($errmsg, $sum_file, $log_file, $status);
}


#################################################################
# Subroutine : PrintErrorAndExit()
# Incept:      EPN, Wed Nov 11 06:22:59 2009
#
# Purpose:     Print an error message to STDERR and two files
#              (should be summary file and log file),
#              then exit with return status <$status>.
#
# Arguments: 
#   $errmsg:       the error message to write
#   $sum_file:     sum file to write errmsg to, "" for none
#   $log_file:     log file to write errmsg to, "" for none
#   $status:       error status to exit with
# 
# Returns:     Nothing, this function will exit the program.
#
################################################################# 
sub PrintErrorAndExit { 
    my $narg_expected = 4;
    if(scalar(@_) != $narg_expected) { printf STDERR ("ERROR, PrintErrorAndExit() entered with %d != %d input arguments.\n", scalar(@_), $narg_expected); exit(1); } 
    my ($errmsg, $sum_file, $log_file, $status) = @_;

    if($errmsg !~ m/\n$/) { $errmsg .= "\n\n"; }
    else                  { $errmsg .= "\n"; }
    if($errmsg !~ m/^\n/) { $errmsg = "\n" . $errmsg; }

    if($sum_file ne "") { 
	PrintStringToFile($sum_file, 0, $errmsg);
	PrintStringToFile($sum_file, 0, "# SSU-ALIGN-FAILURE\n");
    }
    if($log_file ne "") { 
	PrintStringToFile($log_file, 0, $errmsg);
	PrintStringToFile($log_file, 0, "# SSU-ALIGN-FAILURE\n");
    }
    printf STDERR $errmsg; 
    exit($status);
}


#####################################################################
# Subroutine: PrintSearchAndAlignStatistics()
# Incept:     EPN, Thu Nov 12 05:40:53 2009
# 
# Purpose:    Print statistics on the search and alignment we just 
#             performed to the summary file and stdout.
#
# Arguments: 
# $search_seconds:       seconds required for search, "NA" if search was not performed
# $align_seconds:        seconds required for alignment, "NA" if alignment was not performed
# $target_nseq:          number of sequences in input target file
# $target_nres:          number of residues in input target file
# $nseq_all_cms:         number of sequences that were best match to any CM
# $nres_total_all_cms:   summed length of all target seqs that were best 
#                        match to any CM
# $nres_hit_all_cms:     summed length of extracted hits that were best match to any CM
# $indi_cm_name_AR:      reference to array with CM names
# $cm_used_for_align_HR: reference to hash telling whether each CM was used for alignment or not
# $nseq_cm_HR:           number of sequences that were best match to each CM 
# $nres_total_cm_HR:     summed length of target seqs that were best match to each CM
# $nres_hit_cm_HR:       summed length of extracted hits that were best match to each CM
# $print_to_stdout:      '1' to also print to stdout (in addition to <$sum_file>)
# $sum_file:             summary file 
# $log_file:             summary file 
# 
# Returns:    Nothing.
#             
# 
####################################################################
sub PrintSearchAndAlignStatistics { 
    my $narg_expected = 15;
    if(scalar(@_) != $narg_expected) { printf STDERR ("ERROR, PrintSearchAndAlignStatistics() entered with %d != %d input arguments.\n", scalar(@_), $narg_expected); exit(1); } 
    my ($search_seconds, $align_seconds, $target_nseq, $target_nres, $nseq_all_cms, $nres_total_all_cms, $nres_hit_all_cms, 
	$indi_cm_name_AR, $cm_used_for_align_HR, $nseq_cm_HR, $nres_total_cm_HR, $nres_hit_cm_HR, $print_to_stdout, $sum_file, $log_file) = @_;

    my ($cm_name, $i);
    my $nres_aligned_all_cms = 0;
    my $nseq_aligned_all_cms = 0;

    PrintStringToFile($sum_file, $print_to_stdout, sprintf("#\n"));
    PrintStringToFile($sum_file, $print_to_stdout, sprintf("# Summary statistics:\n"));
    PrintStringToFile($sum_file, $print_to_stdout, sprintf("#\n"));

    my $cm_width = MaxLengthScalarInArray($indi_cm_name_AR);
    if($cm_width < length("*all-models*")) { $cm_width = length("*all-models*"); }
    my $dashes = ""; for($i = 0; $i < $cm_width; $i++) { $dashes .= "-"; } 
    PrintStringToFile($sum_file, $print_to_stdout, sprintf("# %-*s  %7s  %8s  %13s  %8s  %13s\n", $cm_width, "model or",   "number",  "fraction", "average",        "average",  ""));
    PrintStringToFile($sum_file, $print_to_stdout, sprintf("# %-*s  %7s  %8s  %13s  %8s  %13s\n", $cm_width, "category",   "of seqs", "of total", "length",         "coverage", "nucleotides"));
    PrintStringToFile($sum_file, $print_to_stdout, sprintf("# %-*s  %7s  %8s  %13s  %8s  %13s\n", $cm_width, $dashes,      "-------", "--------", "-------------",  "--------", "-------------"));
    
    PrintStringToFile($sum_file, $print_to_stdout, sprintf("  %-*s  %7d  %8.4f  %13.2f  %8.4f  %13d\n", 
							   $cm_width, "*input*", 
							   $target_nseq,
							   1.0, 
							   $target_nres / $target_nseq,
							   1.0, 
							   $target_nres));
    PrintStringToFile($sum_file, $print_to_stdout, "\#\n");
    
    foreach $cm_name (@{$indi_cm_name_AR}) { 
	if($nseq_cm_HR->{$cm_name} == 0) { 
	    PrintStringToFile($sum_file, $print_to_stdout, sprintf("  %-*s  %7d  %8.4f  %13s  %8s  %13d\n", 
								   $cm_width, $cm_name, 
								   $nseq_cm_HR->{$cm_name},
								   $nseq_cm_HR->{$cm_name} / $target_nseq,
								   "-", "-", 0));
	}
	else { 
	    PrintStringToFile($sum_file, $print_to_stdout, sprintf("  %-*s  %7d  %8.4f  %13.2f  %8.4f  %13d\n", 
								   $cm_width, $cm_name, 
								   $nseq_cm_HR->{$cm_name},
								   $nseq_cm_HR->{$cm_name} / $target_nseq,
								   $nres_hit_cm_HR->{$cm_name} / $nseq_cm_HR->{$cm_name}, 
								   $nres_hit_cm_HR->{$cm_name} / $nres_total_cm_HR->{$cm_name}, 
								   $nres_hit_cm_HR->{$cm_name}));
	    if($cm_used_for_align_HR->{$cm_name}) { 
		$nseq_aligned_all_cms += $nseq_cm_HR->{$cm_name}; 
		$nres_aligned_all_cms += $nres_hit_cm_HR->{$cm_name}; 
	    }
	}
    }
    #if($nseq_all_cms == 0) { PrintErrorAndExit("ERROR, no seqs matched to any CM (during stat printing). Program should've exited earlier. Error in code.", $sum_file, $log_file, 1); }
    PrintStringToFile($sum_file, $print_to_stdout, "\#\n");
    PrintStringToFile($sum_file, $print_to_stdout, sprintf("  %-*s  %7d  %8.4f  %13.2f  %8.4f  %13d\n", 
							   $cm_width, "*all-models*", 
							   $nseq_all_cms,
							   $nseq_all_cms / $target_nseq,
							   ($nseq_all_cms       > 0) ? ($nres_hit_all_cms / $nseq_all_cms)       : 0., 
							   ($nres_total_all_cms > 0) ? ($nres_hit_all_cms / $nres_total_all_cms) : 0, 
							   $nres_hit_all_cms));
    if($target_nseq > $nseq_all_cms) { 
	PrintStringToFile($sum_file, $print_to_stdout, sprintf("  %-*s  %7d  %8.4f  %13.2f  %8.4f  %13d\n", 
							       $cm_width, "*no-models*", 
							       $target_nseq - $nseq_all_cms,
							       ($target_nseq - $nseq_all_cms) / $target_nseq,
							       ($target_nres - $nres_total_all_cms) / ($target_nseq - $nseq_all_cms),
							       0.,
							       ($target_nres - $nres_total_all_cms)));
    }
    else { 
	PrintStringToFile($sum_file, $print_to_stdout, sprintf("  %-*s  %7d  %8.4f  %13s  %8s  %13s\n", 
							       $cm_width, "*no-models*", 
							       $target_nseq - $nseq_all_cms,
							       0., "-", "-", 0));
    }
    
    if($search_seconds eq "0") { $search_seconds = 1; }
    if($align_seconds eq "0")  { $align_seconds = 1; }
    PrintStringToFile($sum_file, $print_to_stdout, sprintf("#\n"));
    PrintStringToFile($sum_file, $print_to_stdout, sprintf("# Speed statistics:\n"));
    PrintStringToFile($sum_file, $print_to_stdout, sprintf("#\n"));
    PrintStringToFile($sum_file, $print_to_stdout, sprintf("# %-9s  %8s  %7s  %13s  %13s  %8s\n","stage",     "num seqs", "seq/sec", "seq/sec/model", "nucleotides",   "nt/sec"));
    PrintStringToFile($sum_file, $print_to_stdout, sprintf("# %9s  %8s  %7s  %13s  %13s  %8s\n", "---------", "--------", "-------", "-------------", "-------------", "--------"));
    if($search_seconds ne "NA") { 
	PrintStringToFile($sum_file, $print_to_stdout, sprintf("  %-9s  %8d  %7.3f  %13.3f  %13d  %8.1f\n", 
							       "search", $target_nseq, 
							       ($target_nseq / $search_seconds), 
							       ($target_nseq / ($search_seconds * scalar(@{$indi_cm_name_AR}))), 
							       $target_nres, 
							       $target_nres / $search_seconds));
    }
    if($align_seconds ne "NA") { 
	PrintStringToFile($sum_file, $print_to_stdout, sprintf("  %-9s  %8d  %7.3f  %13.3f  %13d  %8.1f\n", 
							       "alignment", $nseq_aligned_all_cms, 
							       ($nseq_aligned_all_cms / $align_seconds), 
							       ($nseq_aligned_all_cms / $align_seconds), 
							       $nres_aligned_all_cms, 
							       $nres_aligned_all_cms / $align_seconds));
    }
    PrintStringToFile($sum_file, $print_to_stdout, sprintf("#\n"));

    return;
}


#################################################################
# Subroutine : NumberOfDigits()
# Incept:      EPN, Fri Nov 13 06:17:25 2009
# 
# Purpose:     Return the number of digits in a number before
#              the decimal point. (ex: 1234.56 would return 4).
# Arguments:
# $num:        the number
# 
# Returns:     the number of digits before the decimal point
#
################################################################# 
sub NumberOfDigits
{
    my $narg_expected = 1;
    if(scalar(@_) != $narg_expected) { printf STDERR ("ERROR, NumberOfDigits() entered with %d != %d input arguments.\n", scalar(@_), $narg_expected); exit(1); } 
    my ($num) = $_[0];

    my $ndig = 1; 
    while($num > 10) { $ndig++; $num /= 10.; }

    return $ndig;
}


#################################################################
# Subroutine : FindPossiblySharedFile()
# Incept:      EPN, Thu Nov 19 09:45:55 2009
# 
# Purpose:     Given a path to a file, determine if that file
#              exists either with respect to the current
#              working directory and/or with respect to 
#              another directory <$other_dir>.
#
# Arguments:
# $file:       name of file, possibly with directory path as a prefix
# $other_dir:  second directory in which to look for the file, 
#              if "", don't look in another dir
# 
# Returns:     The local path to the file if it does
#              exist in the current dir, else the full
#              path to it in <$other_dir>, else if it
#              doesn't exist in either place, return "".
#
################################################################# 
sub FindPossiblySharedFile
{
    my $narg_expected = 2;
    if(scalar(@_) != $narg_expected) { printf STDERR ("ERROR, FindPossiblySharedFile() entered with %d != %d input arguments.\n", scalar(@_), $narg_expected); exit(1); } 
    my ($file, $other_dir) = @_;
    
    if(-e $file) { return $file; }

    if($other_dir ne "") { 
	# if other_dir has a "/" at the end, remove it
	$other_dir =~ s/\/$//;
	
	$file = $other_dir . "/" . $file;
	if(-e ($file)) { return $file; }
    }
    return "";
}


#####################################################################
# Subroutine: SeqstatSeqFilePerSeq()
# Incept:     EPN, Wed Nov 11 15:30:40 2009
# 
# Purpose:    Get statistics on a sequence file using easel's
#             esl-seqstat miniapp, including the length of each
#             sequence. Also, verify that there are not two
#             sequences with the same name in the sequence
#             file; if there are, die with an error message.
#
# Arguments: 
# $seqstat:          the esl-seqstat executable
# $seqfile:          the target sequence file 
# $seqstat_out_file: output file from seqstat, created here
# $key:              string for temp file name
# $total_nres_R:     RETURN: total number of residues in all seqs in the file
# $total_nseq_R:     RETURN: total number of sequences in the file
# $format_R:         RETURN: sequence file format (ex: "FASTA")
# $target_order_AR:  reference to an array to fill with order of sequences
# $target_len_HR:    reference to a hash to fill with length of sequences
# $sum_file:         summary file 
# $log_file:         log file to print commands to
# 
# Returns:    <$total_nres_R>, <$total_nseq_R>, <$format_R>, 
#             <$seq_order_AR>, <$seq_len_HR> filled. Other than
#             that nothing is returned.
#             
# 
####################################################################
sub SeqstatSeqFilePerSeq { 
    my $narg_expected = 11;
    if(scalar(@_) != $narg_expected) { printf STDERR ("ERROR, SeqstatSeqFilePerSeq() entered with %d != %d input arguments.\n", scalar(@_), $narg_expected); exit(1); } 
    my ($seqstat, $seqfile, $seqstat_out_file, $key, $total_nres_R, $total_nseq_R, $format_R, $seq_order_AR, $seq_len_HR, $sum_file, $log_file) = @_;

    my ($command, $command_worked, $line, $format, $total_nseq, $total_nres);
    $command = "$seqstat --rna -a $seqfile > $seqstat_out_file";
    RunCommand("$command", $key, 1, 1, $sum_file, $log_file, \$command_worked, "");
    
    # parse seqstat output
    my $nseq_read = 0;
    my $nres_read = 0;
    my ($seqname, $seqlen);
    open(SEQSTAT, $seqstat_out_file) || FileOpenFailure($seqstat_out_file, $sum_file, $log_file, $!, "reading");
    while($line = <SEQSTAT>) { 
	if($line =~ /^\=\s+(\S+)\s+(\d+)/) { 
	    $seqname = $1;
	    $seqlen  = $2;
	    $nseq_read++;
	    $nres_read += $seqlen;
	    push(@{$seq_order_AR}, $seqname);
	    if(exists($seq_len_HR->{$seqname})) { PrintErrorAndExit("ERROR, there are two sequences with the same name ($seqname) in $seqfile.\nAll sequences must have a unique name.", $sum_file, $log_file, 1); }
	    $seq_len_HR->{$seqname} = $seqlen;
	}
	elsif($line =~ s/^Format\:\s+//) { 
	    chomp $line; 
	    $format = $line;
	}
	elsif($line =~ s/^Number of sequences\:\s+//) { 
	    chomp $line; 
	    $total_nseq = $line;
	}
	elsif($line =~ s/^Total \# residues\:\s+//) { 
	    chomp $line; 
	    $total_nres = $line;
	}
    }
    close(SEQSTAT);

    # validate what we just parsed
    if($nseq_read == 0)           { PrintErrorAndExit("ERROR, unable to parse $seqstat output in file $seqstat_out_file,\n0 individual sequence lengths read.", $sum_file, $log_file, 1); }
    if($nseq_read != $total_nseq) { PrintErrorAndExit("ERROR, unable to parse $seqstat output in file $seqstat_out_file,\nnumber of individual sequences disagrees with summary output.", $sum_file, $log_file, 1); }
    if($nres_read != $total_nres) { PrintErrorAndExit("ERROR, unable to parse $seqstat output in file $seqstat_out_file,\nsummed length of individual sequences disagrees with summary output.", $sum_file, $log_file, 1); }
    if($format eq "")             { PrintErrorAndExit("ERROR, unable to parse sequence file format in $seqstat output in file $seqstat_out_file.", $sum_file, $log_file, 1); }

    $$total_nres_R = $total_nres;
    $$total_nseq_R = $total_nseq;
    $$format_R     = $format;
    
    return;
}


#################################################################
# Subroutine : InitializeSsuAlignOptions()
# Incept:      EPN, Mon Apr  5 17:16:13 2010
# 
#
# Purpose:     Update the <opt_takes_arg_HR> hash and the <opt_order_AR>
#              array for ssu-align/ssu-prep command-line options. 
#              Called by both 'ssu-align' and 'ssu-prep'.
#
# Arguments:
# $opt_takes_arg_HR:  ref to hash, key is option name, value
#                     is '1' for 'takes an argument', '0' for 
#                     'doesnt take an argument'
# $opt_order_AR:      ref to arr, order of options
# 
# Returns:     Nothing.
#
################################################################# 
sub InitializeSsuAlignOptions {
    my $narg_expected = 2;
    if(scalar(@_) != $narg_expected) { printf STDERR ("ERROR, InitializeSsuAlignOptions() entered with %d != %d input arguments.\n", scalar(@_), $narg_expected); exit(1); } 
    my ($opt_takes_arg_HR, $opt_order_AR) = @_;
    
    $opt_takes_arg_HR->{"-h"}          = 0;  push(@{$opt_order_AR}, "-h");
    $opt_takes_arg_HR->{"-f"}          = 0;  push(@{$opt_order_AR}, "-f");
    $opt_takes_arg_HR->{"-m"}          = 1;  push(@{$opt_order_AR}, "-m");
    $opt_takes_arg_HR->{"-b"}          = 1;  push(@{$opt_order_AR}, "-b");
    $opt_takes_arg_HR->{"-l"}          = 1;  push(@{$opt_order_AR}, "-l");
    $opt_takes_arg_HR->{"-i"}          = 0;  push(@{$opt_order_AR}, "-i");
    $opt_takes_arg_HR->{"-n"}          = 1;  push(@{$opt_order_AR}, "-n");
    $opt_takes_arg_HR->{"--dna"}       = 0;  push(@{$opt_order_AR}, "--dna");
    $opt_takes_arg_HR->{"--keep-int"}  = 0;  push(@{$opt_order_AR}, "--keep-int");
    $opt_takes_arg_HR->{"--rfonly"}    = 0;  push(@{$opt_order_AR}, "--rfonly");
    $opt_takes_arg_HR->{"--no-align"}  = 0;  push(@{$opt_order_AR}, "--no-align");
    $opt_takes_arg_HR->{"--no-search"} = 0;  push(@{$opt_order_AR}, "--no-search");
    $opt_takes_arg_HR->{"--no-trunc"}  = 0;  push(@{$opt_order_AR}, "--no-trunc");
    $opt_takes_arg_HR->{"--toponly"}   = 0;  push(@{$opt_order_AR}, "--toponly");
    $opt_takes_arg_HR->{"--forward"}   = 0;  push(@{$opt_order_AR}, "--forward");
    $opt_takes_arg_HR->{"--global"}    = 0;  push(@{$opt_order_AR}, "--global");
    $opt_takes_arg_HR->{"--aln-one"}   = 1;  push(@{$opt_order_AR}, "--aln-one");
    $opt_takes_arg_HR->{"--filter"}    = 1;  push(@{$opt_order_AR}, "--filter");
    $opt_takes_arg_HR->{"--no-prob"}   = 0;  push(@{$opt_order_AR}, "--no-prob");
    $opt_takes_arg_HR->{"--mxsize"}    = 1;  push(@{$opt_order_AR}, "--mxsize");

    return;
}


#################################################################
# Subroutine : CheckSsuAlignOptions()
# Incept:      EPN, Mon Apr  5 17:16:13 2010
# 
#
# Purpose:     Check a ssu-align/ssu-prep <opt_HR> hash for incompatible
#              option combinations/ranges, and die with an error message 
#              if any exist. This function 'knows' about which options
#              takes args and which do not.
#
# Arguments:
# $opt_HR:  ref to hash of options, key is actual option,
#           values are arguments, examples: 
#               $opt_HR->{"--no-align"}  = 0 => --no-align not set on cmd line
#               $opt_HR->{"--no-search"} = 1 => --no-search set on cmd line
#               $opt_HR->{"-m"} = ""         => '-m' not set on cmd line
#               $opt_HR->{"-m"} = "foo.cm"   => '-m foo.cm' set on cmd line 
#   
#
# Returns:     Nothing, dies if any incompatible combinations exist.
#
################################################################# 
sub CheckSsuAlignOptions {
    my $narg_expected = 1;
    if(scalar(@_) != $narg_expected) { printf STDERR ("ERROR, CheckSsuAlignOptions() entered with %d != %d input arguments.\n", scalar(@_), $narg_expected); exit(1); } 
    my ($opt_HR) = @_;

    if(($opt_HR->{"--no-align"}) && 
       (($opt_HR->{"--filter"} ne "")   ||
	($opt_HR->{"-i"})               ||
	($opt_HR->{"--no-prob"})        ||
	($opt_HR->{"--aln-one"} ne "")  ||
	($opt_HR->{"--mxsize"} ne ""))) { 
	printf STDERR ("\nERROR, --no-align is incompatible with alignment-specific options: -i,--filter,--no-prob, --aln-one and --mxsize.\n"); exit(1); 
    }

    if(($opt_HR->{"--no-search"}) && 
       (($opt_HR->{"-b"} ne "") ||
	($opt_HR->{"-l"})      ||
	($opt_HR->{"--toponly"})  ||
	($opt_HR->{"--no-trunc"})  ||
	($opt_HR->{"--forward"})  ||
	($opt_HR->{"--global"}) ||
	($opt_HR->{"--keep-int"}))) {
	printf STDERR ("\nERROR, --no-search is incompatible with search-specific options: -b,-l,--toponly,--no-trunc,--forward, --keep-int, and --global.\n"); exit(1); 
    }

    # Check for incompatible option ranges
    if(($opt_HR->{"-l"} ne "")       && ($opt_HR->{"-l"} <= 0))        { printf STDERR ("\nERROR, with -l <n>, <n> must be greater than 0.\n"); exit(1); }
    if(($opt_HR->{"--mxsize"} ne "") && ($opt_HR->{"--mxsize"} <= 0.)) { printf STDERR ("\nERROR, with --mxsize <f>, <f> must be greater than 0.\n"); exit(1); }
    if(($opt_HR->{"--filter"} ne "") && (($opt_HR->{"--filter"} < 0.) || ($opt_HR->{"--filter"} > 1.))) { printf STDERR ("\nERROR, with --filter <f>, <f> must be between 0. and 1.\n"); exit(1); }
    
    return;
}


#####################################################################
# Subroutine: ValidateAndSetupSsuAlignOrPrep()
# Incept:     EPN, Mon Nov  3 15:05:56 2008
# 
# Purpose:    Validation and setup of ssu-align/ssu-prep:
#             - validate that the sequence file exists
#             - validate that the required executable programs exist
#             - validate that the CM file exists
#
# Arguments: 
# $globals_HR:      reference to the 'globals' hash
# $ssualigndir:     where the library files (CM file, template file) are 
#                   determined prior to entering this subroutine by 
#                   $ENV{"SSUALIGNDIR"} by the caller.
# $target_file:     the target sequence file 
# $caller_is_ssu_prep: TRUE if called by 'ssu-prep', FALSE if not (caller is probably ssu-align).
# $caller_will_merge:  TRUE if caller will need 'ssu-merge', FALSE if not
# $opt_HR:          reference to the hash of command-line options
# $tfilectr_R:      refernece to counter for naming tmp files
# $ssualign_R:      RETURN; ssu-align executable command
# $ssumerge_R:      RETURN; ssu-merge executable command
# $cmsearch_R:      RETURN; cmsearch executable command
# $cmalign_R:       RETURN; cmalign executable command
# $reformat_R:      RETURN; esl-reformat executable command
# $sfetch_R:        RETURN; esl-sfetch executable command
# $seqstat_R:       RETURN; esl-seqstat executable command
# $weight_R:        RETURN; esl-weight executable command
# $cm_file_R:       RETURN; the path to the CM file, either default CM file or <s> from -m <s>
# $indi_cm_name_AR: RETURN; array of individual CM names in the
#                   order they appear in the CM file
# $sum_file:        summary file
# $log_file:        file to print commands to 
# 
# Returns:    Nothing, if it returns, everything is valid.
# 
# Exits:      If a required program does not exist, the program 
#             prints a message to STDERR explaining why it's
#             exiting early and then exits with non-zero status.
#
####################################################################
sub ValidateAndSetupSsuAlignOrPrep { 
    my $narg_expected = 19;
    if(scalar(@_) != $narg_expected) { printf STDERR ("\nERROR, ValidateAndSetupSsuAlignOrPrep() entered with %d != %d input arguments.\n", scalar(@_), $narg_expected); exit(1); } 
    my($globals_HR, $ssualigndir, $target_file, $caller_is_ssu_prep, $caller_will_merge, $opt_HR, $tfilectr_R, $ssualign_R, $ssumerge_R, $cmsearch_R, $cmalign_R, $reformat_R, $sfetch_R, $seqstat_R, $weight_R, $cm_file_R, $indi_cm_name_AR, $sum_file, $log_file) = @_;

    #Make sure the CM file exists either with respect to cwd or SSUALIGNDIR
    my $cm_file = "";
    if($opt_HR->{"-m"} ne "") { # -m <s> invoked, determine the absolute path to the CM file, we'll use this
	                        # this is important if we are in prep mode and need to specify -m to child ssu-align calls
	$cm_file = FindPossiblySharedFile($opt_HR->{"-m"}, $ssualigndir);
	if(-e $cm_file) { 
	    # $cm_file does exist, we need the absolute path, in case we're spawning/setting up child processes 
	    if(-e (getcwd() . "/" . $cm_file)) { # user did not supply absolute path $cm_file is relative path from cwd
		$cm_file = getcwd() . "/" . $cm_file;
	    }
	    if(! (-e $cm_file)) { PrintErrorAndExit("ERROR, error processing -m option (cm file: $cm_file), bug in code.\n", $sum_file, $log_file, 1); }
	}
	else { #$opt_HR->{"-m"} does not exist
	    PrintErrorAndExit("ERROR, CM file $cm_file, specified with -m does not exist.", $sum_file, $log_file, 1); 
	}
    }
    else { # -m not invoked, use default CM file
	$cm_file = $globals_HR->{"DF_CM_FILE"};
	if(!(-e $cm_file))   { PrintErrorAndExit("ERROR, the default CM file $cm_file does not exist.", $sum_file, $log_file, 1); }
    }
    
    #Make sure the target file exists
    if(!(-e $target_file))   { PrintErrorAndExit("ERROR, target sequence file $target_file does not exist.", $sum_file, $log_file, 1); }
    
    my ($tmp, $command_worked);
    my $cmsearch   = $globals_HR->{"cmsearch"};
    my $cmalign    = $globals_HR->{"cmalign"};
    my $reformat   = $globals_HR->{"esl-reformat"};
    my $sfetch     = $globals_HR->{"esl-sfetch"};
    my $seqstat    = $globals_HR->{"esl-seqstat"};
    my $weight     = $globals_HR->{"esl-weight"};
    my $ssualign   = $globals_HR->{"ssu-align"};
    my $ssumerge   = $globals_HR->{"ssu-merge"};

    # check that the required programs are in the PATH
    ValidateRequiredExecutable($seqstat, $$tfilectr_R++, "-h", $sum_file, $log_file); 
    if(!($opt_HR->{"--no-search"})) { 
	ValidateRequiredExecutable($cmsearch, $$tfilectr_R++, "-h", $sum_file, $log_file);  
	ValidateRequiredExecutable($sfetch,   $$tfilectr_R++, "-h", $sum_file, $log_file);  
	ValidateRequiredExecutable($reformat, $$tfilectr_R++, "-h", $sum_file, $log_file); 
    }
    if(!($opt_HR->{"--no-align"}))  { ValidateRequiredExecutable($cmalign,  $$tfilectr_R++, "-h", $sum_file, $log_file); } 
    if($opt_HR->{"--filter"} ne "") { ValidateRequiredExecutable($weight,   $$tfilectr_R++, "-h", $sum_file, $log_file); }
    if($caller_is_ssu_prep)         { ValidateRequiredExecutable($ssualign, $$tfilectr_R++, "-h", $sum_file, $log_file); }
    if($caller_will_merge)          { ValidateRequiredExecutable($ssumerge, $$tfilectr_R++, "-h", $sum_file, $log_file); }

    # Finally, validate and process the CM file by making sure each CM has a unique name,
    # and store those names in @{$indi_cm_name_AR}
    my($line, $cm_name);
    my %cm_name_exists_H = ();
    my $found_aln_one_name = 0;
    my $found_only_name = 0;
    my $cms_read = "";

    open(CM, $cm_file) || FileOpenFailure($cm_file, $sum_file, $log_file, $!, "reading");
    while($line = <CM>) {
	# the lines we're interested in look like this:
	#NAME     archaea
	if($line =~ /^NAME\s+(\S+)/) { 
	    $cm_name = $1;
	    $cms_read .= "\t$cm_name\n";
	    if(($opt_HR->{"-n"} eq "") || # -n not enabled
	       ($opt_HR->{"-n"} ne "") && ($cm_name eq $opt_HR->{"-n"})) { #-n enabled and we have a match!
		push(@{$indi_cm_name_AR}, $cm_name);
		if(exists($cm_name_exists_H{$cm_name})) { 
		    PrintErrorAndExit("ERROR, two CMs in CM file $cm_file have the name $cm_name. Each CM must have a unique name.", $sum_file, $log_file, 1); 
		}
		$cm_name_exists_H{$cm_name} = 1;
		
		if($cm_name eq $globals_HR->{"DF_NO_NAME"}) { 
		    PrintErrorAndExit("ERROR, you can't use a CM with the name " . $globals_HR->{"DF_NO_NAME"} . ", that's reserved for indicating which sequences are not the best-match to any models.", $sum_file, $log_file, 1); 
		}
		if(($opt_HR->{"--aln-one"} ne "") && ($cm_name eq $opt_HR->{"--aln-one"})) { 
		    $found_aln_one_name = 1; 
		}
		if(($opt_HR->{"-n"} ne "") && ($cm_name eq $opt_HR->{"-n"})) { 
		    $found_only_name = 1; 
		}
	    }
	}
    }
    close(CM);
    my $ncm = scalar(@{$indi_cm_name_AR});
    if(($opt_HR->{"--aln-one"} ne "") && (! $found_aln_one_name)) { 
	PrintErrorAndExit(sprintf("\nERROR, --aln-one %s enabled, but no CM named %s exists in $cm_file.\nCMs that do exist are:\n$cms_read\n", $opt_HR->{"--aln-one"}, $opt_HR->{"--aln-one"}), $sum_file, $log_file, 1);
    }
    if(($opt_HR->{"-n"} ne "") && (! $found_only_name)) { 
	PrintErrorAndExit(sprintf("\nERROR, -n %s enabled, but no CM named %s exists in $cm_file.\nCMs that do exist are:\n$cms_read\n", $opt_HR->{"-n"}, $opt_HR->{"-n"}), $sum_file, $log_file, 1);
    }
    if(($opt_HR->{"--no-search"}) && ($ncm > 1)) { 
       	PrintErrorAndExit("ERROR, the --no-search option only works if either -n <s> is used or the CM file contains exactly 1 CM.\n$cm_file has $ncm CMs in it.", $sum_file, $log_file, 1);
    }

    $$ssualign_R = $ssualign;
    $$ssumerge_R = $ssumerge;
    $$cmsearch_R = $cmsearch;
    $$cmalign_R  = $cmalign;
    $$reformat_R = $reformat;
    $$sfetch_R   = $sfetch;
    $$seqstat_R  = $seqstat;
    $$weight_R   = $weight;
    $$cm_file_R  = $cm_file;

    return;
}									 


#####################################################################
# Subroutine: CreateSsuAlignOutputDir()
# Incept:     EPN, Mon Nov  3 15:22:26 2008
# 
# Purpose:    Create a new directory <$outdir> for the output files. 
#
#             If the directory already exists and contains subdirectories
#             with names suggesting they were created by ssu-align, then
#             delete all files within $outdir only if $opt_HR->{"-f"} 
#             is '1'. 
#
#             If the directory already exists and does not contain 
#             subdirectories that appear to have been created by 
#             ssu-align, delete all of the files within it only if
#             $opt_HR->{"-f"} is '1'.
#
# Arguments:  
# $out_dir:   directory to create
# $out_root:  lowest level subdirectory in $out_dir (same as $out_dir if $out_dir contains 0 subdirs)
# $opt_HR:    reference to the hash of command-line options
# $sum_file:  summary file, created (opened) here
# $log_file:  log file, created (opened) here
#
# Returns:    Nothing.
#
# Exits:      If the directory already exists and <$do_clobber> is
#             FALSE. If a system call unexpectedly fails and returns 
#             a non-zero status code. 
# 
####################################################################
sub CreateSsuAlignOutputDir { 
    my $narg_expected = 5;
    if(scalar(@_) != $narg_expected) { printf STDERR ("\nERROR, CreateSsuAlignOutputDir() entered with %d != %d input arguments.\n", scalar(@_), $narg_expected); exit(1); } 
    my($out_dir, $out_root, $opt_HR, $sum_file, $log_file) = @_;

    my ($command, $tmp, $command_worked, $ran_command, $output, $errmsg);
    $ran_command = 0;
    my $retval = 0;
    my $status = 0;

    # create output directory
    if(-f $out_dir) { 
	printf STDERR ("\nERROR, $out_dir was specified as the output directory, but a file with the same name exists. Delete it and rerun.\n");
	exit(1);
    }
    if(-d $out_dir) { 
	if(! $opt_HR->{"-f"}) { 
	    printf STDERR ("\nERROR, output directory $out_dir already exists. Delete it or use -f to overwrite it.\n");
	    exit(1);
	}
	# if we get here, $out_dir exists, but either it has no subdirectories, -f was enabled, or both
	# remove the contents of the directory with rm -rf and remove the directory
	$command = "rm -rf $out_dir 2>&1";
	system "$command"; 
	$status = $?;
        # Note: we can't use RunCommand, b/c that requires a output file to write to, which will be put
	# into $out_dir, and since that hasn't been created yet, we can't write to it. Instead if the command
	# succeeds, we write it to the log file at the end of the function.
	if   (($status&255) != 0) { $retval = ($status&255); }
	elsif(($status>>8) != 0)  { $retval = ($status>>8);  }
	else { $retval = $status; }
	if($retval != 0) { printf STDERR "\nERROR, the command \"rm -rf $out_dir did not successfully complete."; exit(1); }
	$ran_command = 1;
	if(-d $out_dir) { printf STDERR "\nERROR, output directory $out_dir still exists after the command \"rm -rf $out_dir\".\n"; exit(1); }
    }

    # make the directory 
    if(! mkdir($out_dir)) { 
	printf STDERR "ERROR, unable to make directory $out_dir with PERL's mkdir command.";
	exit(1); 
    }

    # open the sum and log files
    open(OUT, ">" . $sum_file) || die "\nERROR, creating file $sum_file.\n";
    close(OUT);
    open(OUT, ">" . $log_file) || die "\nERROR, creating file $log_file.\n";
    close(OUT);

    #if we did a 'rm -rf' command, print that to the log file:
    if($ran_command) { 
	PrintStringToFile($log_file, 0, ("Executing:      " . $command . "\n"));
	PrintStringToFile($log_file, 0, ("Returned:       " . $retval . "\n"));
    }
    return;
}


#####################################################################
# Subroutine: AppendSsuAlignOptionsUsage()
# Incept:     EPN, Wed Apr 14 08:45:08 2010
# 
# Purpose:    Append usage strings for 'ssu-align' options that get
#             printed by both 'ssu-align' and 'ssu-prep'.
#
# Arguments:  
# $options_usage_R: REFERENCE to the options usage string to append to
# $caller_is_prep:  '1' (TRUE) if caller is ssu-prep, else '0' (FALSE)
#
# Returns:    Nothing. Updates $$options_usage_R.
#
####################################################################
sub AppendSsuAlignOptionsUsage { 
    my $narg_expected = 2;
    if(scalar(@_) != $narg_expected) { printf STDERR ("\nERROR, CreateSsuAlignOutputDir() entered with %d != %d input arguments.\n", scalar(@_), $narg_expected); exit(1); } 
    my($options_usage_R, $caller_is_prep) = @_;

    if($caller_is_prep) { $$options_usage_R .= "\ngeneral options to use for ssu-align jobs:\n"; }
    if(! $caller_is_prep) { 
	$$options_usage_R .= "  -f     : force; if dir named <output dir> already exists, empty it first\n";
    }
    $$options_usage_R .= "  -m <f> : use CM file <f> instead of the default CM file\n";
    $$options_usage_R .= "  -b <x> : set minimum bit score of a surviving subsequence as <x> [default: 50]\n";
    $$options_usage_R .= "  -l <n> : set minimum length    of a surviving subsequence as <n> [default: 1]\n";
    $$options_usage_R .= "  -i     : output alignments in interleaved Stockholm format (not 1 line/seq)\n";
    $$options_usage_R .= "  -n <s> : only search with and align to single CM named <s> in CM file\n"; 
    $$options_usage_R .= "           (default CM file includes 'archaea', 'bacteria', 'eukarya')\n";
    
    $$options_usage_R .= "\nmiscellaneous output options"; 
    if($caller_is_prep) { $$options_usage_R .= " for ssu-align jobs"; }
    $$options_usage_R .= ":\n"; 
    $$options_usage_R .= "  --dna      : output alignments as DNA, default is RNA (even if input is DNA)\n";
    $$options_usage_R .= "  --rfonly   : discard inserts, only keep consensus (nongap RF) columns in alignments\n";
    $$options_usage_R .= "               (alignments will be fixed width but won't include all target nucleotides)\n";
    
    #if(! $caller_is_prep) { 
    #$$options_usage_R .= "\noptions for merging parallelized ssu-align jobs:\n";
    #$$options_usage_R .= "  --merge <n>      : once finished, merge <n> parallel jobs created by ssu-prep\n";
    #$$options_usage_R .= "  --keep-merge <n> : w/--merge, do not remove smaller files as they're merged\n";
    #}
    
    $$options_usage_R .= "\noptions for skipping the 1st (search) stage or 2nd (alignment) stage";
    if($caller_is_prep) { $$options_usage_R .= " in ssu-align"; }
    $$options_usage_R .= ":\n"; 
    $$options_usage_R .= "  --no-align  : only search target sequence file for hits, skip alignment step\n";
    $$options_usage_R .= "  --no-search : only align  target sequence file, skip initial search step\n"; 
    
    $$options_usage_R .= "\nexpert options for tuning the initial search stage";
    if($caller_is_prep) { $$options_usage_R .= " in ssu-align jobs"; }
    $$options_usage_R .= ":\n"; 
    $$options_usage_R .= "  --toponly  : only search the top strand [default: search both strands]\n";
    $$options_usage_R .= "  --forward  : use the HMM forward algorithm for searching, not HMM viterbi\n";
    $$options_usage_R .= "  --global   : search with globally configured HMM [default: local]\n";
    $$options_usage_R .= "  --keep-int : keep intermediate files which are normally removed\n";
    
    $$options_usage_R .= "\nexpert options for tuning the alignment stage";
    if($caller_is_prep) { $$options_usage_R .= " in ssu-align jobs"; }
    $$options_usage_R .= ":\n"; 
    $$options_usage_R .= "  --aln-one <s> : only align best-matching sequences to the CM named <s> in CM file\n";
    $$options_usage_R .= "  --no-trunc    : do not truncate seqs to HMM predicted start/end, align full seqs\n";
    #$$options_usage_R .= "  --filter <f>  : filter aln based on seq identity, allow no 2 seqs > <f> identical\n";
    $$options_usage_R .= "  --no-prob     : do not append posterior probabilities to alignments\n";
    $$options_usage_R .= "  --mxsize <f>  : increase mx size for cmalign to <f> Mb [default: 4096]\n";

    return;
}

####################################################################
# the next line is critical, a perl module must return a true value
return 1;
####################################################################


