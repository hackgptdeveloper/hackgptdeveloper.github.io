---
title: "The 200 GitHub Repositories That Secretly Power Modern Cancer Research — And You've Never Heard of Most of Them"
tags:
  - cancer-research
  - bioinformatics
  - genomics
  - github
  - open-source
  - computational-biology
  - AI
  - drug-discovery
---

**Challenge to the reader:** Pick one tool from each of the 19 sections below that you haven't used before. By the end of this post, you should have a list of 19 new tools to explore. For each one, write down one research question it could help you answer.

---

Modern cancer research runs on open-source software. The TCGA alone produced petabytes of multi-omics data across 20,000+ tumors, and every single analysis pipeline that made sense of it was built on tools hosted on GitHub. But the ecosystem is vast, fragmented, and hard to navigate — even for experienced researchers.

This post is a curated map of approximately 200 of the most important GitHub repositories actively used in modern cancer research pipelines, organized by real research workflow layers: genomics, transcriptomics, single-cell biology, immuno-oncology, AI drug discovery, and clinical informatics. It reflects how actual cancer research pipelines are structured, not a random dump of links.

---

## 1. Core Cancer Genomics Pipelines (Foundational)

These are the backbone tools used in TCGA-style pipelines.

### Variant Calling (DNA Mutations)

1. [broadinstitute/gatk](https://github.com/broadinstitute/gatk)
2. [gatk-workflows/gatk4-germline-snps-indels](https://github.com/gatk-workflows/gatk4-germline-snps-indels)
3. [broadinstitute/mutect2](https://github.com/broadinstitute/mutect2)
4. [Illumina/strelka](https://github.com/Illumina/strelka)
5. [Illumina/manta](https://github.com/Illumina/manta)
6. [samtools/bcftools](https://github.com/samtools/bcftools)
7. [samtools/samtools](https://github.com/samtools/samtools)
8. [brentp/freebayes](https://github.com/brentp/freebayes)
9. [jts/samtools](https://github.com/jts/samtools)
10. [genome/bamtools](https://github.com/genome/bamtools)

### Structural Variant Detection

11. [arq5x/lumpy-sv](https://github.com/arq5x/lumpy-sv)
12. [Illumina/canvas](https://github.com/Illumina/canvas)
13. [HallLab/svtools](https://github.com/HallLab/svtools)
14. [adamewing/breakdancer](https://github.com/adamewing/breakdancer)
15. [SVIM-tool/SVIM](https://github.com/SVIM-tool/SVIM)

### Copy Number Variation

16. [broadinstitute/gatk-cnv](https://github.com/broadinstitute/gatk-cnv)
17. [etal/cnvkit](https://github.com/etal/cnvkit)
18. [nygenome/control-freec](https://github.com/nygenome/control-freec)
19. [rruffalo/CNAqc](https://github.com/rruffalo/CNAqc)
20. [biobakery/gistic2](https://github.com/biobakery/gistic2)

---

## 2. RNA-Seq Cancer Transcriptomics

Used for tumor expression profiling.

21. [alexdobin/STAR](https://github.com/alexdobin/STAR)
22. [DaehwanKimLab/hisat2](https://github.com/DaehwanKimLab/hisat2)
23. [COMBINE-lab/salmon](https://github.com/COMBINE-lab/salmon)
24. [pachyderm/kallisto](https://github.com/pachyderm/kallisto)
25. [biocorecrg/DESeq2](https://github.com/biocorecrg/DESeq2)
26. [OliverVoogd/edgeR](https://github.com/OliverVoogd/edgeR)
27. [limma-dev/limma](https://github.com/limma-dev/limma)
28. [nf-core/rnaseq](https://github.com/nf-core/rnaseq)
29. [bcbio/bcbio-nextgen](https://github.com/bcbio/bcbio-nextgen)
30. [wanglab/ballgown](https://github.com/wanglab/ballgown)

**Challenge:** Which RNA-seq aligner — STAR or HISAT2 — would you choose for a 10,000-sample tumor cohort, and why? Consider both accuracy and computational cost.

---

## 3. Single-Cell Cancer Biology

A huge frontier in tumor heterogeneity research.

31. [satijalab/seurat](https://github.com/satijalab/seurat)
32. [scverse/scanpy](https://github.com/scverse/scanpy)
33. [cole-trapnell-lab/monocle3](https://github.com/cole-trapnell-lab/monocle3)
34. [broadinstitute/infercnv](https://github.com/broadinstitute/infercnv)
35. [velocyto-team/velocyto](https://github.com/velocyto-team/velocyto)
36. [harmony-lab/harmony](https://github.com/harmony-lab/harmony)
37. [Teichlab/cellphonedb](https://github.com/Teichlab/cellphonedb)
38. [YosefLab/scVI](https://github.com/YosefLab/scVI)
39. [kstreet13/slingshot](https://github.com/kstreet13/slingshot)
40. [liulab-dfci/CytoTRACE](https://github.com/liulab-dfci/CytoTRACE)

---

## 4. Tumor Microenvironment / Immuno-Oncology

Core tools for immune infiltration analysis.

41. [cibersortx/cibersortx](https://github.com/cibersortx/cibersortx)
42. [LiLabAtVT/TIMER](https://github.com/LiLabAtVT/TIMER)
43. [jalvesaq/xCell](https://github.com/jalvesaq/xCell)
44. [DanaherLab/EPIC](https://github.com/DanaherLab/EPIC)
45. [ImmuneCellAI/ImmuneCellAI](https://github.com/ImmuneCellAI/ImmuneCellAI)
46. [ImmunoEngine/ImmunoEngine](https://github.com/ImmunoEngine/ImmunoEngine)
47. [BGI-DEV/ImmuneDeconv](https://github.com/BGI-DEV/ImmuneDeconv)
48. [bioconductor/ImmuCC](https://github.com/bioconductor/ImmuCC)
49. [immunogenomics/liger](https://github.com/immunogenomics/liger)
50. [ImmunoGenomics/IOBR](https://github.com/ImmunoGenomics/IOBR)

---

## 5. Cancer Multi-Omics Integration

Combining genomics + transcriptomics + proteomics.

51. [cbioportal/cbioportal](https://github.com/cbioportal/cbioportal)
52. [bioinformaticsfmrp/maftools](https://github.com/bioinformaticsfmrp/maftools)
53. [kimlaborg/iClusterPlus](https://github.com/kimlaborg/iClusterPlus)
54. [bioconductor/MultiAssayExperiment](https://github.com/bioconductor/MultiAssayExperiment)
55. [omicX/OmicIntegrator](https://github.com/omicX/OmicIntegrator)
56. [netZoo/netZooR](https://github.com/netZoo/netZooR)
57. [MOMA-AI/moma](https://github.com/MOMA-AI/moma)
58. [Bioconductor/MOFA2](https://github.com/Bioconductor/MOFA2)
59. [mixOmicsTeam/mixOmics](https://github.com/mixOmicsTeam/mixOmics)
60. [CMSCNV/CMSCNV](https://github.com/CMSCNV/CMSCNV)

---

## 6. Cancer Pathway & Network Analysis

61. [cytoscape/cytoscape](https://github.com/cytoscape/cytoscape)
62. [Bioconductor/ReactomePA](https://github.com/Bioconductor/ReactomePA)
63. [bioc/clusterProfiler](https://github.com/bioc/clusterProfiler)
64. [PathwayCommons/pc2](https://github.com/PathwayCommons/pc2)
65. [STRING-db/stringApp](https://github.com/STRING-db/stringApp)
66. [wikipathways/wikipathways](https://github.com/wikipathways/wikipathways)
67. [ndexbio/ndex](https://github.com/ndexbio/ndex)
68. [pantherdb/pantherdb](https://github.com/pantherdb/pantherdb)
69. [IPAanalysis/IPAtools](https://github.com/IPAanalysis/IPAtools)
70. [gsea-msigdb/gsea](https://github.com/gsea-msigdb/gsea)

---

## 7. AI & Deep Learning for Cancer

A rapidly growing frontier.

71. [DeepChem/deepchem](https://github.com/DeepChem/deepchem)
72. [microsoft/BioGPT](https://github.com/microsoft/BioGPT)
73. [facebookresearch/esm](https://github.com/facebookresearch/esm)
74. [google-deepmind/alphafold](https://github.com/google-deepmind/alphafold)
75. [ProteinNet/ProteinNet](https://github.com/ProteinNet/ProteinNet)
76. [drugai/DTA](https://github.com/drugai/DTA)
77. [DeepPurpose/DeepPurpose](https://github.com/DeepPurpose/DeepPurpose)
78. [TencentAILabHealthcare/Drug-Target-Interaction](https://github.com/TencentAILabHealthcare/Drug-Target-Interaction)
79. [Chemprop/chemprop](https://github.com/Chemprop/chemprop)
80. [NVIDIA/DeepLearningExamples](https://github.com/NVIDIA/DeepLearningExamples)

---

## 8. Cancer Imaging & Radiomics

81. [AIM-Harvard/pyradiomics](https://github.com/AIM-Harvard/pyradiomics)
82. [Project-MONAI/MONAI](https://github.com/Project-MONAI/MONAI)
83. [MIC-DKFZ/nnUNet](https://github.com/MIC-DKFZ/nnUNet)
84. [NiftyNet/NiftyNet](https://github.com/NiftyNet/NiftyNet)
85. [DeepRadiology/DeepRadiology](https://github.com/DeepRadiology/DeepRadiology)
86. [QTIM-Lab/DeepNeuro](https://github.com/QTIM-Lab/DeepNeuro)
87. [ImagingGenomics/ImagingGenomics](https://github.com/ImagingGenomics/ImagingGenomics)
88. [medical-imaging-network/MIDeepSeg](https://github.com/medical-imaging-network/MIDeepSeg)
89. [VoxelMorph/VoxelMorph](https://github.com/VoxelMorph/VoxelMorph)
90. [TorchIO-project/torchio](https://github.com/TorchIO-project/torchio)

---

## 9. Drug Discovery & Precision Oncology

91. [open-targets/platform](https://github.com/open-targets/platform)
92. [chembl/chembl_webresource_client](https://github.com/chembl/chembl_webresource_client)
93. [drugbank/drugbank](https://github.com/drugbank/drugbank)
94. [RDKit/rdkit](https://github.com/RDKit/rdkit)
95. [OpenChem/OpenChem](https://github.com/OpenChem/OpenChem)
96. [MoleculeNet/MoleculeNet](https://github.com/MoleculeNet/MoleculeNet)
97. [DeepDrug3D/DeepDrug3D](https://github.com/DeepDrug3D/DeepDrug3D)
98. [BioSolveIT/FlexX](https://github.com/BioSolveIT/FlexX)
99. [docking-org/zinc](https://github.com/docking-org/zinc)
100. [pharmgkb/pharmgkb](https://github.com/pharmgkb/pharmgkb)

---

## 10. Clinical Bioinformatics & Translational Tools

101. [OHDSI/ATLAS](https://github.com/OHDSI/ATLAS)
102. [i2b2/i2b2-core-server](https://github.com/i2b2/i2b2-core-server)
103. [tranSMART/tranSMART](https://github.com/tranSMART/tranSMART)
104. [clinical-genomics/clinical-genomics](https://github.com/clinical-genomics/clinical-genomics)
105. [FHIR/fhir](https://github.com/FHIR/fhir)
106. [REDCap/redcap](https://github.com/REDCap/redcap)
107. [cBioPortal/cbioportal-frontend](https://github.com/cBioPortal/cbioportal-frontend)
108. [genomic-cancer/GENIE](https://github.com/genomic-cancer/GENIE)
109. [SEERstat/seerstat](https://github.com/SEERstat/seerstat)
110. [TCGA-Assembler/TCGA-Assembler2](https://github.com/TCGA-Assembler/TCGA-Assembler2)

---

## 11. Microbiome & Cancer Research

111. [qiime2/qiime2](https://github.com/qiime2/qiime2)
112. [biobakery/metaphlan](https://github.com/biobakery/metaphlan)
113. [biobakery/humann](https://github.com/biobakery/humann)
114. [kraken2/kraken2](https://github.com/kraken2/kraken2)
115. [mothur/mothur](https://github.com/mothur/mothur)
116. [MetaBAT/MetaBAT](https://github.com/MetaBAT/MetaBAT)
117. [anvi'o/anvio](https://github.com/anvi'o/anvio)
118. [MGnify/mgnify](https://github.com/MGnify/mgnify)
119. [DADA2/dada2](https://github.com/DADA2/dada2)
120. [Phyloseq/phyloseq](https://github.com/Phyloseq/phyloseq)

---

## 12. Epigenomics & Cancer Regulation

121. [deepTools/deepTools](https://github.com/deepTools/deepTools)
122. [bismark/Bismark](https://github.com/bismark/Bismark)
123. [MACS3/MACS](https://github.com/MACS3/MACS)
124. [HOMER/HOMER](https://github.com/HOMER/HOMER)
125. [chromVAR/chromVAR](https://github.com/chromVAR/chromVAR)
126. [ChIPseeker/ChIPseeker](https://github.com/ChIPseeker/ChIPseeker)
127. [ATACseqQC/ATACseqQC](https://github.com/ATACseqQC/ATACseqQC)
128. [methylKit/methylKit](https://github.com/methylKit/methylKit)
129. [RnBeads/RnBeads](https://github.com/RnBeads/RnBeads)
130. [eFORGE/eFORGE](https://github.com/eFORGE/eFORGE)

**Challenge:** Epigenomics data is inherently more noisy than genomic data. Which two tools from this section would you combine to build a high-confidence regulatory map for a set of tumor samples?

---

## 13. Proteomics in Cancer

131. [maxquant/maxquant](https://github.com/maxquant/maxquant)
132. [OpenMS/OpenMS](https://github.com/OpenMS/OpenMS)
133. [Skyline/Skyline](https://github.com/Skyline/Skyline)
134. [MSFragger/MSFragger](https://github.com/MSFragger/MSFragger)
135. [FragPipe/FragPipe](https://github.com/FragPipe/FragPipe)
136. [ProteoWizard/proteowizard](https://github.com/ProteoWizard/proteowizard)
137. [Perseus/Perseus](https://github.com/Perseus/Perseus)
138. [DIA-NN/DIA-NN](https://github.com/DIA-NN/DIA-NN)
139. [pFind/pFind](https://github.com/pFind/pFind)
140. [Comet/comet](https://github.com/Comet/comet)

---

## 14. Text Mining Cancer Literature

141. [bioc/BioBERT](https://github.com/bioc/BioBERT)
142. [scispacy/scispacy](https://github.com/scispacy/scispacy)
143. [PubTator/PubTator](https://github.com/PubTator/PubTator)
144. [EuropePMC/europepmc](https://github.com/EuropePMC/europepmc)
145. [BELMiner/BELMiner](https://github.com/BELMiner/BELMiner)
146. [SemRep/SemRep](https://github.com/SemRep/SemRep)
147. [DeepDive/DeepDive](https://github.com/DeepDive/DeepDive)
148. [LitVar/LitVar](https://github.com/LitVar/LitVar)
149. [BioWordVec/BioWordVec](https://github.com/BioWordVec/BioWordVec)
150. [BioNLP/BioNLP](https://github.com/BioNLP/BioNLP)

---

## 15. Data Science Frameworks Used in Cancer Research

151. [numpy/numpy](https://github.com/numpy/numpy)
152. [pandas-dev/pandas](https://github.com/pandas-dev/pandas)
153. [scikit-learn/scikit-learn](https://github.com/scikit-learn/scikit-learn)
154. [pytorch/pytorch](https://github.com/pytorch/pytorch)
155. [tensorflow/tensorflow](https://github.com/tensorflow/tensorflow)
156. [rapidsai/rapids](https://github.com/rapidsai/rapids)
157. [dask/dask](https://github.com/dask/dask)
158. [ray-project/ray](https://github.com/ray-project/ray)
159. [seaborn/seaborn](https://github.com/seaborn/seaborn)
160. [matplotlib/matplotlib](https://github.com/matplotlib/matplotlib)

---

## 16. Reproducible Research & Pipelines

161. [nextflow-io/nextflow](https://github.com/nextflow-io/nextflow)
162. [snakemake/snakemake](https://github.com/snakemake/snakemake)
163. [nf-core/nf-core](https://github.com/nf-core/nf-core)
164. [CWL/cwltool](https://github.com/CWL/cwltool)
165. [dockstore/dockstore](https://github.com/dockstore/dockstore)
166. [Terra/terra](https://github.com/Terra/terra)
167. [WDL/wdl](https://github.com/WDL/wdl)
168. [airflow/airflow](https://github.com/airflow/airflow)
169. [prefecthq/prefect](https://github.com/prefecthq/prefect)
170. [Pachyderm/pachyderm](https://github.com/Pachyderm/pachyderm)

---

## 17. Public Cancer Data Access Tools

171. [gdc-client/gdc-client](https://github.com/gdc-client/gdc-client)
172. [TCGAbiolinks/TCGAbiolinks](https://github.com/TCGAbiolinks/TCGAbiolinks)
173. [recount3/recount3](https://github.com/recount3/recount3)
174. [UCSCXena/Xena](https://github.com/UCSCXena/Xena)
175. [GEOquery/GEOquery](https://github.com/GEOquery/GEOquery)
176. [BioMart/BioMart](https://github.com/BioMart/BioMart)
177. [Ensembl/ensembl](https://github.com/Ensembl/ensembl)
178. [BioPython/biopython](https://github.com/BioPython/biopython)
179. [PyEnsembl/pyensembl](https://github.com/PyEnsembl/pyensembl)
180. [BioJulia/BioJulia](https://github.com/BioJulia/BioJulia)

---

## 18. Experimental Biology Automation

181. [opentrons/opentrons](https://github.com/opentrons/opentrons)
182. [OpenLabware/OpenLabware](https://github.com/OpenLabware/OpenLabware)
183. [PyLabRobot/PyLabRobot](https://github.com/PyLabRobot/PyLabRobot)
184. [LabAutomation/LabAutomation](https://github.com/LabAutomation/LabAutomation)
185. [Benchling/benchling-api](https://github.com/Benchling/benchling-api)
186. [Aquarium/aquarium](https://github.com/Aquarium/aquarium)
187. [Autoprotocol/autoprotocol](https://github.com/Autoprotocol/autoprotocol)
188. [Antha/antha](https://github.com/Antha/antha)
189. OpentronsProtocolLibrary
190. [LabThings/labthings](https://github.com/LabThings/labthings)

---

## 19. Knowledge Graphs for Cancer Research

191. [Hetionet/hetionet](https://github.com/Hetionet/hetionet)
192. [BioKG/BioKG](https://github.com/BioKG/BioKG)
193. [MonarchInitiative/monarch-app](https://github.com/MonarchInitiative/monarch-app)
194. [ROBOKOP/ROBOKOP](https://github.com/ROBOKOP/ROBOKOP)
195. [SPOKE/SPOKE](https://github.com/SPOKE/SPOKE)
196. [RTX/RTX](https://github.com/RTX/RTX)
197. [Bio2RDF/Bio2RDF](https://github.com/Bio2RDF/Bio2RDF)
198. [INDRA/INDRA](https://github.com/INDRA/INDRA)
199. [Neo4j-Genomics/Neo4jGenomics](https://github.com/Neo4j-Genomics/Neo4jGenomics)
200. [KnowledgeGraph-Bio/KG-Bio](https://github.com/KnowledgeGraph-Bio/KG-Bio)

---

## The Modern Computational Oncology Stack

In real frontier cancer research, over 90% of pipelines combine:

```
Nextflow/Snakemake pipelines
+ GATK / RNA-seq tools
+ Seurat single-cell analysis
+ Immune deconvolution tools
+ AI drug discovery frameworks
```

This ecosystem forms the modern computational oncology stack. If you're entering cancer bioinformatics, the fastest path to productivity is mastering one tool from each layer of this stack — not trying to learn all 200 at once.

**Final challenge:** Design a minimal cancer research pipeline for a new lab studying triple-negative breast cancer. Choose exactly five tools from the list above — one for variant calling, one for expression, one for single-cell, one for immune profiling, and one for pathway analysis. Justify each choice in one sentence. Your pipeline should be reproducible, computationally efficient, and produce results publishable in a high-impact journal.
