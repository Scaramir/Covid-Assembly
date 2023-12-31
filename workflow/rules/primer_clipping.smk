# Convert the primer files to BEDPE format so we can use them later
rule convert_bed_to_bedpe:
    input:
        bed = primer_illumina if "{sample}" in illumina_samples_df.index else primer_nanopore
    output:
        bedpe = results_dir / "primer_scheme/converted-{sample}.bedpe"
    log:
        results_dir / "log/primer_clipping/convert_bed_to_bedpe_{sample}.log"
    conda:
        envs_dir / "primer_clipping.yaml"
    threads: 
        config["num_threads"]
    shell:
        r"""
        # Check if the file is a BED file by checking the extension
        if [[ "{input.bed}" == *.bed ]]; then
            echo "Converting BED to BEDPE." >> {log}
            python workflow/scripts/primerbed2bedpe.py {input.bed} --forward_identifier _LEFT --reverse_identifier _RIGHT -o {output.bedpe}
        else
            echo "File is already in BEDPE format. No conversion needed." >> {log}
            cp {input.bed} {output.bedpe}
        fi
        """

# Rule for checking and correcting the BED file for both Illumina and Nanopore samples
rule check_and_correct_bed:
    input:
        ref = reference_genome,
        bedpe = results_dir / "primer_scheme/converted-{sample}.bedpe"
    output:
        bedpe_corrected = results_dir / "primer_scheme/corrected-{sample}.bedpe"
    log:
        results_dir / "log/primer_clipping/check_correct_bed_{sample}.log"
    benchmark: 
        benchmark_dir / "primer_clipping" / "check_correct_bed_{sample}.txt"
    threads: 1
    shell:
        r"""
        # Get only the ID part of the FASTA header (assuming it's the first field, separated by space)
        REF_HEADER=$(head -n 1 {input.ref} | awk '{{print $1}}' | sed 's/>//')
        
        # Get the BED header
        BED_HEADER=$(head -n 1 {input.bedpe} | awk '{{print $1}}')
        
        # Check if they match
        if [ "$REF_HEADER" != "$BED_HEADER" ]; then
            echo "Headers do not match. Correcting the BED file." >> {log}
            sed "s/$BED_HEADER/$REF_HEADER/g" {input.bedpe} > {output.bedpe_corrected}
        else
            echo "Headers match. No correction needed." >> {log}
            cp {input.bedpe} {output.bedpe_corrected}
        fi
        """

# Clip the primers from the BAM file
rule bamclipper:
    input:
        bam = results_dir / "mapping" / "minimap2-{sample}.sorted.bam",
        bedpe_corrected = results_dir / "primer_scheme" / "corrected-{sample}.bedpe"
    output:
        bam = results_dir / "primer_clipping" / "minimap2-{sample}.sorted.primerclipped.bam",
        bai = results_dir / "primer_clipping" / "minimap2-{sample}.sorted.primerclipped.bam.bai"
    log:
        results_dir / "log" / "primer_clipping" / "{sample}_bamclipper.log"
    conda:
        envs_dir / "primer_clipping.yaml"
    benchmark:
        benchmark_dir / "primer_clipping" / "{sample}_bamclipper.txt"
    params:
        results_dir = results_dir / "primer_clipping"
    threads: 
        config["num_threads"]
    shell:
        """
        bamclipper.sh -b {input.bam} -p {input.bedpe_corrected} -n 8 2>> {log}
        mv *bam* {params.results_dir} # -o does not exist in bamclipper.sh       
        """
