
# How many reads where aligned? What’s the read quality?
rule samtools_flagstat:
    input:
        bam = "output/mapping/minimap2-{sample}.sorted.bam"
    output:
        txt = "results/stats/minimap2-{sample}_flagstat.txt"
    log:
        "results/log/stats/minimap2-{sample}_flagstat.log"
    conda:
        "../envs/mapping.yaml"
    shell:
        """
        samtools flagstat {input.bam} > {output.txt} 2>> {log}
        """

# Read length distribution
rule samtools_stats:
    input:
        bam = "output/mapping/minimap2-{sample}.sorted.bam"
    output:
        txt = "results/stats/minimap2-{sample}_stats.txt"
    log:
        "results/log/stats/minimap2-{sample}_stats.log"
    conda:
        "../envs/mapping.yaml"
    shell:
        """
        samtools stats {input.bam} > {output.txt} 2>> {log}
        """
# Pot Read length distribution
# rule plot_bamstats:
#     input:
#         txt = "results/stats/minimap2-{sample}_stats.txt"
#     output:
#         png = "results/stats/minimap2-{sample}_length_distribution.png"
#     conda:
#         "../envs/mapping.yaml"
#     shell:
#         """
#         plot-bamstats -p results/stats/{wildcards.sample}_ {input.txt}
#         """
