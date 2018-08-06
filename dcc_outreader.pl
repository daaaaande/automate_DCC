#/usr/bin/perl -w
use strict;

# starting vars
my$currdir=`pwd`;
my$starttime= time;

my$infile=$ARGV[0];# CircRNACount file
chomp $infile;
my$linfile=$ARGV[1];# CircCoordinates file
chomp $linfile;
# outfile
my$outfile=$ARGV[2];
chomp $outfile;
my$samplename=$ARGV[3];
chomp $samplename;

open(IN,$infile)|| die "$!";
my@alllines=<IN>;
open(IZ,$linfile)|| die "$!";
my@allllines=<IZ>;



open(OU,">",$outfile)|| die "$!";
# order has to be the same in those two files, otherwise this will not work
print OU "coord\tstrand\tsample\tnum_reads\tscore\tscore\tannotation\n";
# foreach line i.e circ candidate from dcc
for (my $var = 0; $var < scalar(@alllines); $var++) {
  # body...

  my$countline=$alllines[$var];
  if(!($countline=~/Strand/)){ # header check
      my$cordline=$allllines[$var];
      my@count_line_parts=split(/\t/,$countline);# CircRNACount file
      my@cord_line_parts=split(/\t/,$cordline);# CircCoordinates file
      # build coordinates
      my$chrom=$count_line_parts[0];
      my$start=$count_line_parts[1];
      my$end=$count_line_parts[2];
      my$fullcoords="$chrom:$start-$end";
      # get quantification
      my$num_counts=$count_line_parts[4];
      # get strand
      my$strand= $count_line_parts[3];
      # small sanity check
      if($count_line_parts[1] ne $cord_line_parts[1]){
        die "coordinates in both files are not the same!\n";
      }
      # get annotation
      my$annot=$cord_line_parts[3];
      # cleaning of annotation ?


      # score is here junctiontype parameter from dcc
      my$score=$cord_line_parts[4];
      my$line="$fullcoords\t$strand\t$samplename\t$num_counts\t$score\t$score\t$annot";
      $line=~s/\n//g;
      print OU "$line\n";
  }

}
