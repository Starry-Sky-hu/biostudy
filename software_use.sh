## seqkit https://bioinf.shenwei.me/seqkit/
#fasta多行变一行
seqkit seq -w 0
# 根据区间提取序列
seqkit subseq Tubocapsicum_anomalum.fa --chr Chr_5 -r 225396723:228924963 -o block_1.fa
# 根据bed文件提取序列
seqkit subseq --bed Solanum_tuberosumDM_colgene_sort.bed -u 5000 -d 5000 Solanum_tuberosumDM.fa > Solanum_tuberosumDM_colgene.fa



## pigz
pigz -p 52 ${i}
## gtz
gtz -d file -z


## PASA update gff
SINGULARITYENV_PREPEND_PATH="/opt/conda/envs/pasa/bin" \
singularity exec GenomeAnnotationContainer_v0.3 \
	/opt/conda/envs/pasa/opt/pasa-2.4.1/scripts/Load_Current_Gene_Annotations.dbi \
	-c pasa.alignAssembly.txt \
	-g Solanum_aculeatissimum_hifiasm.bp.p_ctg.fasta \
	-P Solanum_aculeatissimum_maker_merge_filter.gff3

SINGULARITYENV_PREPEND_PATH="/opt/conda/envs/pasa/bin" \
singularity exec GenomeAnnotationContainer_v0.3 \
	/opt/conda/envs/pasa/opt/pasa-2.4.1/Launch_PASA_pipeline.pl \
	-c pasa.annotationCompare.txt -A \
	-g Solanum_aculeatissimum_hifiasm.bp.p_ctg.fasta \
	-t Solanum_aculeatissimum_hifiasm_transcripts.fasta.clean

grep -Ev "^#|^$" Solanum_aculeatissimum_hifiasm_db.gene_structures_post_PASA_updates.22495.gff3 > Solanum_aculeatissimum_hifiasm_db.gene_structures_post_PASA_updates.gff3

perl ~/software/longest_transcript.pl Solanum_aculeatissimum_hifiasm_db.gene_structures_post_PASA_updates.gff3 > Solanum_aculeatissimum_hifiasm_db.gene_structures_post_PASA_updates_longest.gff3




# minimap2 mapping
minimap2 -t 52 -x asm5 -o Datura_inoxia_Datura_metel_5.paf Datura_inoxia.fa Datura_metel.fa
# plot
Rscript ~/software/co.R -i ${i} -o ${i%.paf*} -l -s -t -k 12 -p 9 -m 15000
# mummer
ref=Datura_inoxia.fa
query=Datura_metel.fa
prefix=Datura_inoxia_Datura_metel
nucmer --mum -t 52 -p $prefix $ref $query
delta-filter -i 90 -l 10000 -q ${prefix}.delta > ${prefix}.flt.delta
show-coords -c -l -o -r -T ${prefix}.flt.delta >  ${prefix}.r.coords
show-coords -c -l -o -q -T ${prefix}.flt.delta >  ${prefix}.q.coords
mummerplot -t png -s large -p $prefix ${prefix}.flt.delta
gnuplot ${prefix}.gp









