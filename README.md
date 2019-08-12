# AllEnricher 

### A comprehensive gene set function enrichment tool for multiple species.

------

```
  0.Introduction
  1.System Requirements
  2.Installation
  3.Usage
  4.Output files
  5.Copyright
  6.Contact information
```

# 0.Introduction

This is a tool designed for functional genomic and large-scale genetic studies from which large number of gene lists (e.g. differentially expressed gene sets, co-expressed gene sets, or differential epigenomic
modification gene sets etc) are continuously generated. AllEnricher incorporates information from different public resources and provides an easy way for biologists to make sense out of gene lists.

The advantages of this tool include:

**A. Comprehensive function interpretation support**

The same gene set provided by users could be interpreted from multiple aspects according to their purpose, which including:

- Gene ontology
- KEGG pathway
- Reactome pathway
- Disease ontology (for human)
- DisGeNET disease (for human)

Besides, gene-function annotations based on various kind of library will be integrated as local library of AllEnricher to satisfy researches in different filed in the future, based on current program framework.

**B. Multiple species support**

- Gene ontology analysis for 15464 species

- Disease analysis for *Homo sapiens*

- KEGG pathway analysis for all the species in KEGG Organism (https://www.kegg.jp/kegg/catalog/org_list.html), including 498 eukaryotes, 5159 bacteria and 296 archaea.

- Reactome pathway for all the 16 kind of model species in Reactome, including:

  *Bos taurus*

  *Caenorhabditis elegans*

  *Canis familiaris*

  *Danio rerio*

  *Dictyostelium discoideum*

  *Drosophila melanogaster*

  *Gallus gallus*

  *Homo sapiens*

  *Mus musculus*

  *Mycobacterium tuberculosis*

  *Plasmodium falciparum*

  *Rattus norvegicus*

  *Saccharomyces cerevisiae*

  *Schizosaccharomyces pombe*

  *Sus scrofa*

  *Xenopus tropicalis*

**C. Customized library update**

The local library was built based on public resources that are frequently updated (Figure 1a), and several simple commands were designed for easy update. Users could obtain the latest data as they need.

**D. Easy to use and embeddable**

Simple installation requirements. Once you finished library construction, only one command is required for gene set enrichment analysis and visualization. Since most bioinformatic pipelines of function genomic studies are deployed on the Unix platform, it is convenient for users to integrating AllEnricher into their pipelines to facilitating analysis.

# 1.System Requirements

Unix system and common Unix utilities like sort, uniq, gzip, cat, zcat etc.
 should be available.

Perl version >= 5.10.1

with module installed:

- *PerlIO::gzip*
- *FindBin*

R version >= 3.2

with package installed: 

- *RCurl*
- *XML*
- *ggplot2*



# 2.Installation

Create a directory where you plan the package to reside. Copy the downloaded archive there, then unpack it using a command like this:

 

```shell
tar zxvf AllEnricher-v1.0.tar.gz

```

 
This should unpack a few files in the current directory and will create a bin subdirectory with several files. 
Once unpacked successfully, the installation script will detect and install the dependent R packages and perl modules to the default perl and R of your system:

```
cd AllEnricher-v1.0
sh install.sh
```

or, specify the perl and Rscript program you want to use:

```
sh install.sh -P /usr/bin/perl -R /usr/bin/Rscript
```

There are four main scripts in the main directory:

> AllEnricher

> update_GOdb

> update_ReactomeDB

> make_speciesDB

They will invoke the scripts in the directory `./src`.
All the scripts have the perl/shell/R location as the first line, set to 

```perl
#!/usr/bin/perl
```

or

```shell
#!/bin/bash
```

or

```R
#!/usr/bin/Rscript
```

If this is not the valid path for your perl/shell/R installation, you need to change these lines in all the files to point to your actual perl/shell/R binary location.

# 3.Usage

#### 3.1 Local gene set library construction

Before the users could use the tool, the library need to be updated.

Otherwise, it will use the default old library instead, which was build 

on 6-12-2019 by the author.

##### 3.1.1 Update the Gene Ontology (GO) library for AllEnricher

To update GO library for AllEnricher, just type:

```shell
./make_speciesDB
```

This will download the up to date `gene2go`and `gene_info`file from NCBI, `obo` file from Gene Ontology and `gaf` file from Gene Ontology Annotation. The file size is about:

> 23 M	gene2go.gz

> 477 M	gene_info.gz

> 7.3 G	goa_uniprot_all.gaf.gz

> 31 M	go-basic.obo

So, This will take some time to finish the update depending on your network.
The updated library will be named as \"GO+current date\"
at this path: `./database/basic/go/`

##### 3.1.2 Update the Reactome library for AllEnricher

To update Reactome library for AllEnricher, just type:

```shell
./make_ReactomeDB
```

This will download the up to date `gene_info` file from NCBI and 
`NCBI2Reactome_All_Levels` file from Reactome. The file size is about:

> 480 M	gene_info.gz

> 7.3 M	NCBI2Reactome_All_Levels.txt.gz

So, This will take some time to finish the update depending on your network.
The new build library will be named in \"Reactome+current date\" at this path: `./database/basic/reactome/`

##### 3.1.3 Build local GO/KEGG/Reactome/DO/DisGeNET library for specified species 

In this step, 
Local GO library and Reactome library for specified species are build on the established databse in step 3.1.1 and 3.1.2 ;

Local KEGG library for specified species are build from the web server of KEGG;

Local Disease Ontology (DO) library for `human` is build based on DISEASES database (https://diseases.jensenlab.org/) ;

Local DisGeNET library for `human` is build based on DisGeNET database (http://disgenet.org/home/).

For example, to build the GO/KEGG/DO/Reactome library for human,  just type:

```shell
./make_speciesDB -s hsa -i 9606 -R /usr/bin/Rscript
```

The program will use the most recent GO and Reactome library version in these path as default. 

or, you can specify the GO and Reactome library you had build in

 `./database/basic/go/` and  `./database/basic/reactome/` 

by type:

```shell
./make_speciesDB -vg GO20190612 -vr Reactome20190612 -s hsa -i 9606 -R /usr/bin/Rscript

```

This will take some time to finish the update depending on your network.

The new build library will be named in \"v+current date\" at this path:

`./database/organism/v20190612/hsa/`

The program had build the library for several species in the default version of library.

The species abbrev and the taxonomy ID of these established library are listed in this table:

|    Species name     | Species abbrev | Taxonomy ID |
| :-----------------: | :------------: | :---------: |
|   *Homo sapiens*    |      hsa       |    9606     |
|   *Mus musculus*    |      mmu       |    10090    |
| *Rattus norvegicus* |      rno       |    10116    |
|    *Sus scrofa*     |      ssc       |    9823     |

#### 3.2 Run enrichment analyses and visualization

Once all the library for a specified species had build, the users could conduct the gene set enrichment analyses in just one single command.

Take the gene set in the `./example` file as example, just type:

```shell
./AllEnricher -l example.glist -s hsa -v v20190612 -o ./allenricher/ -r /usr/bin/Rscript -m GO+KEGG+Reactome+DO+DisGeNET

```

Note to select appropriate kind of analyses from GO, KEGG, Reactome, DO and DisGeNET according to your interests and under the  support of AllEnricher library.

The user guide is summarized as follows:
![image](https://github.com/zd105/AllEnricher/blob/master/AllEnricher_workflow.jpg)

# 4.Output files

The program creates a few working files during the library establishment and enrichment process and several output files to be further processed by the user (the library files).

#### 4.1 Local gene set library files

Assuming the GO and Reactome database is built on June 12, 2019. For the GO database updated by the script  `update_GOdb`,  this will creates the necessary search files for the GO database establishment for specified species in path:  `./database/basic/go/GO20190612/` 

> gene2go.gz

> gene_info.gz

> goa_uniprot_all.gaf.gz

> go-basic.obo

Similar database files will generate by `update_ReactomeDB` for Reactome database in path: `./database/basic/reactome/Reactome20190612/`

> gene_info.gz

> NCBI2Reactome_All_Levels.txt

Assuming all the database of human is built on June 12, 2019. For all the database build for specified species by `make_speciesDB`, it will generate several  files in path: `./database/organism/v20190612/hsa/`

> hsa.gene2go.txt

> hsa.gene_info

> hsa.gene2pathway.txt

> hsa.GO2gene.tab.gz

> hsa.GO2disc.gz

> hsa.kegg2gene.tab.gz

> hsa.kegg2disc.gz

> hsa.DO2gene.tab.gz

> hsa.DO2disc.gz

> hsa.Reactome2gene.tab.gz

> hsa.Reactome2disc.gz

> hsa.CUI2gene.tab.gz

> hsa.CUI2disc.gz

#### 4.2 Enrichment output files

The main program AllEnricher will generate several result files according to the `test method` and `Q-value` of enrichment specified by the user. Take the test data as example, the output files and the file tree are: 

```shell
example/
├── allenricher
│   ├── example.glist
│   └── fisher
│       └── Q0.05
│           ├── example.glist.DisGeNET_barplot.top20.pdf
│           ├── example.glist.DisGeNET_bubbleplot.top20.pdf
│           ├── example.glist.DisGeNET.xls
│           ├── example.glist.DO_barplot.pdf
│           ├── example.glist.DO_bubbleplot.pdf
│           ├── example.glist.DO.xls
│           ├── example.glist.GO_barplot.top20.pdf
│           ├── example.glist.GO_bubbleplot.top20.pdf
│           ├── example.glist.GO.xls
│           ├── example.glist.KEGG_barplot.pdf
│           ├── example.glist.KEGG_bubbleplot.pdf
│           ├── example.glist.KEGG.xls
│           ├── example.glist.Reactome_barplot.top20.pdf
│           ├── example.glist.Reactome_bubbleplot.top20.pdf
│           └── example.glist.Reactome.xls
├── example.glist
└── example.sh

```

 The `*.xls` files are the enrichment output tables, a special tab delimited format where each line has the following tab delimited fields:

 **1) TermID:** GO term ID, DO term ID, KEGG pathway ID or Reactome pathway ID.

 **2) TermGeneNum:** Gene number of this term/pathway in the background gene set.

 **3) ObservedGeneNum:** Observed gene number of this term/pathway in the customized gene set.

 **4) ExpectedGeneNum:** Expected gene number of this term/pathway in the customized gene set.
             
ExpectedGeneNum = CategoryGeneNum / BackgroundGeneNum * AnnotatedGenelistNum


 **5) RichFactor:** ObservedGeneNum/ExpectedGeneNum.

 **6) rawP:** p value of Fisher's exact test or hypergeometric test.

 **7) adjP:** adjusted p value by multiple hypothesis testing.

 **8) TermName:** Term/Pathway name.

 **9) GeneList:** List of observed genes in the customized gene set.

The `*barplot.pdf` files and the `*bubbleplot.pdf` files are the visualization plot of the corresponding enrichment results.

1) Bar plot (KEGG pathway enrichment)
![image](https://github.com/zd105/AllEnricher/blob/master/example_barplot.jpg)

2) Bubble plot (GO term enrichment)
![image](https://github.com/zd105/AllEnricher/blob/master/example_bubbleplot.jpg)


# 5.Copyright

Copyright (c) 2019, NEO Institute, All Rights Reserved.

This software is OSI Certified Open Source Software.
OSI Certified is a certification mark of the Open Source Initiative.




# 6.Contact

This bioinformatics tool is available at github page at: https://github.com/zd105/AllEricher

For problems and questions related to this program please contact Du Zhang
at zhangducsu@163.com . 
