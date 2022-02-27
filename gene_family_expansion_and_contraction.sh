orthofinder install

For Linux 64, Open MPI is built with CUDA awareness but this support is disabled by default.
To enable it, please set the environment variable OMPI_MCA_opal_cuda_support=true before
launching your MPI processes. Equivalently, you can set the MCA parameter in the command line:
mpiexec --mca opal_cuda_support 1 ...
 
In addition, the UCX support is also built but disabled by default.
To enable it, first install UCX (conda install -c conda-forge ucx). Then, set the environment
variables OMPI_MCA_pml="ucx" OMPI_MCA_osc="ucx" before launching your MPI processes.
Equivalently, you can set the MCA parameters in the command line:
mpiexec --mca pml ucx --mca osc ucx ...
Note that you might also need to set UCX_MEMTYPE_CACHE=n for CUDA awareness via UCX.
Please consult UCX's documentation for detail.


# orthofinder报错
# diamond 比对时无法识别 '.' (gffread转成protein序列是将终止密码子默认为'.')
Error: Error reading input stream at line 1161: Invalid character (.) in sequence\n'
# gffread 转成protein序列时加上 -S

# globcks报错
# Sequence name too long
# 需要修改每个基因的id


# gff to protein fasta file
singularity exec OrthoGeneGL \
		gffread ${i}/${i}_hifiasm_maker_filter.gff \
			-g ${i}/${i}_hifiasm.bp.p_ctg.fasta \
			-x ${i}/${i}_hifiasm_cds.fa \
			-y ${i}/${i}_hifiasm_protein.fa \
			-S

# rename proten id, add species name into protein id
# list file like to   |Atropa_belladonna_hifiasm_protein.fa
#                     |Lycium_barbarum_hifiasm_protein.fa
#                     |...
for i in $(cat list)
do
	s=${i#*_}
	sed -i 's/>/>'${i:0:1}'_'${s%%_*}'|/g' ${i}
done

# orthofinder 
singularity exec OrthoGeneGL \
	orthofinder -f ./protein -a 1 -M msa -I 2 -t 52

# multi alignment with mafft
for i in `ls Single_Copy_Orthologue_Sequences/*.fa|sed s/.fa//g`
do
	singularity exec OrthoGeneGL \
		einsi ${i}.fa > ${i}_einsi.fa

	singularity exec OrthoGeneGL \
		linsi ${i}.fa > ${i}_linsi.fa
done

# Gblocks 
for i in `ls Single_Copy_Orthologue_Sequences/*.fa|grep -v "linsi"|grep -v "einsi"|sed s/.fa//g`
do
	singularity exec OrthoGeneGL \
		Gblocks ${i}_einsi.fa -b1=6 -e=-eigb
	
	singularity exec OrthoGeneGL \
		Gblocks ${i}_linsi.fa -b1=6 -e=-ligb
done

# cat 
for i in `ls Single_Copy_Orthologue_Sequences/*.fa|grep -v "linsi"|grep -v "einsi"|sed s/.fa//g`
do
	cat ${i}_einsi.fa-eigb >> all_einsi.fa-eigb
	cat ${i}_linsi.fa-ligb >> all_linsi.fa-ligb
done

singularity exec OrthoGeneGL python3 /home/bin/delete_enter_in_seq.py all_einsi.fa-eigb > all_einsi.fa-eigb.out2
singularity exec OrthoGeneGL python3 /home/bin/delete_enter_in_seq.py all_linsi.fa-ligb > all_linsi.fa-ligb.out2
singularity exec OrthoGeneGL python3 /home/bin/concatenation.py all_linsi.fa-ligb.out2 species_id > all_linsi.fa
singularity exec OrthoGeneGL python3 /home/bin/concatenation.py all_einsi.fa-eigb.out2 species_id > all_einsi.fa










##### fang reference
最大的雷是物种树构建后，需要定根，留意一下就好。

1. Orthofinder for gene family cluster
1.1 orthofinder对基因家族聚类
pipeline：/vol3/agis/huangsanwen_group/fangyuhan/01_Adc/08_gene_family/ortho_18species_1.5msa.sh
#使用的物种序列务必去除过变位剪切
#关键参数-I，影响基因家族的数量，我使用的是默认值1.5，常用值为3。建议多调试几个参数做对比。
result：/vol3/agis/huangsanwen_group/fangyuhan/01_Adc/08_gene_family/18chname_species_Results

1.2 利用orthofinder获得的单拷贝基因构建物种树
/vol3/agis/huangsanwen_group/fangyuhan/01_Adc/08_gene_family/OrthoFinder_18chname_species/OrthoFinder/Results_Oct15_1/work.sh
#注意得到的树一定要定根，定根可以使用mega等软件，reroot然后另存为新的文件。定根后的树，即可作为r8s构建超度量树。

2.  gene family expansion and contraction
2.1 利用r8s构建超度量树
/vol3/agis/huangsanwen_group/fangyuhan/01_Adc/08_gene_family/18chname_species_Results/r8s/work.r8s.sh
#得到的超度量树作为cafe的输入文件

2.2 cafe for gene family expansion and contraction analysis
pipeline:/vol3/agis/huangsanwen_group/fangyuhan/01_Adc/08_gene_family/18chname_species_Results/cafe/cafe/cafe_command_reroot.sh
#cafe是交互式界面，运行cafe后，按pipeline先后录入数据即可。

3. gene family gain and loss
dollop 
/public/agis/yanjianbin_group/liaoqinggang/05_pipeline/dollop
#输入的树需要定根。








1. Orthofinder for gene family cluster

1.1 orthofinder对基因家族聚类
pipeline：/vol3/agis/huangsanwen_group/fangyuhan/01_Adc/08_gene_family/ortho_18species_1.5msa.sh
#使用的物种序列务必去除过变位剪切
#关键参数-I，影响基因家族的数量，我使用的是默认值1.5，常用值为3。建议多调试几个参数做对比。
result：/vol3/agis/huangsanwen_group/fangyuhan/01_Adc/08_gene_family/18chname_species_Results

pipeline：
orthofinder -f OrthoFinder_18chname_species/ -a 200 -M msa
#-I default=1.5, The -I (inflation) parameter determines how granular the clustering will be. Lower numbers means denser clusters, but again, this is an arbitrary choice. A value of 3 usually works, but you can try different values and compare results


1.2 利用orthofinder获得的单拷贝基因构建物种树
/vol3/agis/huangsanwen_group/fangyuhan/01_Adc/08_gene_family/OrthoFinder_18chname_species/OrthoFinder/Results_Oct15_1/work.sh
#注意得到的树一定要定根，定根可以使用mega等软件，reroot然后另存为新的文件。定根后的树，即可作为r8s构建超度量树。

#筛选低拷贝基因
python3 low_copy_gene_pick.py Orthogroups/Orthogroups.GeneCount.tsv > low_copy_genes.txt
cut -f1-19 low_copy_genes.txt> low_copy_genes2.txt
mkdir ortho_for_species_tree
for i in $(cut -f1 low_copy_genes2.txt); do cp Orthogroup_Sequences/$i.fa ./ortho_for_species_tree/.; done

#每个物种每个OG仅保留一条序列
cd ortho_for_species_tree/
sed -i 's/>XP_/>Ppa|XP_/g' *.fa
sed -i 's/>Adc/>Adc|/g' *.fa
file=`ls *.fa|sed s/.fa//g`
for i in $file; do echo "python3 ../pickup_one_seq_each_species.py ${i}.fa > ${i}.one4species.fa" >> work.sh; done
split -l 13 -d work.sh
chmod +x x*
nohup ./x* &

#使用mafft-linsi进行多序列比对，结果后缀linsi.out
for i in $file; do echo "linsi ${i}.one4species.fa > ${i}.linsi.out" >> tree.sh; done
split -l 13 -d tree.sh tree
chmod +x tree*
for i in tree0*; do nohup ./${i} & done
for i in $file; do mv ${i}.out ${i}.linsi.out; done

#使用mafft-einsi进行多序列比对，结果后缀einsi.out
for i in $file; do echo "einsi ${i}.one4species.fa > ${i}.einsi.out" >> tree.einsi.sh; done
split -l 13 tree.einsi.sh -d tree.einsi
chmod +x tree.einsi0*
for i in tree.einsi0*; do nohup ./${i} & done

#Gblocks截取保守片段
#----针对linsi.out多序列比对结果，截取保守片段，所得序列要多于einsi.out的结果。
for i in $file; do echo "Gblocks ${i}.linsi.out -b1=13 -e=-ligb" >> work.ligb.sh; done
chmod +x work.ligb.sh
nohup ./work.ligb.sh &

for i in $file; do echo "Gblocks ${i}.einsi.out -b1=13 -e=-eigb" >> work.eigb.sh; done
chmod +x work.eigb.sh
nohup ./work.eigb.sh &

cd ortho_for_species_tree
for i in $file; do  cat ${i}.linsi.out-ligb >> 63_linsi.ligb.out; done
python3 ../delete_enter_in_seq.py 63_linsi.ligb.out > 63_linsi.ligb.out2
sed -i 's/ //g' 63_linsi.ligb.out2

for i in $file; do  cat ${i}.einsi.out-eigb >> 63_einsi.eigb.out; done
python3 ../delete_enter_in_seq.py 63_einsi.eigb.out > 63_einsi.eigb.out2
sed -i 's/ //g' 63_einsi.eigb.out2

cd ..
grep '>'  63_linsi.ligb.out2|wc -l #查看序列总数n，用n除以物种数目，即可得到下一步python脚本所需的i参数。
python3 concatenation.py 63_linsi.ligb.out2 species_id.txt > 63OG_18species.ligb.fa
#注意修改concatenation.py中的i==参数！！！！
python3 concatenation.py 63_einsi.eigb.out2 species_id.txt >63OG_18species.eingb.fa
注意，有时候因为物种蛋白序列存在稀有氨基酸，会导致mafft无法正常运行，如下：
=========================================================================
=========================================================================
===
=== Alphabet 'U' is unknown.
=== Please check site 15 in sequence 8.
===
=== To make an alignment that has unusual characters (U, @, #, etc), try
=== % mafft --anysymbol input > output
===
=========================================================================
=========================================================================
Illegal character U
这种情况会导致真正用到的序列数<低拷贝基因家族数。
另一个导致最终贡献保守序列位点减少的原因是，在Gblocks筛选保守区块时，无法找到满足条件的保守区块。
因此绝大部分情况下，最终建树使用的序列数目要少于低拷贝基因家族数。


nohup ./work.iqtree.sh & 
iqtree -s 63OG_18species.ligb.fa -m MFP -bb 1000


2.  gene family expansion and contraction
2.1 利用r8s构建超度量树
/vol3/agis/huangsanwen_group/fangyuhan/01_Adc/08_gene_family/18chname_species_Results/r8s/work.r8s.sh
#得到的超度量树作为cafe的输入文件

#r8s -b -f r8s_in.txt > r8s_out.txt
#r8s -b -f r8s_in2.txt > r8s_out2.txt
#r8s -b -f r8s_in3.txt > r8s_out3.txt
#r8s -b -f r8s_in3.txt > r8s_out3_reroot.txt
r8s -b -f r8s_in3_1687OG.txt > r8s_out3_1687OG.txt
#r8s -b -f r8s_in4.txt > r8s_out4.txt

2.2 cafe for gene family expansion and contraction analysis

pipeline:/vol3/agis/huangsanwen_group/fangyuhan/01_Adc/08_gene_family/18chname_species_Results/cafe/cafe/cafe_command_reroot.sh
#cafe是交互式界面，运行cafe后，按pipeline先后录入数据即可。

#!/vol1/agis/huangsanwen_group/fangyuhan/software/anaconda3/bin/cafe
version
date
#load -i cafe.des.filter.txt -t 50 -l ./reports/log.out -p 0.01
load -i cafe.des.filter.txt2 -t 10 -l ./reports/log.start -p 1
tree (((Men:614.563541,Smu:614.563541):108.462570,((Mpo:481.088591,Ppa:481.088591):61.572729,(Smo:500.685501,((((((Ath:97.853028,Csa:97.853028):19.146972,Vvi:117.000000):53.000000,(Osa:48.000000,Zma:48.000000):122.000000):42.845033,Atr:212.845033):125.911101,(Gbi:271.000000,(Pab:119.007473,Pta:119.007473):151.992527):67.756134):111.243866,(Adc:233.782244,(Afi:171.254489,Scu:171.254489):62.527755):216.217756):50.685501):41.975819):180.364791):426.004483,Kni:1149.030594)
#tree (Adc:0.000207,(Afi:0.000226,Scu:0.000275):0.000310,((((((Ath:0.001338,Csa:0.000835):0.000986,Vvi:0.000456)ATVV:0.000716,(Osa:0.000806,Zma:0.000846)OSZM:0.000866)ATOS:0.000696,Atr:0.000415):0.000571,(Gbi:0.000228,(Pab:0.000240,Pta:0.000351):0.000337)GBPT:0.000490):0.000891,(((Kni:0.000895,(Men:0.000695,Smu:0.000886):0.000852):0.000989,(Mpo:0.000379,Ppa:0.000441)MPPP:0.000949):0.001259,Smo:0.000605):0.001375):0.001721)ATAC
#tree (Adc:450,(Afi:349,Scu:349):101,((((((Ath:99,Csa:98):19,Vvi:117):53,(Osa:48,Zma:48):122):45,Atr:215):125,(Gbi:271,(Pab:120,Pta:120):151):69):79,(((Kni:333,(Men:287,Smu:287):46):70,(Mpo:395,Ppa:395):8):7,Smo:410):9):31);
lambda -l 0.00005599320035
report ./reports/log.start.out

3. gene family gain and loss
dollop 
/public/agis/yanjianbin_group/liaoqinggang/05_pipeline/dollop
#输入的树需要定根。













假设有下面三种形式的进化树：
[1] (a, b, c);      无根树
[2] (a, b, c):1;   有根树
[3] ((a,b),c);      有根树
除第一种形式的进化树外，其它两种形式的进化树都是有根树。R语言对有根树、无根树的判断是：
如果最外层大括号内只有两个分枝，即为有根树，如[3]；
如果最外层大括号内有三个或以上分枝，一般为无根树，如[1]；
但是，如果大括号外存在枝长参数，如[2]中的:1，这种情况认为三个分枝以一定的枝长连接到根上，为有根树。














































