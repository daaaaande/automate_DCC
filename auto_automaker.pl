#/usr/bin/perl -w
use strict;

system("clear");

# cd /find_circ/dcc/automate_DCC
# copy infile to /find_circ/dcc/
# perl auto_automaker.pl infile


open(ER,'>>',"/home/daniel/logfile_auto.log")||die "$!";		# global logfile

chdir "../";

my$inputfile=$ARGV[0];
chomp$inputfile;
open(IN,$inputfile)|| die "$!";	# infile is a .csv file steptwo output.csv
my@lines=<IN>;
my$error="";# collecting dump
my@groups=();
my$errortwo="";
my$errthre="";
foreach my $singleline (@lines){
	if($singleline =~ /[a-z]/gi){
		chomp $singleline;
		my@lineparts=split(/\s+/,$singleline);
		my$fileone=$lineparts[0];
		my$filetwo=$lineparts[1];
		my$samplename=$lineparts[2];
		my$groupname=$lineparts[3];
		chomp $samplename;
		chomp $fileone;
		chomp $filetwo;
		my$tim=localtime();
		print ER "##############################################################\n";
		print ER "starting @ $tim \nfinding circs in sample $samplename with DCC ...\n";

		$error=system("perl automate_DCC/dcc_starter.pl $fileone $filetwo $samplename");
		#my$err2=system("perl  run_$samplename/CIRCexplorer_circ.txt run_$samplename/$samplename.processed.tsv $samplename");
		# will dump file into run_$samplename/$samplename_processed.tsv, this to be done for every file

		print ER "errors:\n$error\n\n";
		$errthre=system("rm run_$samplename/$samplename* ");
		print ER "errors removing tmpfiles for sample $samplename:\n $errthre\n";
		if($groupname=~/[a-z]/gi){
			if(!(grep(/$groupname/,@groups))){ # check if group already present
				mkdir $groupname;		# IF NOT, MAKE GROUPDIR
				push(@groups,$groupname);
			}
		$errortwo=system ("cp run_$samplename/processed_run_$samplename.tsv $groupname/");
		}

		print ER "errors auto_moving:\n$errortwo\n";
	}


}

my$date= localtime();
$date=~s/\s+/_/g;
$date=~s/[0-9]//g;
$date=~s/\://g;
$date=~s/\_\_//g;
mkdir "all_run_$date";


foreach my $groupname (@groups){
	my$errseding=system("sed -i '1d' $groupname/*.tsv"); # will remove first line from steptwo output i.e headers
	my$errcat=system("cat $groupname/*.tsv >$groupname/allsites_bedgroup_$groupname.csv");
	my$errmatxrix=system("perl automate_DCC/matrixmaker.pl $groupname/allsites_bedgroup_$groupname.csv $groupname/allcircs_matrixout.txt");
	my$matrtmaker=system("perl automate_DCC/matrixtwo.pl $groupname/allcircs_matrixout.txt $groupname/allc_matrixtwo.tsv");
	print ER "errors catting $groupname .csv files together:\n$errcat\n";
	system("cp $groupname/allsites_bedgroup_$groupname.csv all_run_$date/");

	print ER "errors making matrix for $groupname/allsites_bedgroup_$groupname.csv :\n$errmatxrix\n";
	print ER "errors making second matrix for $groupname/allsites_bedgroup_$groupname.csv :\n$matrtmaker\n";

}

my$erralcat=system("cat all_run_$date/* >all_run_$date.allbeds.dcc.out");
my$erralm1=system("perl matrixmaker.pl all_run_$date/all_run_$date.allbeds.dcc.out all_run_$date/allsamples_matrix.dcc.tsv");
my$err_mat2=system("perl matrixtwo.pl all_run_$date/allsamples_matrix.dcc.tsv all_run_$date/allsamples_m_heatmap.dcc.tsv");

print ER "error making files in all_run_$date :\ncat:\t$erralcat\nmatrix 1 creation:\t$erralm1 \nmatrix 2 creation:\n$err_mat2\n";

# now copy two matrix files into find_circ dir
my$errtransfer=system("cp all_run_$date/*.tsv /media/daniel/NGS1/RNASeq/find_circ/all_run_$date/");
print ER "transfering matrix to find_circ dir errors: \n$errtransfer\n";

print ER "finished with all groups\n";
