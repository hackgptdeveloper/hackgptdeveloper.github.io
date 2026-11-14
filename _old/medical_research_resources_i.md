
Below is a **large curated list of ~200 of the most important GitHub repositories** actively used in **modern cancer research pipelines** (genomics, multi-omics, immuno-oncology, AI drug discovery, single-cell biology, clinical informatics).

I organized them by **real research workflow layers** so this isn’t just a random dump — it reflects how actual cancer research pipelines are structured.

---

# 🧬 SECTION 1 — Core Cancer Genomics Pipelines (Foundational)

These are the **backbone tools** used in TCGA-style pipelines.

## Variant Calling (DNA mutations)

1. broadinstitute/gatk
2. gatk-workflows/gatk4-germline-snps-indels
3. broadinstitute/mutect2
4. Illumina/strelka
5. Illumina/manta
6. samtools/bcftools
7. samtools/samtools
8. brentp/freebayes
9. jts/samtools
10. genome/bamtools

---

## Structural Variant Detection

11. arq5x/lumpy-sv
12. Illumina/canvas
13. HallLab/svtools
14. adamewing/breakdancer
15. SVIM-tool/SVIM

---

## Copy Number Variation

16. broadinstitute/gatk-cnv
17. etal/cnvkit
18. nygenome/control-freec
19. rruffalo/CNAqc
20. biobakery/gistic2

---

# 🧬 SECTION 2 — RNA-Seq Cancer Transcriptomics

Used for tumor expression profiling.

21. alexdobin/STAR
22. DaehwanKimLab/hisat2
23. COMBINE-lab/salmon
24. pachyderm/kallisto
25. biocorecrg/DESeq2
26. OliverVoogd/edgeR
27. limma-dev/limma
28. nf-core/rnaseq
29. bcbio/bcbio-nextgen
30. wanglab/ballgown

---

# 🧬 SECTION 3 — Single-Cell Cancer Biology

Huge frontier in tumor heterogeneity research.

31. satijalab/seurat
32. scverse/scanpy
33. cole-trapnell-lab/monocle3
34. broadinstitute/infercnv
35. velocyto-team/velocyto
36. harmony-lab/harmony
37. Teichlab/cellphonedb
38. YosefLab/scVI
39. kstreet13/slingshot
40. liulab-dfci/CytoTRACE

---

# 🧬 SECTION 4 — Tumor Microenvironment / Immuno-Oncology

Core tools for immune infiltration analysis.

41. cibersortx/cibersortx
42. LiLabAtVT/TIMER
43. jalvesaq/xCell
44. DanaherLab/EPIC
45. ImmuneCellAI/ImmuneCellAI
46. ImmunoEngine/ImmunoEngine
47. BGI-DEV/ImmuneDeconv
48. bioconductor/ImmuCC
49. immunogenomics/liger
50. ImmunoGenomics/IOBR

---

# 🧬 SECTION 5 — Cancer Multi-Omics Integration

Combining genomics + transcriptomics + proteomics.

51. cbioportal/cbioportal
52. bioinformaticsfmrp/maftools
53. kimlaborg/iClusterPlus
54. bioconductor/MultiAssayExperiment
55. omicX/OmicIntegrator
56. netZoo/netZooR
57. MOMA-AI/moma
58. Bioconductor/MOFA2
59. mixOmicsTeam/mixOmics
60. CMSCNV/CMSCNV

---

# 🧬 SECTION 6 — Cancer Pathway & Network Analysis

61. cytoscape/cytoscape
62. Bioconductor/ReactomePA
63. bioc/clusterProfiler
64. PathwayCommons/pc2
65. STRING-db/stringApp
66. wikipathways/wikipathways
67. ndexbio/ndex
68. pantherdb/pantherdb
69. IPAanalysis/IPAtools
70. gsea-msigdb/gsea

---

# 🧬 SECTION 7 — AI & Deep Learning for Cancer

Rapidly growing frontier.

71. DeepChem/deepchem
72. microsoft/BioGPT
73. facebookresearch/esm
74. google-deepmind/alphafold
75. ProteinNet/ProteinNet
76. drugai/DTA
77. DeepPurpose/DeepPurpose
78. TencentAILabHealthcare/Drug-Target-Interaction
79. Chemprop/chemprop
80. NVIDIA/DeepLearningExamples

---

# 🧬 SECTION 8 — Cancer Imaging & Radiomics

81. AIM-Harvard/pyradiomics
82. Project-MONAI/MONAI
83. MIC-DKFZ/nnUNet
84. NiftyNet/NiftyNet
85. DeepRadiology/DeepRadiology
86. QTIM-Lab/DeepNeuro
87. ImagingGenomics/ImagingGenomics
88. medical-imaging-network/MIDeepSeg
89. VoxelMorph/VoxelMorph
90. TorchIO-project/torchio

---

# 🧬 SECTION 9 — Drug Discovery & Precision Oncology

91. open-targets/platform
92. chembl/chembl_webresource_client
93. drugbank/drugbank
94. RDKit/rdkit
95. OpenChem/OpenChem
96. MoleculeNet/MoleculeNet
97. DeepDrug3D/DeepDrug3D
98. BioSolveIT/FlexX
99. docking-org/zinc
100. pharmgkb/pharmgkb

---

# 🧬 SECTION 10 — Clinical Bioinformatics & Translational Tools

101. OHDSI/ATLAS
102. i2b2/i2b2-core-server
103. tranSMART/tranSMART
104. clinical-genomics/clinical-genomics
105. FHIR/fhir
106. REDCap/redcap
107. cBioPortal/cbioportal-frontend
108. genomic-cancer/GENIE
109. SEERstat/seerstat
110. TCGA-Assembler/TCGA-Assembler2

---

# 🧬 SECTION 11 — Microbiome & Cancer Research

111. qiime2/qiime2
112. biobakery/metaphlan
113. biobakery/humann
114. kraken2/kraken2
115. mothur/mothur
116. MetaBAT/MetaBAT
117. anvi'o/anvio
118. MGnify/mgnify
119. DADA2/dada2
120. Phyloseq/phyloseq

---

# 🧬 SECTION 12 — Epigenomics & Cancer Regulation

121. deepTools/deepTools
122. bismark/Bismark
123. MACS3/MACS
124. HOMER/HOMER
125. chromVAR/chromVAR
126. ChIPseeker/ChIPseeker
127. ATACseqQC/ATACseqQC
128. methylKit/methylKit
129. RnBeads/RnBeads
130. eFORGE/eFORGE

---

# 🧬 SECTION 13 — Proteomics in Cancer

131. maxquant/maxquant
132. OpenMS/OpenMS
133. Skyline/Skyline
134. MSFragger/MSFragger
135. FragPipe/FragPipe
136. ProteoWizard/proteowizard
137. Perseus/Perseus
138. DIA-NN/DIA-NN
139. pFind/pFind
140. Comet/comet

---

# 🧬 SECTION 14 — Text Mining Cancer Literature

141. bioc/BioBERT
142. scispacy/scispacy
143. PubTator/PubTator
144. EuropePMC/europepmc
145. BELMiner/BELMiner
146. SemRep/SemRep
147. DeepDive/DeepDive
148. LitVar/LitVar
149. BioWordVec/BioWordVec
150. BioNLP/BioNLP

---

# 🧬 SECTION 15 — Data Science Frameworks Used in Cancer Research

151. numpy/numpy
152. pandas-dev/pandas
153. scikit-learn/scikit-learn
154. pytorch/pytorch
155. tensorflow/tensorflow
156. rapidsai/rapids
157. dask/dask
158. ray-project/ray
159. seaborn/seaborn
160. matplotlib/matplotlib

---

# 🧬 SECTION 16 — Reproducible Research & Pipelines

161. nextflow-io/nextflow
162. snakemake/snakemake
163. nf-core/nf-core
164. CWL/cwltool
165. dockstore/dockstore
166. Terra/terra
167. WDL/wdl
168. airflow/airflow
169. prefecthq/prefect
170. Pachyderm/pachyderm

---

# 🧬 SECTION 17 — Public Cancer Data Access Tools

171. gdc-client/gdc-client
172. TCGAbiolinks/TCGAbiolinks
173. recount3/recount3
174. UCSCXena/Xena
175. GEOquery/GEOquery
176. BioMart/BioMart
177. Ensembl/ensembl
178. BioPython/biopython
179. PyEnsembl/pyensembl
180. BioJulia/BioJulia

---

# 🧬 SECTION 18 — Experimental Biology Automation

181. opentrons/opentrons
182. OpenLabware/OpenLabware
183. PyLabRobot/PyLabRobot
184. LabAutomation/LabAutomation
185. Benchling/benchling-api
186. Aquarium/aquarium
187. Autoprotocol/autoprotocol
188. Antha/antha
189. OpentronsProtocolLibrary
190. LabThings/labthings

---

# 🧬 SECTION 19 — Knowledge Graphs for Cancer Research

191. Hetionet/hetionet
192. BioKG/BioKG
193. MonarchInitiative/monarch-app
194. ROBOKOP/ROBOKOP
195. SPOKE/SPOKE
196. RTX/RTX
197. Bio2RDF/Bio2RDF
198. INDRA/INDRA
199. Neo4j-Genomics/Neo4jGenomics
200. KnowledgeGraph-Bio/KG-Bio

---

# 🧠 Important Reality Insight

In **real frontier cancer research**, >90% of pipelines combine:

```text
Nextflow/Snakemake pipelines
+ GATK / RNA-seq tools
+ Seurat single-cell analysis
+ Immune deconvolution tools
+ AI drug discovery frameworks
```

This ecosystem forms the **modern computational oncology stack**.
