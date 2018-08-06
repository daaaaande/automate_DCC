#!/bin/bash	


#find_circ

bowtie2 -p 16 --very-sensitive --mm -M20 --score-min=C,-15,0 -x /path/to/bowtie2_index -q -1 /path/to/file1.fq.gz -2 /path/to/file2.fq.gz | samtools view -hbuS - | samtools sort - output

samtools view -hf 4 output.bam | samtools view -Sb - > unmapped.bam 

python unmapped2anchors.py unmapped.bam | gzip > anchors.qfa.gz

bowtie2 -p 16 --reorder --mm -M20 --score-min=C,-15,0 -q -x /path/to/bowtie2_index -U anchors.qfa.gz | python find_circ.py -G /path/to/chomosomes.fa -p prefix -s find_circ.sites.log > find_circ.sites.bed 2> find_circ.sites.reads

grep circ find_circ.sites.bed | grep -v chrM | python sum.py -2,3 | python scorethresh.py -16 1 | python scorethresh.py -15 2 | python scorethresh.py -14 2 | python scorethresh.py 7 2 | python scorethresh.py 8,9 35 | python scorethresh.py -17 100000 > finc_circ.candidates.bed



#circRNA_finder

./runStar.pl /path/to/file1.fq /path/to/file2.fq /path/to/star_index /path/to/star/output 

./postProcessStarAlignment.pl /path/to/star/output /path/to/circRNA_finder/output



#CIRI

bwa mem -t 16 -T 19 -v 2 /path/to/bwa_index /path/to/file1.fq /path/to/file2.fq >output.sam

perl CIRI_v1.2.pl -I output.sam -O /path/to/ciri/output.txt -F /path/to/genome.fa -P



#circExplorer

tophat2 -a 6 --microexon-search -m 2 -p 16 -o circExplorer_output /path/to/bowtie1_index /path/to/file1.fq.gz /path/to/file2.fq.gz

bamToFastq -i circExplorer_output/unmapped.bam -fq circExplorer_output/unmapped.fastq

tophat2 -o circExplorer_output -p 16 --fusion-search --keep-fasta-order --bowtie1 --no-coverage-search path/to/bowtie2_index circExplorer_output/unmapped.fastq

python CIRCexplorer.py -f circExplorer_output/accepted_hits.bam -g /path/to/genome.fa -r /path/to/gene_annotation_ucsc_hg19.txt -o output.txt 



#MapSplice

python MapSplice-v2.1.8/mapsplice.py -1 /path/to/file1.fq -2 file2.fq -c /path/to/chromosome_sequences -x /path/to/bowtie1_index -p 16 -o Mapsplice_output --min-fusion-distance 200 --gene-gtf Homo_sapiens.GRCh37.66.gtf --fusion 





