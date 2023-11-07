# Rule for variant calling on Illumina samples using freebayes
# first re-calulate the index for the reference FASTA with samtools
rule freebayes_illumina:
    input:
        ref = reference_genome,
        bam = results_dir / "primer_clipping" / "minimap2-illumina.sorted.primerclipped.bam",
    output:
        vcf = results_dir / "variant_calling" / "freebayes-illumina.vcf"
    log:
        results_dir / "log/variant_calling/freebayes_illumina.log"
    conda:
        envs_dir / "variant_calling.yaml"
    benchmark:
        benchmark_dir / "variant_calling" / "freebayes_illumina.txt"
    threads: 
        config["num_threads"]
    shell:
        """
        samtools faidx {input.ref} 
        freebayes -f {input.ref} --min-alternate-count 10 --min-alternate-fraction 0.1 --min-coverage 20 --pooled-continuous --haplotype-length -1 {input.bam} > {output.vcf} 2>> {log}
        """

# Rule for variant calling on Nanopore samples using Medaka
rule medaka_nanopore:
    input:
        ref = reference_genome,
        bam = results_dir / "primer_clipping" / "minimap2-nanopore.sorted.primerclipped.bam",
    output:
        vcf = results_dir / "variant_calling" / "medaka-nanopore.vcf",
        annotate_vcf = results_dir / "variant_calling" / "medaka-nanopore.annotate.vcf",
        outname = results_dir / "variant_calling" / "medaka-nanopore.consensus.hdf"
    log:
        results_dir / "log/variant_calling/medaka_nanopore.log"
    conda:
        envs_dir / "medaka.yaml"
    benchmark:
        benchmark_dir / "variant_calling" / "medaka_nanopore.txt"
    threads: 
        config["num_threads"]
    shell:
        """
        medaka consensus --model r941_min_hac_g507 --threads 4 --chunk_len 800 --chunk_ovlp 400 {input.bam} {output.outname} 2>> {log}
        medaka variant {input.ref} {output.outname} {output.vcf} 2>> {log}
        medaka tools annotate {output.vcf} {input.ref} {input.bam} {output.annotate_vcf} 2>> {log}
        """
