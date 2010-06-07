#!/usr/bin/perl
#
# stk2fa.pl 
# Eric Nawrocki
# EPN, Tue Aug 25 06:41:26 2009
#
# Usage: perl stk2fa.pl <non-interleaved stockholm alignment (1 line per sequence)>
# 
# Synopsis: Convert a non-interleaved (1-line-per-seq) stockholm alignment to a 
#           a 1-line-per-seq FASTA alignment.
#
# Options from:
#     -C : include #=GC <x> markup, named as "GC-<x>"
#     -R : include #=GR <x> <tag> markup, named as "GR-<x>-<tag>"
use Getopt::Std;
getopts('CR');
$do_GC = 0;
$do_GR = 0;
if(defined $opt_C) { $do_GC = 1; }
if(defined $opt_R) { $do_GR = 1; }

$usage =  "usage: perl stk2fa.pl [-options] <non-interleaved stockholm alnment (1 line per seq)>\n\n";
$usage .= "Options:\n\t";
$usage .= "-C : include #=GC <x> markup, named as \"GC-<x>\"\n\t";
$usage .= "-R : include #=GR <x> <tag> markup, named as \"GR-<x>-tag\"\n\n";
$usage .= "Note that the stockholm alignment must be non-interleaved.\n";
$usage .= "You can convert an interleaved ssu-align/cmalign output alignment \"foo.stk\"\n";
$usage .= "to non-interleaved \"foo2.stk\" with \"esl-reformat -o foo2.stk pfam foo.stk\"\n\n";

if(scalar(@ARGV) != 1){ 
    printf("$usage");
    exit(1);
}
($in_file) = $ARGV[0];

open(IN, $in_file);
%seq_exists_H = ();
while($line = <IN>) { 
    if($line !~ m/\S/) { 
	;
    }
    elsif($line =~ m/\/\//) { 
	;
    }
    elsif($line !~ m/^\#/) { 
	$line =~ s/\s+/\n/;
	printf("\>$line");
	$line =~ /(\S+).*/;
	if(exists($seq_exists_H{$1})) { 
	    printf STDERR ("\nERROR, more than one line of sequence $1. Use 'esl-reformat pfam' to de-interleave this stockholm alignment\n"); 
	    printf STDERR ("\n$usage");
	    exit(1); 
	}
	else { 
	    $seq_exists_H{$1} = 1; 
	}
    }
    elsif($do_GC && $line =~ s/^\#=GC\s+//)
    {
	chomp $line;
	($name, $seq) = split(/\s+/, $line);
	$newname = "GC-$name";
	printf("\>$newname\n$seq\n");
	if(exists($seq_exists_H{$newname})) { 
	    printf STDERR ("\nERROR, more than one line of \#=GC  $name. Use 'esl-reformat pfam' to de-interleave this stockholm alignment\n"); 
	    printf STDERR ("\n$usage");
	    exit(1); 
	}
	else { 
	    $seq_exists_H{$newname} = 1; 
	}
    }
    elsif($do_GR && $line =~ s/^\#=GR\s+//)
    {
	chomp $line;
	($name, $tag, $seq) = split(/\s+/, $line);
	$newname = "GR-$name-$tag";
	printf("\>$newname\n$seq\n");
	if(exists($seq_exists_H{$newname})) { 
	    printf STDERR ("\nERROR, more than one line of \#=GR $name $tag. Use 'esl-reformat pfam' to de-interleave this stockholm alignment\n"); 
	    printf STDERR ("\n$usage");
	    exit(1); 
	}
	else { 
	    $seq_exists_H{$newname} = 1; 
	}
    }
}
