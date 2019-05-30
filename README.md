# PopGenScripts
my scripts for population genetics

- *make_standard_table.R* reads genalex formatted file and outputs a table like:

| Locus | Pop | N.alleles | H.exp | H.obs | AR |
|-------|-----|-----------|-------|-------|----|
| ...   |...  | ..........| ......| ......| ...|
| Mean  |...  | ..........| ......| ......| ...|
| SE    |...  | ..........| ......| ......| ...|
|Total  |...  | ..........| ......| ......| ...|

- *get_pop_diff.R* reads genalex formatted file and outputs Gst (both by Hedrick and Nei) and Jost's D as tables (tab-delimited) along with NJ trees built using Gst/D distances (in *nwk* and *png* formats)
