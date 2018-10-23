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
my%mapping_hash;
foreach my $line (@allllines){
  # get scores and coordinates, match in later file
  my@loineparts=split(/\t/,$line);
  my$score = $loineparts[4];
  my$chrom=$loineparts[0];
  my$start=$loineparts[1];
  my$end=$loineparts[2];
  my$fullcoordsi="$chrom:$start-$end";
  $mapping_hash{"$fullcoordsi"}="$score";# coords as key, score as value
}
my@allmapco= keys(%mapping_hash);
open(OU,">",$outfile)|| die "$!";
# order has to be the same in those two files, otherwise this will not work
print OU "coord\tstrand\tsample\tnum_reads\tscore\tscore\tannotation\n";
# foreach line i.e circ candidate from dcc
for (my $var = 0; $var < scalar(@alllines); $var++) {
  my$countline=$alllines[$var];
  if(!($countline=~/Strand/)){ # header check
      my$cordline=$allllines[$var];
      my@count_line_parts=split(/\t/,$countline);# CircRNACount file
      my$chrom=$count_line_parts[0];
      my$start=$count_line_parts[1];
      $start=$start-1;
      my$end=$count_line_parts[2];
      my$fullcoords="$chrom:$start-$end";
      my$g="-1";
      # get quantification
      my$num_counts=$count_line_parts[4];# still right
      # get strand
      my$strand= $count_line_parts[3];
      # get annotation
      my$annot=$count_line_parts[8];
      # cleaning everything except first annotation
      if($annot=~/\,/){
        $annot=$`;
        #print "more than one annot!\n";
      }
      if((grep(/$fullcoords/,@allmapco))){
        $g=$mapping_hash{$fullcoords};
        #  print "found a match for $fullcoords\n";
      }
      my$line="$fullcoords\t$strand\t$samplename\t$num_counts\t$g\t$g\t$annot";
      $line=~s/\n//g;
      print OU "$line\n";
  }
}
