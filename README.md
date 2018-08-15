# automate_DCC
automating DCC circular RNA detection

## two major levels of automation:
- dcc_starter.pl runs the whole DCC pipeline for one sample (two reads, samplename); matrix has to be created manually after it finished.
- auto_automaker.pl runs DCC for how many lines are in the input file for it, summarizes for each group into a matrix.

## dcc_commands.txt
- shows the DCC commands that have benn automated with this tool here. however, you can change those if you prefer other filtering parameters
- can be ignored otherwise

# what you need:
- STAR Aligner
- DCC installed
- mapping files for annotation
- two reads for each sample, a samplename and a groupname for auto_automaker.pl



>> expect about ~ 20 minutes runtime per sample with 10 CPUs

## outfiles:
- for each sample, it creates a directory where it is started where all outputfiles  from dcc and the three(!) STAR alignemnts will be, additionally if you utilize groups it copies the .tsv files from dcc_outreader.pl into there and creates a matrixmaker.pl matrix

# this set of scripts is not mature
