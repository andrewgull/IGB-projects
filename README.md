# IGB-projects
my scripts for [IGB](http://genebiology.ru/) related projects

- S2G.py - a script for joining satellite sequences according to "scheme" file. As input it takes fasta file with satellite sequences and scheme file representing their relative positions in a genome; the script outputs satellite sequences concatenated according to the scheme file.

  - *scheme.txt* - an example of scheme file
  - *satellites.fasta* - an example of satellites file
  - *genomes.fasta* - output example


- Population genetics scripts

   - *make_standard_table.R* reads genalex formatted file and outputs a table like:

    | Locus | Pop | N.alleles | H.exp | H.obs | AR |
    |-------|-----|-----------|-------|-------|----|
    | ...   |...  | ..........| ......| ......| ...|
    | Mean  |...  | ..........| ......| ......| ...|
    | SE    |...  | ..........| ......| ......| ...|
    |Total  |...  | ..........| ......| ......| ...|

   - *get_pop_diff.R* reads genalex formatted file and outputs Gst (both by Hedrick and Nei) and Jost's D as tables (tab-delimited) along with NJ trees built using Gst/D distances (in *nwk* and *png* formats)
