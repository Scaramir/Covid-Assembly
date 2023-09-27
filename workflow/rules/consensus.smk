
sample_to_vcf = {
    'nanopore': 'medaka-nanopore.annotate.vcf',
    'illumina': 'freebayes-illumina.vcf'
}

# Rule for compressing and indexing the VCF file
#TODO results to resultsdir ändern
rule compress_index_vcf:
    input:
        vcf = lambda wildcards: f"results/variant_calling/{sample_to_vcf[wildcards.sample]}"
        # vcf = results_dir / "variant_calling" / "freebayes-illumina.vcf"
        # annotate_vcf = results_dir / "variant_calling" / "medaka-nanopore.annotate.vcf"
    output:
        vcf_gz = results_dir / "consensus" / "{sample}.vcf.gz",
        vcf_gz_tbi = results_dir / "consensus" / "{sample}.vcf.gz.tbi"
    log:
        "results/log/consensus/{sample}_compress_index.log"
    conda:
        "../envs/consensus.yaml"
    benchmark:
        benchmark_dir / "consensus" / "{sample}_compress_index.txt"
    shell:
        """
        bgzip -f -c {input.vcf} > {output.vcf_gz}
        tabix -f -p vcf {output.vcf_gz} 2>> {log}
        """

# TODO: NC_045512.2 allgemein halten
# Rule for generating a consensus sequence from the VCF file
rule generate_consensus:
    input:
        ref = reference_genome,
        vcf = results_dir / "consensus" / "{sample}.vcf.gz",
        vcf_idx = results_dir / "consensus" / "{sample}.vcf.gz.tbi"
    output:
        fasta = results_dir / "consensus/{sample}_consensus.fasta"
    log:
        "results/log/consensus/{sample}_consensus.log"
    conda:
        "../envs/consensus.yaml"
    benchmark: 
        benchmark_dir / "{sample}_consensus.txt"
    shell:
        """
        bcftools consensus -f {input.ref} {input.vcf} -o {output.fasta} 2>> {log}
        sed -i 's/NC_045512.2/Consensus-{wildcards.sample}/g' {output.fasta}
        """

# TODO: use pangolin for lineage assignment/annotation
# TODO: use president to perform QC on the consensus sequences
# TODO: think about performing MSA on the consensus sequences and then generating 
#       a phylogenetic tree from that MSA to see how much the sequences differ from each other