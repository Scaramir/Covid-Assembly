# Rule for compressing and indexing the VCF file
rule compress_index_vcf:
    input:
        annotate_vcf = results_dir / "variant_calling" / "medaka-nanopore.annotate.vcf"
    output:
        vcf_gz = results_dir / "consensus" / "medaka-nanopore.annotate.vcf.gz",
        vcf_gz_tbi = results_dir / "consensus" / "medaka-nanopore.annotate.vcf.gz.tbi"
    log:
        "results/log/consensus/medaka-nanopore_compress_index.log"
    conda:
        "../envs/consensus.yaml"
    benchmark:
        benchmark_dir / "consensus" / "medaka-nanopore_compress_index.txt"
    shell:
        """
        bgzip -f -c {input.annotate_vcf} > {output.vcf_gz}
        tabix -f -p vcf {output.vcf_gz} 2>> {log}
        """


# TODO: adjust according to this: https://github.com/rki-mf1/2023-SC2-Data-Science/blob/main/day-sc2-seq-and-assembly/hands-on.md#consensus-generation
# TODO: NC_045512.2 allgemein halten
# Rule for generating a consensus sequence from the VCF file
rule generate_consensus:
    input:
        ref = reference_genome,
        vcf = results_dir / "consensus" / "medaka-nanopore.annotate.vcf.gz",
        vcf_idx = results_dir / "consensus" / "medaka-nanopore.annotate.vcf.gz.tbi"
    output:
        fasta = results_dir / "consensus/medaka-nanopore_consensus.fasta"
    log:
        "results/log/consensus/medaka-nanopore_consensus.log"
    conda:
        "../envs/consensus.yaml"
    benchmark: 
        benchmark_dir / "consensus.txt"
    shell:
        """
        bcftools consensus -f {input.ref} {input.vcf} -o {output.fasta} 2>> {log}
        sed -i 's/NC_045512.2/Consensus-Nanopore/g' {output.fasta}
        """

# TODO: use pangolin for lineage assignment/annotation
# TODO: use president to perform QC on the consensus sequences
# TODO: think about performing MSA on the consensus sequences and then generating 
#       a phylogenetic tree from that MSA to see how much the sequences differ from each other