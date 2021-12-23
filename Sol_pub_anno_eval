for i in $(cat gff3_list)
do
    j=${i%/*}

    echo "#!/bin/bash" > ${j#*/}_stat.sh
    echo "#SBATCH --partition=queue1" >> ${j#*/}_stat.sh
    echo "#SBATCH -N 1" >> ${j#*/}_stat.sh
    echo "#SBATCH -c 52" >> ${j#*/}_stat.sh
    echo "#SBATCH --qos=queue1" >> ${j#*/}_stat.sh
    echo "" >> ${j#*/}_stat.sh

    echo "singularity exec ~/contianer/OrthoGeneGL gffread ${i} -g ref/${j#*/}.fa -y ${j#*/}_protein.fa -S" >> ${j#*/}_stat.sh
    echo "" >> ${j#*/}_stat.sh

    echo "source activate domain" >> ${j#*/}_stat.sh
    echo "interproscan.sh -appl PfamA \\" >> ${j#*/}_stat.sh
    echo "   -iprlookup -goterms -f tsv \\" >> ${j#*/}_stat.sh
    echo "   -dp -cpu 52 \\" >> ${j#*/}_stat.sh
    echo "   -b ${j#*/}_protein.fa.pfam \\" >> ${j#*/}_stat.sh
    echo "   -i ${j#*/}_protein.fa" >> ${j#*/}_stat.sh
    echo "" >> ${j#*/}_stat.sh

    echo "singularity exec /home/huyong/contianer/busco_container \\" >> ${j#*/}_stat.sh
    echo "   busco -m protein \\" >> ${j#*/}_stat.sh
    echo "       -i ${j#*/}_protein.fa \\" >> ${j#*/}_stat.sh
    echo "       -o ${j#*/}_protein.fa_busco \\" >> ${j#*/}_stat.sh
    echo "       -l /home/huyong/software/solanales_odb10 \\" >> ${j#*/}_stat.sh
    echo "       -c 52 \\" >> ${j#*/}_stat.sh
    echo "       --offline" >> ${j#*/}_stat.sh

done

