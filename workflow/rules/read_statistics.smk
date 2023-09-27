rule samtools_flagstat:
    input:
        bam = "output/mapping/{sample}.sorted.bam"
    output:
        txt = "results/stats/{sample}_flagstat.txt"
    log:
        "results/log/stats/{sample}_flagstat.log"
    conda:
        "../envs/mapping.yaml"
    shell:
        """
        samtools flagstat {input.bam} > {output.txt} 2>> {log}
        """
