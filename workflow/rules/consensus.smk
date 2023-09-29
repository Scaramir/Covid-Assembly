
sample_to_vcf = {
    'nanopore': 'medaka-nanopore.annotate.vcf',
    'illumina': 'freebayes-illumina.vcf'
}

# Rule for compressing and indexing the VCF file
rule compress_index_vcf:
    input:
        vcf = lambda wildcards: results_dir / f"variant_calling/{sample_to_vcf[wildcards.sample]}"
        # vcf = results_dir / "variant_calling" / "freebayes-illumina.vcf"
        # annotate_vcf = results_dir / "variant_calling" / "medaka-nanopore.annotate.vcf"
    output:
        vcf_gz = results_dir / "consensus" / "{sample}.vcf.gz",
        vcf_gz_tbi = results_dir / "consensus" / "{sample}.vcf.gz.tbi"
    log:
        results_dir / "log/consensus/{sample}_compress_index.log"
    conda:
        envs_dir / "consensus.yaml"
    benchmark:
        benchmark_dir / "consensus" / "{sample}_compress_index.txt"
    shell:
        """
        bgzip -f -c {input.vcf} > {output.vcf_gz}
        tabix -f -p vcf {output.vcf_gz} 2>> {log}
        """

# Rule for generating a consensus sequence from the VCF file
rule generate_consensus:
    input:
        ref = reference_genome,
        vcf = results_dir / "consensus" / "{sample}.vcf.gz",
        vcf_idx = results_dir / "consensus" / "{sample}.vcf.gz.tbi"
    output:
        fasta = results_dir / "consensus/{sample}_consensus.fasta"
    log:
        results_dir / "log/consensus/{sample}_consensus.log"
    conda:
        envs_dir / "consensus.yaml"
    benchmark: 
        benchmark_dir / "{sample}_consensus.txt"
    shell:
        """
        bcftools consensus -f {input.ref} {input.vcf} -o {output.fasta} 2>> {log}
        sed -i 's/NC_045512.2/Consensus-{wildcards.sample}/g' {output.fasta}
        """

# Pangolin for lineage assignment/annotation
rule pangolin:
    input:
        #consensus = results_dir / "consensus/{sample}_consensus.fasta"
        expand(results_dir / "consensus/{sample}_consensus.fasta", sample=list(illumina_samples_df.index)+list(nanopore_samples_df.index)),
    output:
        lineage = results_dir / "consensus/lineage.csv"
    log:
        results_dir / "log/consensus/lineage.log"
    conda:
        envs_dir / "lineage.yaml"
    benchmark:
        benchmark_dir / "lineage.txt"
    shell:
        """
        cat {input} > all_consensus.fasta
        pangolin -t 4 all_consensus.fasta --outfile {output.lineage} 2>> {log}
        rm all_consensus.fasta
        """

# President to perform QC on the consensus sequences
rule president:
    input:
        consensus = results_dir / "consensus/{sample}_consensus.fasta",
        ref = reference_genome
    output:
        qc = results_dir / "qc/president/{sample}_report.tsv"
    log:
        results_dir / "log/qc/president/{sample}_president.log"
    conda:
        envs_dir / "lineage.yaml"
    benchmark:
        benchmark_dir / "qc/president/{sample}_president.txt"
    params:
        outdir = results_dir / "qc/president"
    shell:
        """
        president -q {input.consensus} -r {input.ref} -x 0.9 -n 0.05 -t 4 -p {params.outdir} -f {wildcards.sample}_ 2>> {log}
        """

# TODO: think about performing MSA on the consensus sequences and then generating 
#       a phylogenetic tree from that MSA to see how much the sequences differ from each other
# TODO: Read the `outlook` slides of the presentation for even more ideas for further improvements