## pubmed

`pubmed` is an `R` package to download and parse XML documents from [Pubmed Central](http://www.ncbi.nlm.nih.gov/pmc) (PMC).  There are over 2.7 million full-text articles in PMC and 22% are available for text mining in the [Open Access](http://www.ncbi.nlm.nih.gov/pmc/tools/openftlist) (OA) subset.  The number of OA publications is increasing rapidly each year and 67% of PMC articles published in 2012 are open access (view [code](/inst/doc/pmc_growth.R) ).  

![PMC growth](/inst/doc/pmc_growth.png)

Due to the rapid growth of microbial genome sequencing and the lack of model prokaryotic organism databases (containing high-quality annotations linking features to literature), our main objective is to use the OA subset as a genome annotation database and extract features from reference microbial genomes directly from the literature. Initially, we are focusing on locus tags, but many other features such as gene names, accession numbers, sequences and coordinates (start/stop) should be collected before attempting to summarize functional annotations.  Our goal is to extract passages containing locus tags from *full text, tables and supplements* and output tab-delimited files in a variety of formats, for example, as GFF3 files that can then be viewed in a genome browser.  This guide describes some of the functions included within the package by using *Burkholderia pseudomallei* as an example.



## Download Reference Genomes

The [Burkholderia pseudomallei](http://www.ncbi.nlm.nih.gov/genome/476) page in Entrez Genomes lists the Reference genome (strain K96243). This strain may also be identified using the `referenceGenome` function, which searches Entrez genome using a species name.  The next step is to identifiy the organism directory in the Genomes ftp site (ftp.ncbi.nlm.nih.gov/genomes/Bacteria) and download annotations and sequences.  The organism directory is usually the name and project id and can also be found in the Bacteria dataset.  The `read.ncbi.ftp` function reads most of the RefSeq files on the site including GFF3 files below.   


	referenceGenome("Burkholderia pseudomallei")
	[1] "Reference genome, Community selected, UniProt : Burkholderia pseudomallei K96243"
	[2] "Project id : 57733"
	
	data(Bacteria)  # list of directories in ftp
	subset(Bacteria, pid ==  57733)
	                                         name mode size       date   pid
	386 Burkholderia_pseudomallei_K96243_uid57733    d 4096 2010-12-06 57733
	
	bpgff <- read.ncbi.ftp( "Burkholderia_pseudomallei_K96243_uid57733", "gff")
	bpgff
	GRanges with 5935 ranges and 4 metadata columns:
	       seqnames       ranges strand |       locus     feature              description        gene
	          <Rle>    <IRanges>  <Rle> | <character> <character>              <character> <character>
	  [1] NC_006350 [   1, 1116]      - |    BPSL0001         CDS carboxylate-amine ligase            
	  [2] NC_006350 [1161, 2375]      - |    BPSL0002         CDS     hypothetical protein  
	  ... 

	table(values(bpgff)$feature)

	    CDS miscRNA  pseudo    rRNA    tRNA 
	   5728       8     126      12      61 
     

The summaryTag function lists the locus tag prefixes, suffixes and tag ranges from coding regions.  These are needed to search PMC and also create the string pattern to extract locus tags from the XML  (alternately, the locus tags or gene names could be used as a dictionary to find matches within the document, but in many cases there are new locus tags and expecially gene names in the literature that are not found within GFF3 files)

	summaryTag(bpgff)
	$prefix
	BPSL BPSS 
	3399 2329 

	$suffix
	 a  A  b  B  c  d 
	36 42  3  6  1  1 

	$range
	[1]    1 3431

	$digits
	   4 
	5728 

Finally, check if the features within the GFF3 file are sorted and then save the the tags (needed for range expansion described later) and optionally gene names.

	is.sorted(bpgff)
	bplocus <- values(bpgff)$locus
	bpgenes<- sort(unique(unlist( strsplit(values(bpgff)$gene, ",") )))


## Find relevant publications 

The next step is to find publications containing any *B. pseudomallei* K96243 locus tag.  Searching for a single locus tag in a full-text database like PMC is straightforward, for example, enter "BPSS1492" in the search box and this returnes 10 articles (accessed May 20, 2013).  To find all full-text articles with any locus tag, we use tje prefix and first digit from the GFF3 file to build wildcard searches, in this case "(BPSL0* OR BPSL1* OR BPSL2* OR BPSL3* OR BPSS0* OR BPSS1* OR BPSS2*)".  We also restricted the number of spurious matches by limiting the results to articles in the open access subset with the genus name in the tile or abstract.  This query returns 46 [publications](/inst/doc/bp_refs.tab).


	tags <- "(BPSL0* OR BPSL1* OR BPSL2* OR BPSL3* OR BPSS0* OR BPSS1* OR BPSS2*)"
	bp <- ncbiPMC(paste(tags, "AND (Burkholderia[TITLE] OR Burkholderia[ABSTRACT]) AND open access[FILTER]")) 
	bp[1:10,]
	          pmc                                   authors year                                                                                                                                     title                                          journal volume   pages   epubdate     pmid
	1  PMC3623717         Hara Y, Chin CY, Mohamed R, et al 2013                                    Multiple-antigen ELISA for melioidosis - a novel approach to the improved serodiagnosis of melioidosis                          BMC Infectious Diseases     13     165 2013/04/04 23556548
	2  PMC3607239           Puah SM, Puthucheary S, Chua KH 2013 Potential Immunogenic Polypeptides of Burkholderia pseudomallei Identified by Shotgun Expression Library and Evaluation of Their Efficacy        International Journal of Medical Sciences     10 539-547 2013/03/13 23532805
	3  PMC3579680 Janse I, Hamidjaja RA, Hendriks AC, et al 2013                            Multiplex qPCR for reliable detection and differentiation of Burkholderia mallei and Burkholderia pseudomallei                          BMC Infectious Diseases     13      86 2013/02/14 23409683
	4  PMC3564208      Choh LC, Ong GH, Vellasamy KM, et al 2013                                                                                             Burkholderia vaccines: are we moving forward? Frontiers in Cellular and Infection Microbiology      3       5 2013/02/05 23386999
	5  PMC3540353                                Dowling AJ 2013                                       Novel gain of function approaches for vaccine candidate identification in Burkholderia pseudomallei Frontiers in Cellular and Infection Microbiology      2     139 2013/01/09 23316481
	6  PMC3527420     Chen R, Barphagha IK, Karki HS, et al 2012               Dissection of Quorum-Sensing Genes in Burkholderia glumae Reveals Non-Canonical Regulation and the New Regulatory Gene tofM                                         PLoS ONE      7  e52150 2012/12/20 23284909
	7  PMC3521395        Khoo JS, Chai SF, Mohamed R, et al 2012                  Computational discovery and RT-PCR validation of novel Burkholderia conserved and Burkholderia pseudomallei unique sRNAs                                     BMC Genomics     13     S13 2012/12/07 23282220
	8  PMC3443583         Ong HS, Mohamed R, Firdaus-Raih M 2012  Comparative Genome Sequence Analysis Reveals the Extent of Diversity and Conservation for Glycan-Associated Proteins in Burkholderia spp              Comparative and Functional Genomics   2012  752867 2012/09/06 22991502
	9  PMC3419357   Burtnick MN, Heiss C, Roberts RA, et al 2012                            Development of capsular polysaccharide-based glycoconjugates for immunization against melioidosis and glanders Frontiers in Cellular and Infection Microbiology      2     108 2012/08/15 22912938
	10 PMC3418162             Chieng S, Carreto L, Nathan S 2012                                                                       Burkholderia pseudomallei transcriptional adaptation in macrophages                                     BMC Genomics     13     328 2012/07/23 22823543


### Download PMC XML

The XML version of Open Access articles may be downloaded from either the FTP site or the Open Archives Initiative (OAI) service.  The pmcOAI function uses the pmc ID to download the XML version and adds carets (^) within superscript tags and hyperlinked table footnotes for displaying as plain text (for example, BPSL0075<sup>a</sup> is displayed as BPSL0075^a and not BPSL0075a since both BPSL0075 and BPSL0075a are valid tag names).  The function also saves a local copy for future use and checks if a local copy exists (and will use that instead of downloading a second time).  Finally,  the function uses the `xmlParse` function from the [XML](http://cran.r-project.org/web/packages/XML/index.html) package to read the file and generate the XML tree within the R session, so objects are stored as an `XMLInternalDocument` class and can be queried using XPath expressions.


	id <- "PMC3418162"
	doc <- pmcOAI(id)


 with 2959 locus tag [citations](/inst/doc/bp.tab). 



pmcLoop(bp, tags= bpgff, prefix = "BPS[SL]" , suffix= "[abc]",  file="bp.tab")


## Details





