
# How many reads where aligned? What’s the read quality?
rule samtools_flagstat:
    input:
        bam = results_dir / "mapping/minimap2-{sample}.sorted.bam"
    output:
        txt = results_dir / "stats/minimap2-{sample}_flagstat.txt"
    log:
        results_dir / "log/stats/minimap2-{sample}_flagstat.log"
    conda:
        envs_dir / "mapping.yaml"
    shell:
        """
        samtools flagstat {input.bam} > {output.txt} 2>> {log}
        """

# Read length distribution
rule samtools_stats:
    input:
        bam = "output/mapping/minimap2-{sample}.sorted.bam"
    output:
        txt = results_dir / "stats/minimap2-{sample}_stats.txt"
    log:
        results_dir / "log/stats/minimap2-{sample}_stats.log"
    conda:
        envs_dir / "mapping.yaml"
    shell:
        """
        samtools stats {input.bam} > {output.txt} 2>> {log}
        """
# Qualimap2 report (HTML)
rule qualimap:
    input:
        bam = results_dir / "mapping" / "minimap2-{sample}.sorted.bam"
    output:
        report = results_dir / "qualimap" / "{sample}" / "qualimapReport.html"
    conda:
        envs_dir / "qualimap.yaml"
    threads:
        4
    log:
        os.path.join(log_dir, "qualimap2", "qualimap2_{sample}.log")
    params:
        output_dir = str(results_dir / "qualimap/{sample}")
    benchmark:
        os.path.join(benchmark_dir, "qualimap2", "qualimap2_{sample}.txt")
    shell:
        "qualimap bamqc -bam {input} -outdir {params.output_dir} -outformat HTML > {log} 2>&1"