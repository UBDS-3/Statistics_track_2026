---
title: "Exploratory EDA Notebook — Question Answers"
format:
  html:
    embed-resources: true
    toc: true
---

## Suggested answers

**1.** How many experiments do you spot per cell line donor?

Typically 4 experiments per donor, corresponding to the four conditions: naive (N), IFNγ (I), Salmonella (S), and IFNγ + Salmonella (I+S). You can confirm with `table(coldata$donor)`. Some have only 2 or 3, this can be counted with `table(table(coldata$donor))`.

---

**2.** How would you describe the distribution of the different numeric columns in the peaks table? Do these distributions make sense?

The `start` and `end` columns are chromosomal coordinates, so they increase monotonically across the first 1,000 regions of chromosome 1 — roughly spanning some contiguous window up until ~8 million bp. The `percentage_gc_content` column is roughly normally distributed, centered around 40–60%, reflecting the GC content of open-chromatin peaks (regulatory elements). These distributions make sense: positions are ordered along the chromosome, and GC content is relatively consistent across ATAC-seq peaks. The `chr` and `score` are each just one value: 1 and 1000, respectively. The `length` is a long tailed distribution, again this makes sense as most peaks are a few hundred bp (roughly in the range 150-400), but some are more than 1,000 bp.

---

**3.** What is a typical value for `assigned_frac`? For a typical sample, are most observations within the peaks?

A typical ATAC-seq assigned fractions is 0.5. So for most samples, about half the reads fall within called peaks.

---

**4.** What is the general number of peaks / assigned fragments for a typical sample...

A typical value for `peak_count` is around 140,000. It is left skewed, with some samples having less than 100,000, and the minimum around 35,000. A typical value for `assigned` is 15 million, with a slightly right-skewed distrubtion, with most samples having a similar moderate assigned count but one sample has 31.7 million assigned fragments. 

---

**5.** What is a typical value for the column sum of the counts matrix?

A typical value is in the range of 150-200 on the x-axis which is 1,000s of counts -- so the typical value is between 150,000 and 200,000 counts (observations of reads in the peaks). Given we are looking at only 1,000 peaks (a small subset), column sums in thousands make sense, and are well below typical whole-genome count totals which are in the 10s of millions.

---

**6.** What do you notice about the row sum in contrast to the column sum? Any outliers?

Row sums are far more variable than column sums. Column sums are relatively consistent across samples (total library size is roughly similar), but row sums vary enormously: some peaks are highly accessible across all samples while many have very few counts. The row sum ecdf has a long right tail, indicating a few outlier peaks with very high total accessibility across all samples (1000-4000 on the x-axis indicating 1-4 million of read counts).

---

**7.** What's a typical value for the row sum?

The zoomed plot with `xlim=c(0,10)` suggests most peaks have row sums between roughly 2,500-4,500 total counts across all samples (find 0.4 and 0.6 on the y-axis and then trace down to the x-axis, which is in 1000s of reads).

---

**8.** Check out the possible geoms. Try different plots for various columns in `coldata`.

Open-ended exercise. Useful options include: `geom_boxplot` or `geom_violin` for numeric by condition, `geom_bar` for categorical columns, `geom_density` for distributions, `geom_point` for scatterplots of numeric pairs. Students should examine whether condition separates `assigned` and `peak_count`.

---

**9.** Advanced: try using a different smoothing method.

Alternatives include `method = "loess"` (local polynomial, captures non-linear trends), `method = "gam"` (generalized additive model, similar to loess but uses splines), or `method = "glm"` with a family argument. Using `loess` would reveal curved relationships that a linear `lm` would miss.

---

**10.** What could you say about the first six samples in terms of these plots? And the alignment-check question for omics-familiar readers.

The first six samples show highly similar distributions (overlapping densities) and high pairwise correlations (0.7-0.9), consistent with samples from similar conditions. For checking alignment across RNA-seq and ATAC-seq: identify peaks overlapping gene promoters (e.g., within 2 kb of the TSS), extract accessibility counts for those peaks, and correlate with expression values for the same gene — in the same sample. Open promoters should correlate positively with gene expression, when looking across samples due to natural variation in expression levels. Steps: (1) load gene annotation, (2) find overlaps between peaks and promoter windows with _plyranges_ or _BEDtools_ or other tool, (3) match samples by ID across the two matrices, (4) compute per-gene correlation between accessibility and expression across samples, (5) look at histogram of the correlations over the genes to see what typical values are.

---

## Advanced case study

**11.** What do you observe in the PCA plot colored by sample condition?

Samples cluster strongly by condition. The naive condition forms a distinct cluster separated from immune-stimulated samples along PC1 or PC2. The combined IFNγ+Salmonella treatment shows the most extreme separation from naive. IFNγ-only and Salmonella-only conditions fall between naive and the combined treatment. This indicates that the dominant source of variation in chromatin accessibility is immune stimulation, not donor-to-donor differences.

---

**12.** What pattern does PC1 represent across these highlighted peaks?

PC1 captures immune-responsive chromatin accessibility changes. Peaks with high PC1 loading are more accessible in stimulated conditions (especially IFNγ+SL1344) and less accessible in naive cells. These peaks likely correspond to enhancers or regulatory elements activated during immune response. The plotCounts panels shows increasing counts from naive to IFNγ to SL1344 to IFNγ+SL1344.

---

**13.** Why would it be useful to always work with data that has a specified genome with chromosome lengths?

Without chromosome lengths: (1) tiles or sliding windows can extend past chromosome ends, producing invalid ranges; (2) tools that compute enrichment relative to background (e.g., overlap permutation tests) cannot know the total genomic space; (3) liftover to a different genome build requires knowing the source coordinates are valid; (4) genome browsers and visualization tools need chromosome sizes to properly frame the data. Having `seqinfo` prevents silent bookkeeping errors in downstream genomic arithmetic.

---

**14.** Is there any relationship between GC content (`gc`) and contribution to PC1 in tiles?

Maybe, the tile with the highest sum of absolute PC1 has a number of peaks with GC content in the >0.7 range. Looking at `summary(p$gc)`, this is atypically large GC content. However, the mean doesn't appear to be out of the range and the correlation isn't special. This can be investigated by adding `mean_gc = mean(gc, na.rm=TRUE)` to the _plyranges_ code above.
