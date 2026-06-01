---
title: "The 100 Resources That Cancer Researchers Actually Use Every Day — A Behind-the-Scenes Map"
tags:
  - cancer-research
  - bioinformatics
  - medical-research
  - genomics
  - immunology
  - drug-discovery
  - computational-biology
  - open-science
---

**Challenge to the reader:** Before reading, sketch your own mental map of where cancer research data comes from. Write down the data repositories, analysis tools, and databases you know. After reading, compare your map to the 15-layer stack below. What layers were you missing?

---

Modern biology research is drowning in tools and databases — and that's a feature, not a bug. A single clinical research workflow might pull data from TCGA, preprocess it with an nf-core pipeline, analyze it in Seurat, integrate it through a multi-omics framework, interpret it against pathway databases, and translate findings through drug discovery platforms. Each layer depends on the ones below it.

This post is a curated list of approximately 100 resources used by real clinical and translational biology researchers across cancer, immunology, aging, multi-omics, drug discovery, and computational biology. They are grouped by practical research workflow layers so the map is actually usable.

---

## 1. Core Global Biology Data Repositories (Foundational)

These are the primary data backbones for modern biology research.

### Cancer / Disease Mega-Datasets

1. The Cancer Genome Atlas (TCGA) — multi-omics cancer dataset covering 20,000+ tumors. TCGA alone produced petabytes of multi-omics data and transformed molecular cancer classification[^1].
2. COSMIC — somatic mutations in cancer.
3. Cancer Genome Anatomy Project (CGAP).
4. The Cancer Imaging Archive (TCIA).
5. Network of Cancer Genes (NCG).

### Major Functional Genomics Repositories

6. NCBI GEO (Gene Expression Omnibus) — hosts millions of samples across 200,000+ studies[^2].
7. ArrayExpress.
8. ENCODE.
9. GTEx.
10. SRA (Sequence Read Archive).
11. BioProject.
12. BioSample.

### Multi-Omics Integrated Resources

13. cBioPortal.
14. DepMap.
15. Human Protein Atlas.
16. ProteomicsDB.
17. TCGA Pan-Cancer Atlas.

---

## 2. GitHub Curated Bioinformatics Resource Lists (Start Here)

These act as meta-indexes to thousands of tools.

18. [openbiox/awesome-bioinformatics](https://github.com/openbiox/awesome-bioinformatics)
19. [mdozmorov/Immuno_notes](https://github.com/mdozmorov/Immuno_notes)
20. OMICtools search engine — indexes 18,000+ bioinformatics tools[^3].
21. Bioinformatics-papers list repositories.
22. Biostar handbook repositories.

**Challenge:** OMICtools indexes 18,000 tools. Pick one tool from the awesome-bioinformatics list that you've never heard of, read its README, and write down one experiment it could enable.

---

## 3. Cancer Research Toolchains (GitHub-Heavy)

Key software pipelines used in research labs.

### Genomics Analysis

23. GATK — these are the exact variant callers used in TCGA pipelines[^4].
24. MuTect2.
25. VarScan2.
26. Pindel.
27. Strelka.

### RNA-Seq Workflows

28. nf-core RNA-seq.
29. STAR aligner.
30. HISAT2.
31. Salmon.
32. kallisto.
33. DESeq2.
34. edgeR.

### Multi-Omics Integration

35. DRPPM-EASY.
36. Cancer Multi-Omics Benchmark (CMOB) — provides ready-processed datasets across 32 cancers[^5].
37. MultiAssayExperiment.
38. iClusterPlus.

---

## 4. Immunology-Specific Research Tools

Critical for immunotherapy and immune system modeling.

### Repertoire Sequencing

39. Immcantation framework.
40. MiXCR.
41. AIRRflow.

### Immune Deconvolution Tools

42. CIBERSORT.
43. TIMER.
44. xCell.
45. EPIC.

### Immunology Datasets

46. ImmPort.
47. IEDB (Immune Epitope Database).
48. VDJdb.

---

## 5. Single-Cell Biology Research Tools

A massive frontier area.

49. Seurat.
50. Scanpy.
51. Monocle.
52. Cell Ranger.
53. Harmony.
54. CellPhoneDB.

### Single-Cell Datasets

55. Human Cell Atlas.
56. Single Cell Portal.
57. PanglaoDB.

---

## 6. Aging / Longevity Research Databases

Essential for geroscience.

58. GenAge.
59. LongevityMap.
60. Human Ageing Genomic Resources (HAGR).
61. Aging Atlas.
62. SenNet.

---

## 7. Structural Biology & Protein Tools

Used in drug discovery and immunology.

63. AlphaFold DB.
64. PDB (Protein Data Bank).
65. Rosetta.
66. FoldX.
67. PyMOL.

---

## 8. Drug Discovery & Pharmacogenomics Resources

Important in translational oncology.

68. DrugBank.
69. ChEMBL.
70. LINCS L1000.
71. Open Targets Platform.
72. PharmGKB.

---

## 9. Pathway & Systems Biology Tools

73. KEGG.
74. Reactome.
75. STRING.
76. BioGRID.
77. Cytoscape.
78. GenMAPP — integrates gene-level datasets with pathways for disease analysis[^6].

---

## 10. Machine Learning in Biology Repositories

A rapidly growing frontier.

79. DeepChem.
80. BioBERT.
81. DNABERT.
82. ESM protein language models.
83. AlphaFold-multimer.

**Challenge:** DeepChem vs. BioBERT — one is for molecules, one is for literature. If you had to build a system that links published cancer mutations to candidate drugs, which would you use for each step of the pipeline?

---

## 11. Clinical Research & Translational Platforms

84. ClinicalTrials.gov dataset APIs.
85. OHDSI / OMOP.
86. i2b2.
87. REDCap open tools.

---

## 12. Imaging & Radiomics Resources

88. TCIA radiomics tools.
89. PyRadiomics.
90. MONAI (medical AI).

---

## 13. Microbiome / Metagenomics Tools

91. QIIME2.
92. Kraken2.
93. MetaPhlAn.
94. HUMAnN.

---

## 14. Text Mining & Knowledge Graph Resources

95. PubTator.
96. Europe PMC mining.
97. BioASQ datasets.

---

## 15. Experimental Protocol Repositories

98. Protocols.io.
99. Addgene plasmid repository.
100. Benchling open tools.

---

## How Frontier Biology Research Actually Works

A real clinical research workflow typically uses:

```
RAW DATA → GEO / TCGA
     ↓
Preprocessing → nf-core pipelines
     ↓
Analysis → Seurat / DESeq2
     ↓
Integration → Multi-omics frameworks
     ↓
Interpretation → Pathway / protein databases
     ↓
Translation → drug discovery resources
```

Each arrow in this pipeline is a place where tool selection can make or break a project. The difference between a Nature paper and an unpublishable result often comes down to choosing the right tool for each layer — and knowing that the tool exists in the first place.

**Final challenge:** You're a new PI starting a lab focused on immuno-oncology in colorectal cancer. Your first project aims to identify why some patients respond to checkpoint inhibitors while others don't. Using only resources listed above, map out a complete data-to-drug pipeline: which datasets will you query, which preprocessing and analysis tools will you use, and which drug discovery databases will you search for candidate compounds? Write the pipeline as a numbered list of steps, each annotated with the specific resource from the list above.

---

[^1]: <https://www.cancer.gov/ccg/research/genome-sequencing/tcga>
[^2]: <https://rna.cd-genomics.com/resource/gene-expression-databases.html>
[^3]: <https://arxiv.org/abs/1707.03659>
[^4]: <https://gdc.cancer.gov/access-data/community-tools>
[^5]: <https://arxiv.org/abs/2409.02143>
[^6]: <https://en.wikipedia.org/wiki/GenMAPP>
