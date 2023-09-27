# Rule for variant calling on Illumina samples using freebayes
rule freebayes_illumina:
    input:
        ref = reference_genome,
        bam = results_dir / "primer_clipping/illumina_clipped.bam"
    output:
        vcf = results_dir / "variant_calling/freebayes-illumina.vcf"
    log:
        "results/log/variant_calling/freebayes_illumina.log"
    conda:
        "../envs/variant_calling.yaml"
    benchmark:
        benchmark_dir / "variant_calling" / "freebayes_illumina.txt"
    shell:
        """
        samtools faidx {input.ref}
        freebayes -f {input.ref} --min-alternate-count 10 --min-alternate-fraction 0.1 --min-coverage 20 --pooled-continuous --haplotype-length -1 {input.bam} > {output.vcf} 2>> {log}
        """

# Rule for variant calling on Nanopore samples using Medaka
#TODO: yaml erstellen
rule medaka_nanopore:
    input:
        ref = reference_genome,
        bam = results_dir / "primer_clipping/nanopore_clipped.bam"
    output:
        vcf = results_dir / "variant_calling/medaka-nanopore.vcf",
        annotate_vcf = results_dir / "variant_calling/medaka-nanopore.annotate.vcf"
    log:
        "results/log/variant_calling/medaka_nanopore.log"
    conda:
        "../envs/medaka.yaml"
    benchmark:
        benchmark_dir / "variant_calling" / "medaka_nanopore.txt"
    shell:
        """
        medaka consensus --model r941_min_hac_g507 --threads 4 --chunk_len 800 --chunk_ovlp 400 {input.bam} medaka-nanopore.consensus.hdf 2>> {log}
        medaka variant {input.ref} medaka-nanopore.consensus.hdf {output.vcf} 2>> {log}
        medaka tools annotate {output.vcf} {input.ref} {input.bam} {output.annotate_vcf} 2>> {log}
        """
