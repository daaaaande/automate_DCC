#/usr/bin/perl -w
use strict;

`clear`;

# cd /find_circ/dcc/automate_DCC
# copy infile to /find_circ/dcc/
# perl auto_automaker.pl infile


open(ER,'>>',"/home/daniel/logfile_auto.log")||die "$!";		# global logfile

chdir "/media/daniel/NGS1/RNASeq/find_circ/dcc";		# expects infile in parent dir, where all the processing will be handled

my$inputfile=$ARGV[0];
chomp$inputfile;
open(IN,$inputfile)|| die "$!";	# infile is a .csv file steptwo output.csv
my@lines=<IN>;
my$error="";# collecting dump
my@groups=();
my$errortwo="";
my$errthre="";


my$ndir=$ARGV[1];
chomp $ndir;
mkdir "$ndir";



foreach my $singleline (@lines){
	if($singleline =~ /[A-z]/gi){
		chomp $singleline;
		my@lineparts=split(/\s+/,$singleline);
		my$fileone=$lineparts[0];
		my$filetwo=$lineparts[1];
		my$samplename=$lineparts[2];
			$samplename=~s/\-/_/g;# avoid - in samplenames
		my$groupname=$lineparts[3];
		if($groupname eq ""){ # empty or only space-char
			$groupname="default_group_$ndir";
		}
		chomp $samplename;
		chomp $fileone;
		chomp $filetwo;
		my$tim=localtime();
		print ER "##############################################################\n";
		print ER "starting @ $tim \nfinding circs in sample $samplename with DCC ...\n";

		$error=`perl automate_DCC/dcc_starter.pl $fileone $filetwo $samplename`;
		#my$err2=`perl  run_$samplename/CIRCexplorer_circ.txt run_$samplename/$samplename.processed.tsv $samplename`;
		# will dump file into run_$samplename/$samplename_processed.tsv, this to be done for every file

		print ER "errors:\n$error\n\n";
		$errthre=`rm run_$samplename/$samplename* `;
		print ER "errors removing tmpfiles for sample $samplename:\n $errthre\n";
		#deleting the copies of .fastq files afterwards in dcc and circexplorer to not crowd the hdd
	#	my$erdel=`rm $fileone $filetwo`;
		print ER "errors removing fastqs for sample $samplename:\n \n";
		if($groupname=~/[a-z]/gi){
			if(!(grep(/$groupname/,@groups))){ # check if group already present
				mkdir $groupname;		# IF NOT, MAKE GROUPDIR
				push(@groups,$groupname);
			}
		$errortwo=`cp run_$samplename/processed_run_$samplename.tsv $groupname/`;
		}

		print ER "errors auto_moving:\n$errortwo\n";
	}


}




foreach my $groupname (@groups){
	my$errseding=`sed -i '1d' $groupname/*.tsv`; # will remove first line from steptwo output i.e headers
	my$errcat=`cat $groupname/*.tsv >$groupname/allsites_bedgroup_$groupname.csv`;
	my$errmatxrix=`nice perl  automate_DCC/matrixmaker-V3_A.pl $groupname/allsites_bedgroup_$groupname.csv $groupname/allcircs_matrixout.txt`;
	my$matrtmaker=`perl automate_DCC/matrixtwo.pl $groupname/allcircs_matrixout.txt $groupname/allc_matrixtwo.tsv`;
	print ER "errors catting $groupname .csv files together:\n$errcat\n";
	my$cp_k=`cp $groupname/allsites_bedgroup_$groupname.csv $ndir/`;
	print ER "errors copying file$groupname/allsites_bedgroup_$groupname.csv  into $ndir : $cp_k\n";

	print ER "errors making matrix for $groupname/allsites_bedgroup_$groupname.csv :\n$errmatxrix\n";
	print ER "errors making second matrix for $groupname/allsites_bedgroup_$groupname.csv :\n$matrtmaker\n";

}

my$erralcat=`cat $ndir/*.csv >$ndir/$ndir.allbeds.dcc.out`;
my$er_check_in=`perl automate_DCC/matrix_infile_checker.pl $ndir/$ndir.allbeds.dcc.out`;
print "checking the infile for DCC matrix in $ndir ...\n$er_check_in \n";
my$erralm1=`nice perl automate_DCC/matrixmaker-V3_A.pl $ndir/$ndir.allbeds.dcc.out $ndir/allsamples_matrix.dcc.mat1`;
my$err_mat2=`perl automate_DCC/matrixtwo.pl $ndir/allsamples_matrix.dcc.mat1 $ndir/allsamples_m_heatmap.dcc.mat2`;

print ER "error making files in $ndir :\ncat:\t$erralcat\nmatrix 1 creation:\t$erralm1 \nmatrix 2 creation:\n$err_mat2\n";

# now copy two matrix files into find_circ dir
my$errtransfer=`cp $ndir/*.mat* /media/daniel/NGS1/RNASeq/find_circ/$ndir/`;
print ER "transfering matrix to find_circ dir errors: \n$errtransfer\n";

print ER "finished with all groups\n";
