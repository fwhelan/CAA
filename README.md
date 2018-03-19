# CAA

Conjunctive Assembly Approach (CAA) for Culture-Enriched MetaGenomics (CEMG)  

CAA is an assembly approach to pull out sequences with significant kmer overlap across a sample list. Originally, CAA was applied to a set of cultured plates in order to pull out intersecting reads. At the end of the CAA algorithm, any read not accounted for in an intersection is output into a separate uniques file; the combination of the intersection and unique files will contain exactly the number of reads in the sample list.  

CAA is an algorithm based upon the ideas in SAcounter and CoSA; if you use CAA, you should cite SAcounter (http://omics.informatics.indiana.edu/mg/SA/) and CoSA (https://sourceforge.net/projects/concurrentsa/).
