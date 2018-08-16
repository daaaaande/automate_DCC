# automate_DCC
automating DCC circular RNA detection

## two major levels of automation:
1. dcc_starter.pl runs the whole DCC pipeline for one sample (two reads, samplename); matrix has to be created manually after it finished.
2. auto_automaker.pl runs DCC for how many lines are in the input file for it, summarizes for each group and all samples into a matrix.

3. let find_circ/godfather.pl handle it all, see find_circ/godfather.pl


## dcc_commands.txt
- shows the DCC commands that have benn automated with this tool here. however, you can change those if you prefer other filtering parameters
- can be ignored otherwise

# what you need (need to be in the parent directory, so wherever you stared the git clone command):

- STAR Aligner installed
- DCC installed
- mapping files for annotation (see auto_find_circ for links and instructions + you will need the STAR hg19 reference genome and in .gtf format)
- two reads for each sample, a samplename and a groupname for auto_automaker.pl

## how to run:
- copy the samplesheet into the parent dir
- go into the dir where these scripts are
- perl auto_automaker.pl samplesheet (auto_automaker looks for a samplesheet in the parent directory, where all the infiles need to be aswell)
- all dirs and files in these dirs will be created in the parent directory of the scripts, the script- containing dir will have no additional files after execution.
- the two input .fastq files will be deleted after the run was finished. so keep a copy somewhere else (auto_find_circ does not delete them, so maybe there)
## start auto_automaker.pl with inputfile1 inputfile2 samplename groupname table, separated by \t
```bash
~ head infiles_for_auto_automaker.txt   
lineonefile1 linetwofile1 samplename1 group1   
lineonefile2  linetwofile2  samplename2 group1
```    
the group will lead to auto_automaker making a directory named after the group where all the resulting .csv files will be copied into, catted into one big .csv file and then run matrixmaker.pl with this as an input and then start matrixtwo.pl with this as an input

>> expect about ~ 20 minutes runtime per sample with 10 CPUs

## outfiles:
- for each sample, it creates a directory where all outputfiles  from dcc and the three(!) STAR alignemnts will be
- additionally if you utilize groups it copies the .tsv files from dcc_outreader.pl into there and creates a matrixmaker.pl matrix
- and all processed.csv files will also get copied into the Day_Month dir created in the parent dir and two matrices will be created that contaion information fromm al samples in the samplesheet
# this set of scripts is not mature
