## busco summary
for i in $(cat busco_list); do echo -n "${i}"; cat ${i} | grep "C:"; done

## pfam summary
for i in $(cat pfam_tsv_list); do echo -n "${i} "; cat ${i} | cut -f1 | sort | uniq | wc -l ; done

## gff stat summary
for i in $(cat gff3_list)
do
	echo -n "${i}"
	gene_num=$(grep -v "#" ${i} | cut -f3 | sort | uniq -c | grep " gene")
	mRNA_num=$(grep -v "#" ${i} | cut -f3 | sort | uniq -c | grep " mRNA")
	echo -n "${mRNA_num} "
	echo "${gene_num}"
done

## mapping ratio summary
for i in $(cat mapping_ratio_list)
do
	echo -n "${i} " >> mapping_ratio_summary
	cat ${i} | grep "mapped %" | sed -n '1p' >> mapping_ratio_summary
done


