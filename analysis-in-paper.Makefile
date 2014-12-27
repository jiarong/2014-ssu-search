# Makefile to do analysis in SSUsearch paper

Makefile:=/mnt/lustre_scratch_2012/tg/g/dataForPaper/RNA/jobs/cluster/ssusearch/Makefile
Scriptdir:=/mnt/lustre_scratch_2012/tg/g/dataForPaper/RNA/jobs/cluster/ssusearch/scripts/
Datadir:=/mnt/lustre_scratch_2012/tg/g/dataForPaper/RNA/jobs/cluster/ssusearch/analysis_in_paper/data/
Design:=/mnt/lustre_scratch_2012/tg/g/dataForPaper/RNA/jobs/cluster/ssusearch/analysis_in_paper/SS.design
SSUsearch_db:=/mnt/scratch/tg/g/dataForPaper/RNA/jobs/cluster/ssusearch/SSUsearch_db

override Makefile:=$(realpath $(Makefile))
override Scriptdir:=$(realpath $(Scriptdir))
override Datadir:=$(realpath $(Datadir))

export Script_dir:=$(Scriptdir)

# intermediate parameters
Pt_files=$(wildcard $(Datadir)/*_PT.fa)
Sg_files=$(filter-out $(Pt_files), $(wildcard $(Datadir)/*.fa))

# *** do search on all data

all: ssusearch_on_all_data SB1_and_M1 SB1_PT_vs_SB1_123 SB1_456_vs_SB1_123 \
	M1_vs_M1_PT C_vs_M


.PHONY:

ssusearch_on_all_data: $(Pt_files) $(Sg_files)
	make -f $(Makefile) ssusearch Method=align_only Seqfiles="$(Pt_files)"
	make -f $(Makefile) ssusearch Method=ssusearch_no_qc Seqfiles="$(Sg_files)"

# 1 lane analysis 
# -amplicon vs shotgun in SB1 and M1
# -compare replicates
# -copy correction

SB1_and_M1_files:=$(filter %SB1_PT.fa %SB1.fa %M1_PT.fa %M1.fa, $(Pt_files) $(Sg_files))
SB1_and_M1_SG_files:=$(filter %SB1.fa %M1.fa, $(Sg_files))

# file names for SB1
SB1_PT_silva:=$(Datadir)/SB1_PT.fa.ssu.out/dummy.qc.ssu.align.filter.wang.silva.taxonomy.count
SB1_SG_silva:=$(Datadir)/SB1.fa.ssu.out/dummy.qc.ssu.align.filter.wang.silva.taxonomy.count
SB1_PT_rdp:=$(Datadir)/SB1_PT.fa.ssu.out/dummy.qc.ssu.align.filter.wang.rdp.taxonomy.count
SB1_SG_rdp:=$(Datadir)/SB1.fa.ssu.out/dummy.qc.ssu.align.filter.wang.rdp.taxonomy.count

SB1_SG_silva_lsu:=$(Datadir)/SB1.fa.lsu.out/dummy.qc.lsu.align.filter.wang.silva.taxonomy.count

SB1_SG_gg:=$(Datadir)/SB1.fa.ssu.out/dummy.qc.ssu.align.filter.wang.gg.taxonomy.count
SB1_SG_gg_cc:=$(Datadir)/SB1.fa.ssu.out/dummy.qc.ssu.align.filter.wang.gg.taxonomy.cc.count

# file names for M1
M1_PT_silva:=$(Datadir)/M1_PT.fa.ssu.out/dummy.qc.ssu.align.filter.wang.silva.taxonomy.count
M1_SG_silva:=$(Datadir)/M1.fa.ssu.out/dummy.qc.ssu.align.filter.wang.silva.taxonomy.count
M1_PT_rdp:=$(Datadir)/M1_PT.fa.ssu.out/dummy.qc.ssu.align.filter.wang.rdp.taxonomy.count
M1_SG_rdp:=$(Datadir)/M1.fa.ssu.out/dummy.qc.ssu.align.filter.wang.rdp.taxonomy.count

M1_SG_silva_lsu:=$(Datadir)/M1.fa.lsu.out/dummy.qc.lsu.align.filter.wang.silva.taxonomy.count

M1_SG_gg:=$(Datadir)/M1.fa.ssu.out/dummy.qc.ssu.align.filter.wang.gg.taxonomy.count
M1_SG_gg_cc:=$(Datadir)/M1.fa.ssu.out/dummy.qc.ssu.align.filter.wang.gg.taxonomy.cc.count
SB1_and_M1_files.taxonomy:=./SB1_and_M1_files.taxonomy
SB1_and_M1:
	rm -f $(SB1_PT_silva) $(SB1_SG_silva) $(M1_PT_silva) $(M1_SG_silva) 
	make -f $(Makefile) taxonomy_silva Seqfiles="$(SB1_and_M1_files)" Gene_db=$(SSUsearch_db)/Gene_db.ssu_rdp_rep.fasta Gene_tax=$(SSUsearch_db)/Gene_tax.ssu_rdp_rep.tax \
	&& mv $(SB1_PT_silva) $(SB1_PT_rdp) \
	&& mv $(SB1_SG_silva) $(SB1_SG_rdp) \
	&& mv $(M1_PT_silva) $(M1_PT_rdp) \
	&& mv $(M1_SG_silva) $(M1_SG_rdp)
	# rename prerequisite of taxonomy_silva so it will rerun	

	make -f $(Makefile) taxonomy_silva Seqfiles="$(SB1_and_M1_files)"

	make -f $(Makefile) taxonomy_silva Seqfiles="$(SB1_and_M1_SG_files)" Gene=lsu Gene_db=$(SSUsearch_db)/Gene_db.lsu_silva_rep.fasta Gene_tax=$(SSUsearch_db)/Gene_tax.lsu_silva_rep.tax Ali_template=$(SSUsearch_db)/Ali_template.test_lsu.fasta Hmm=$(SSUsearch_db)/Hmm.lsu.hmm
	make -f $(Makefile) taxonomy_cc Seqfiles="$(SB1_and_M1_files)"

	# plot taxonomy and copy corrected taxonomy
	mkdir -p $(SB1_and_M1_files.taxonomy)
	cd $(SB1_and_M1_files.taxonomy) \
	&& ln -sf $(SB1_PT_rdp) RDP-AMP-SSU.SB1.taxonomy.count \
	&& ln -sf $(SB1_SG_rdp) RDP-WGS-SSU.SB1.taxonomy.count \
	&& ln -sf $(SB1_PT_silva) SILVA-AMP-SSU.SB1.taxonomy.count \
	&& ln -sf $(SB1_SG_silva) SILVA-WGS-SSU.SB1.taxonomy.count \
	&& ln -sf $(SB1_SG_silva_lsu) SILVA-WGS-LSU.SB1.taxonomy.count \
	&& python $(Scriptdir)/plot-taxa-count.py 2 PT_vs_SG_taxonomy.SB1 RDP-AMP-SSU.SB1.taxonomy.count RDP-WGS-SSU.SB1.taxonomy.count SILVA-AMP-SSU.SB1.taxonomy.count SILVA-WGS-SSU.SB1.taxonomy.count SILVA-WGS-LSU.SB1.taxonomy.count \
	&& ln -sf $(M1_PT_rdp) RDP-AMP-SSU.M1.taxonomy.count \
	&& ln -sf $(M1_SG_rdp) RDP-WGS-SSU.M1.taxonomy.count \
	&& ln -sf $(M1_PT_silva) SILVA-AMP-SSU.M1.taxonomy.count \
	&& ln -sf $(M1_SG_silva) SILVA-WGS-SSU.M1.taxonomy.count \
	&& ln -sf $(M1_SG_silva_lsu) SILVA-WGS-LSU.M1.taxonomy.count \
	&& python $(Scriptdir)/plot-taxa-count.py 2 PT_vs_SG_taxonomy.M1 RDP-AMP-SSU.M1.taxonomy.count RDP-WGS-SSU.M1.taxonomy.count SILVA-AMP-SSU.M1.taxonomy.count SILVA-WGS-SSU.M1.taxonomy.count SILVA-WGS-LSU.M1.taxonomy.count \
	&& ln -sf $(SB1_SG_gg) SB1.taxonomy.count \
	&& ln -sf $(SB1_SG_gg_cc) SB1-CC.taxonomy.count \
	&& python $(Scriptdir)/plot-taxa-count.py 2 CC_vs_noCC_taxonomy.SB1 SB1.taxonomy.count SB1-CC.taxonomy.count \
	&& python $(Scriptdir)/plot-taxa-ratio.py 2 CC_vs_noCC_taxonomy_ratio.SB1 SB1.taxonomy.count SB1-CC.taxonomy.count \
	&& ln -sf $(M1_SG_gg) M1.taxonomy.count \
	&& ln -sf $(M1_SG_gg_cc) M1-CC.taxonomy.count \
	&& python $(Scriptdir)/plot-taxa-count.py 2 CC_vs_noCC_taxonomy.M1 M1.taxonomy.count M1-CC.taxonomy.count \
	&& python $(Scriptdir)/plot-taxa-ratio.py 2 CC_vs_noCC_taxonomy_ratio.M1 M1.taxonomy.count M1-CC.taxonomy.count


SB1_PT_and_SB1_123_files:=$(filter %SB1_PT.fa %SB1_123.fa, $(Pt_files) $(Sg_files))
SB1_PT_vs_SB1_123_dir:=./SB1_PT_vs_SB1_123.diversity
SB1_PT_vs_SB1_123:
	make -f $(Makefile) clean Seqfiles="$(SB1_PT_and_SB1_123_files)"
	make -f $(Makefile) make_biom Seqfiles="$(SB1_PT_and_SB1_123_files)" Start=1200 End=1350 Diversity_dir=$(SB1_PT_vs_SB1_123_dir)
	make -f $(Makefile) clean Seqfiles="$(SB1_PT_and_SB1_123_files)"
	# do the clean due to shared clustering dir
	# plot
	python $(Scriptdir)/plot-otu-corr-scatter.py $(SB1_PT_vs_SB1_123_dir)/SS.shared $(SB1_PT_vs_SB1_123_dir)/SB1_PT_vs_SB1_123.otu_corr_scatter "SB1_PT,SB1_123"

SB1_456_and_SB1_123_files:=$(filter %SB1_456.fa %SB1_123.fa, $(Pt_files) $(Sg_files))
SB1_456_vs_SB1_123_dir:=./SB1_456_vs_SB1_123.diversity
SB1_456_vs_SB1_123:
	make -f $(Makefile) clean Seqfiles="$(SB1_456_and_SB1_123_files)" Diversity_dir=$(SB1_456_vs_SB1_123_dir)
	make -f $(Makefile) make_biom Seqfiles="$(SB1_456_and_SB1_123_files)" Start=1200 End=1350 Diversity_dir=$(SB1_456_vs_SB1_123_dir)
	make -f $(Makefile) clean Seqfiles="$(SB1_456_and_SB1_123_files)" Diversity_dir=$(SB1_456_vs_SB1_123_dir)
	# plot 
	python $(Scriptdir)/plot-otu-corr-scatter.py $(SB1_456_vs_SB1_123_dir)/SS.shared $(SB1_456_vs_SB1_123_dir)/SB1_456_vs_SB1_123.otu_corr_scatter "SB1_123,SB1_456"
	# R2 calculation fail in test when cutoff (sys.argv[2]) goes higher
	-(python $(Scriptdir)/plot-otu-corr-r2.py 25 $(SB1_456_vs_SB1_123_dir)/SS.shared $(SB1_456_vs_SB1_123_dir)/SB1_456_vs_SB1_123.otu_corr_r2 "SB1_123,SB1_456")

M1_and_M1_PT_files:=$(filter %M1_PT.fa %M1.fa, $(Pt_files) $(Sg_files))
M1_vs_M1_PT_dir:=./M1_vs_M1_PT.diversity
M1_vs_M1_PT:
	make -f $(Makefile) clean Seqfiles="$(M1_and_M1_PT_files)" Diversity_dir=$(M1_vs_M1_PT_dir)
	make -f $(Makefile) make_biom Seqfiles="$(M1_and_M1_PT_files)" Diversity_dir=$(M1_vs_M1_PT_dir)
	make -f $(Makefile) clean Seqfiles="$(M1_and_M1_PT_files)" Diversity_dir=$(M1_vs_M1_PT_dir)
	# plot 
	python $(Scriptdir)/plot-otu-corr-scatter.py $(M1_vs_M1_PT_dir)/SS.shared $(M1_vs_M1_PT_dir)/M1_vs_M1_PT.otu_corr_scatter "M1,M1_PT"

corn_and_miscanthus_files:=$(wildcard $(Datadir)/[CM]?.fa) $(wildcard $(Datadir)/[CM]?_PT.fa)
C_and_M_SG_files:=$(wildcard $(Datadir)/[CM]?.fa)
V4_PT_and_SG_dir:=./CvsM.V4.PT_SG.diversity
V4_PT_and_SG_cc_dir:=./CvsM.V4.PT_SG.diversity_cc

V2_dir:=./CvsM.V2.diversity
V4_dir:=./CvsM.V4.diversity
V6_dir:=./CvsM.V6.diversity
V8_dir:=./CvsM.V8.diversity
plot_dir:=./CvsM.plot
C_vs_M:
	make -f $(Makefile) clean Seqfiles="$(corn_and_miscanthus_files)"
	make -f $(Makefile) diversity Diversity_dir=$(V4_PT_and_SG_dir) Seqfiles="$(corn_and_miscanthus_files)" Design=$(Design)
	make -f $(Makefile) diversity_cc Diversity_cc_dir=$(V4_PT_and_SG_cc_dir) Seqfiles="$(corn_and_miscanthus_files)" Design=$(Design)

	make -f $(Makefile) clean Seqfiles="$(corn_and_miscanthus_files)"
	make -f $(Makefile) diversity Diversity_dir=$(V2_dir) Seqfiles="$(C_and_M_SG_files)" Design=$(Design) Start=100 End=250
	make -f $(Makefile) clean Seqfiles="$(C_and_M_SG_files)"
	make -f $(Makefile) diversity Diversity_dir=$(V4_dir) Seqfiles="$(C_and_M_SG_files)" Design=$(Design) Start=550 End=700
	make -f $(Makefile) clean Seqfiles="$(C_and_M_SG_files)"
	make -f $(Makefile) diversity Diversity_dir=$(V6_dir) Seqfiles="$(C_and_M_SG_files)" Design=$(Design) Start=970 End=1120
	make -f $(Makefile) clean Seqfiles="$(C_and_M_SG_files)"
	make -f $(Makefile) diversity Diversity_dir=$(V8_dir) Seqfiles="$(C_and_M_SG_files)" Design=$(Design) Start=1200 End=1350
	make -f $(Makefile) clean Seqfiles="$(C_and_M_SG_files)"
	# 4 regions
	# plot
	mkdir -p $(plot_dir)
	python $(Scriptdir)/plot-pcoa-for-kbs.py $(V4_PT_and_SG_dir)/SS.thetayc.dummy.lt.pcoa.axes $(V4_PT_and_SG_dir)/SS.thetayc.dummy.lt.pcoa.loadings "C,M"  $(plot_dir)/V4_pcoa.pdf
	python $(Scriptdir)/plot-pcoa-for-kbs.py $(V4_PT_and_SG_cc_dir)/SS.thetayc.dummy.lt.pcoa.axes $(V4_PT_and_SG_cc_dir)/SS.thetayc.dummy.lt.pcoa.loadings "C,M" $(plot_dir)/V4_cc_pcoa.pdf
	# compare V regions
	python $(Scriptdir)/plot-diversity-index.py dummy "invsimpson" "C,M" "$(V2_dir)/SS.groups.summary,$(V4_dir)/SS.groups.summary,$(V6_dir)/SS.groups.summary,$(V8_dir)/SS.groups.summary" "V2,V4,V6,V8" $(plot_dir)/CvsM.V2_V4_V6_V8.div_index.pdf
	# plot  proscrutes, requires qiime
	python $(Scriptdir)/merge-pcoa-axes-loading.py $(V2_dir)/SS.thetayc.dummy.lt.pcoa.axes $(V2_dir)/SS.thetayc.dummy.lt.pcoa.loadings $(V2_dir)/V2.pcoa
	python $(Scriptdir)/merge-pcoa-axes-loading.py $(V4_dir)/SS.thetayc.dummy.lt.pcoa.axes $(V4_dir)/SS.thetayc.dummy.lt.pcoa.loadings $(V4_dir)/V4.pcoa
	python $(Scriptdir)/merge-pcoa-axes-loading.py $(V6_dir)/SS.thetayc.dummy.lt.pcoa.axes $(V6_dir)/SS.thetayc.dummy.lt.pcoa.loadings $(V6_dir)/V6.pcoa
	python $(Scriptdir)/merge-pcoa-axes-loading.py $(V8_dir)/SS.thetayc.dummy.lt.pcoa.axes $(V8_dir)/SS.thetayc.dummy.lt.pcoa.loadings $(V8_dir)/V8.pcoa
	transform_coordinate_matrices.py -d 2 -i $(V4_dir)/V4.pcoa,$(V6_dir)/V6.pcoa,$(V8_dir)/V8.pcoa,$(V2_dir)/V2.pcoa -o $(plot_dir)/ -r 1000
	python $(Scriptdir)/plot-pcoa-procrutes-color.py "$(V2_dir)/V2.pcoa,$(V4_dir)/V4.pcoa,$(V6_dir)/V6.pcoa,$(V8_dir)/V8.pcoa" "V2,V4,V6,V8" "C,M" $(plot_dir)/CvsM.V2_V4_V6_V8.procrutes.pdf

clean:
	rm -rf $(SB1_and_M1_files.taxonomy) $(SB1_PT_vs_SB1_123_dir) $(SB1_456_vs_SB1_123_dir) $(M1_vs_M1_PT_dir) $(V4_PT_and_SG_dir) $(V4_PT_and_SG_cc_dir) $(V2_dir) $(V4_dir) $(V6_dir) $(V8_dir) $(plot_dir)
