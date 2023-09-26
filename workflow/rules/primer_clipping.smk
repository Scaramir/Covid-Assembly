# #coronavirusWuhan
# # Rule for checking and correcting the BED file for both Illumina and Nanopore samples
rule check_and_correct_bed:
    input:
        ref = reference_genome,
        bedpe = "data/primer_scheme/{primer_sequence}"
    output:
        bedpe_corrected = "data/primer_scheme/corrected-{primer_sequence}"
    log:
        "results/log/primer_clipping/check_correct_bed_{primer_sequence}.log"
    benchmark: 
        benchmark_dir / "primer_clipping" / "check_correct_bed_{primer_sequence}.txt"
    shell:
        r"""
        # Debug: Print the first line of the reference and BED file
        echo "First line of Reference:" >> {log}
        head -n 1 {input.ref} >> {log}

        echo "First line of BED:" >> {log}
        head -n 1 {input.bedpe} >> {log}

        # Get the FASTA header
        REF_HEADER=$(head -n 1 {input.ref} | sed 's/>//')
        
        # Get the BED header
        BED_HEADER=$(head -n 1 {input.bedpe} | awk '{{print $1}}')
        
        # Debug: Print the extracted headers
        echo "Extracted REF_HEADER: $REF_HEADER" >> {log}
        echo "Extracted BED_HEADER: $BED_HEADER" >> {log}

        # Check if they match
        if [ "$REF_HEADER" != "$BED_HEADER" ]; then
            echo "Headers do not match. Correcting the BED file." >> {log}
            sed "s/$BED_HEADER/$REF_HEADER/g" {input.bedpe} > {output.bedpe_corrected}
        else
            echo "Headers match. No correction needed." >> {log}
            cp {input.bedpe} {output.bedpe_corrected}
        fi
        """

# Rule for primer clipping on Illumina samples using BAMclipper
rule bamclipper_illumina:
    input:
        bam = "output/mapping/minimap2-illumina.sorted.bam",
        bedpe = "data/primer_scheme/cleanplex-corrected.amplicons.bedpe"
    output:
        bam = "output/primer_clipping/illumina_clipped.bam"
    log:
        "results/log/primer_clipping/illumina_bamclipper.log"
    conda:
        "../envs/primer_clipping.yaml"
    benchmark: 
        benchmark_dir / "primer_clipping" / "illumina_bamclipper.txt"
    shell:
        """
        bamclipper.sh -b {input.bam} -p {input.bedpe} -n 4 -o {output.bam} 2>> {log}
        """

# Rule for primer clipping on Nanopore samples using BAMclipper
rule bamclipper_nanopore:
    input:
        bam = "output/mapping/minimap2-nanopore.sorted.bam",
        bedpe = "data/primer_scheme/nCoV-2019.bedpe"
    output:
        bam = "output/primer_clipping/nanopore_clipped.bam"
    log:
        "results/log/primer_clipping/nanopore_bamclipper.log"
    conda:
        "../envs/primer_clipping.yaml"
    benchmark:
        benchmark_dir / "primer_clipping" / "nanopore_bamclipper.txt"
    shell:
        """
        bamclipper.sh -b {input.bam} -p {input.bedpe} -n 4 -o {output.bam} 2>> {log}
        """
