#/usr/bin/perl -w
use strict;

# starting vars
my$currdir=`pwd`;
chdir "../";
my$starttime= time;

open(ER,'>>',"/home/daniel/logfile_auto.log")||die "$!";		# global logfile

system("rm Chimeric.out.junction");
system("rm fusion_junction.txt");

# first get reference place for hg19
my$bowtwiindexplace="/media/daniel/NGS1/RNASeq/find_circ/dcc/";

# change to reference place for execution
if(!($currdir eq $bowtwiindexplace)){
chdir $bowtwiindexplace;
}

my$infile1=$ARGV[0];
chomp $infile1;
my$infile2=$ARGV[1];
chomp $infile2;
my$samplename=$ARGV[2];
chomp $samplename;

print ER "-------------------------------------------------\nsample $samplename processing:\n";
#### start of dcc for this sample
mkdir "run_$samplename";

# go there

chdir "run_$samplename";


print ER "doing mate STAR alignment...\n";
# start DCC in find_circ/dcc/
# STAR --runThreadN 10 --genomeDir . --outSAMtype BAM SortedByCoordinate --readFilesIn HAL01_R1_trimmed.fastq HAL01_R2_trimmed.fastq --outFileNamePrefix halo1_r --outReadsUnmapped Fastx --outSJfilterOverhangMin 15 15 15 15 --alignSJoverhangMin 15 --alignSJDBoverhangMin 15 --outFilterMultimapNmax 20 --outFilterScoreMin 1 --outFilterMatchNmin 1 --outFilterMismatchNmax 2 --chimSegmentMin 15 --chimScoreMin 15 --chimScoreSeparation 10 --chimJunctionOverhangMin 15
my$tophatout=system("STAR --runThreadN 10 --genomeDir ../ --outSAMtype BAM SortedByCoordinate --readFilesIn ../$infile1 ../$infile2 --outFileNamePrefix $samplename. --outReadsUnmapped Fastx --outSJfilterOverhangMin 15 15 15 15 --alignSJoverhangMin 15 --alignSJDBoverhangMin 15 --outFilterMultimapNmax 20 --outFilterScoreMin 1 --outFilterMatchNmin 1 --outFilterMismatchNmax 2 --chimSegmentMin 15 --chimScoreMin 15 --chimScoreSeparation 10 --chimJunctionOverhangMin 15");
# creates auto_$samplename dir in test/
print ER "errors during STAR alignment:\n $tophatout\n";


# mate1 and
# mate2 need to get remaned files aswell


my$laneonename="lane_1$samplename";
my$lanetwoname="lane_2$samplename";
# alignment first read .fastq file
print ER "doing line 1 STAR alignment...\n";

my$err_star_line1=system("STAR --runThreadN 10 --genomeDir ../ --outSAMtype None --readFilesIn ../$infile1 --outFileNamePrefix $laneonename. --outReadsUnmapped Fastx --outSJfilterOverhangMin 15 15 15 15 --alignSJoverhangMin 15 --alignSJDBoverhangMin 15 --seedSearchStartLmax 30 --outFilterMultimapNmax 20 --outFilterScoreMin 1 --outFilterMatchNmin 1 --outFilterMismatchNmax 2 --chimSegmentMin 15 --chimScoreMin 15 --chimScoreSeparation 10 --chimJunctionOverhangMin 15");
print ER "errors during STAR lane 1 alignment:\n $err_star_line1\n";

print ER "doing line 2 STAR alignment...\n";

my$err_star_line2=system("STAR --runThreadN 10 --genomeDir ../ --outSAMtype None --readFilesIn ../$infile2 --outFileNamePrefix $lanetwoname. --outReadsUnmapped Fastx --outSJfilterOverhangMin 15 15 15 15 --alignSJoverhangMin 15 --alignSJDBoverhangMin 15 --seedSearchStartLmax 30 --outFilterMultimapNmax 20 --outFilterScoreMin 1 --outFilterMatchNmin 1 --outFilterMismatchNmax 2 --chimSegmentMin 15 --chimScoreMin 15 --chimScoreSeparation 10 --chimJunctionOverhangMin 15");
print ER "errors during STAR lane 2 alignment:\n $err_star_line2\n";


#now we have
#run_$samplename/$samplenameChimeric.out.junction for sample1
#run_$samplename/lane_1$samplenameChimeric.out.junction for lane 1
#run_$samplename/lane_2$samplenameChimeric.out.junction for lane 2

##
# run dcc
my$bothlanesname="$samplename.Chimeric.out.junction";
##
print ER "running dcc..\n";
my$dcc_err=system("DCC $bothlanesname -mt1 $laneonename.Chimeric.out.junction -mt2 $lanetwoname.Chimeric.out.junction -D -fg -an ../hg19_ens.gtf -Pi -M -Nr 1 1 -A ../hg19.fa -N -T 10 -an ../all_ref.gtf");
print ER "errors running dcc: $dcc_err\n";

# seding, removing headers
print ER "removing header from CircRNACount...\n";
#my$line=qq{"sed -i '1d' CircRNACount"};
my$sed=`sed -i '1d' CircRNACount`;
print "errors removing headers:\n$sed\n";

# bedtools annotations
print ER "using bedtools for annotation of CircRNACount file for $samplename...\n";
my$betout=system("bedtools window -a CircRNACount -b /media/daniel/NGS1/RNASeq/find_circ/bed_files/Genes_RefSeq_hg19_09.20.2013.bed -w 1 >CircRNACount_annotated.tsv");
print ER "errors annotating $samplename :\n$betout\n";



# now parsing the output
print ER "parsing in run_$samplename ...\n";
my$err_running_dcc_outreader=system("perl ../automate_DCC/dcc_outreader.pl CircRNACount_annotated.tsv CircCoordinates processed_run_$samplename.tsv $samplename");
print ER "errors parsing in run_$samplename/ : \n$err_running_dcc_outreader\n";

print ER "############################################################\nsample $samplename done :\n";

my$total_time=((time)-$starttime)/60;
print ER "done. \n\n took $total_time minutes for sample $samplename\n";
