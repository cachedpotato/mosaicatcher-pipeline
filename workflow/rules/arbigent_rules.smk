## Arbigent rules / Developed by Wolfram Hoeps & Hufsah Ashraf
## ---------------------------------------------------------------
## prepare_manual_segments_counts_debug: Take manual segments counts debugfile and prepare it in a way that we can easily extract the information for n informative bins per segment.
## run_regenotypeR_samplewise_singlecell: Invoke regenotype.R for each sample, creating a sv_calls_bulk and associated plots for each sample

if config["arbigent"] is True:

    rule create_hdf_file:
        input:
            mapping_track=config["arbigent_data"]["arbigent_mapability_track"],
        output:
            config["arbigent_data"]["arbigent_mapability_track_h5"],
        log:
            "workflow/data/arbigent/log/create_hdf_file.log",
        conda:
            "../envs/dev/arbigent/mc_base.yaml"
        script:
            "../scripts/arbigent_utils/create_hdf.py"

    rule watson_crick_counts:
        input:
            bam_folder="{folder}/{sample}/selected",
            bed="{folder}/{sample}/arbigent/manual_segmentation/{sample}.bed",
            mapping=config["arbigent_data"]["arbigent_mapability_track"],
            mapping_h5=config["arbigent_data"]["arbigent_mapability_track_h5"],
        output:
            processing_counts="{folder}/{sample}/arbigent/counts/manual_segments_counts.txt.raw",
            debug="{folder}/{sample}/arbigent/counts/manual_segments_counts.txt.raw.debug",
            norm_plot_output="{folder}/{sample}/arbigent/counts/blub.txt",
        log:
            "{folder}/log/arbigent/watson_crick_counts/{sample}/watson_crick_counts.log",
        conda:
            "../envs/dev/arbigent/mc_base.yaml"
        threads: 16
        script:
            "../scripts/arbigent_utils/watson_crick.py"


    rule correct_watson_crick_counts:
        input:
            "{folder}/{sample}/arbigent/counts/manual_segments_counts.txt.raw",
        output:
            "{folder}/{sample}/arbigent/counts/manual_segments_counts.txt",
        log:
            "{folder}/log/arbigent/correct_watson_crick_counts/{sample}/watson_crick_counts.log",
        conda:
            "../envs/dev/arbigent/mc_base.yaml"
        shell:
            "sed 's/.sort.mdup//g' {input} > {output}"


    rule prepare_manual_segments_counts_debug:
        input:
            counts_file="{folder}/{sample}/arbigent/counts/manual_segments_counts.txt.raw.debug",
        output:
            msc="{folder}/{sample}/arbigent/sv_calls/msc.debug",
        log:
            "{folder}/log/arbigent/sv_calls/{sample}/watson_crick_counts.log",
        conda:
            "../envs/dev/arbigent/mc_base.yaml"
        shell:
            """
            awk '!seen[$1,$2,$3]++' {input.counts_file} > {output.msc}
            """


    rule mosaiClassifier_calc_probs_arbigent:
        input:
            # [W] windows_specs is x_fixed_norm. 
            counts="{folder}/{sample}/counts/{sample}.txt.gz",
            info="{folder}/{sample}/counts/{sample}.info",
            states="{folder}/{sample}/strandphaser/StrandPhaseR_final_output.txt",
            bp="{folder}/{sample}/arbigent/counts/manual_segments_counts.txt",
        output:
            output="{folder}/{sample}/mosaiclassifier/sv_probabilities/probabilities.Rdata",
        log:
            "{folder}/log/arbigent/mosaiClassifier_calc_probs_arbigent/{sample}.log",
        conda:
            "../envs/rtools.yaml"
        script:
            "../scripts/arbigent_utils/mosaiclassifier_scripts/mosaiClassifier.snakemake.R"


    # rule mosaiClassifier_make_CN_call_manual_segs:
    #     input:
    #         #probs = "manual_segmentation/{sample}/{window_specs}.{bpdens}/sv_probabilities.Rdata"
    #         # probs = "sv_probabilities/{sample}/{window_specs}.{bpdens}/probabilities.Rdata"
    #         probs="{folder}/{sample}/arbigent/mosaiclassifier/sv_probabilities/probabilities.Rdata",
    #     output:
    #         # calls = "manual_segmentation/{sample}/{window_specs}.{bpdens}/CN_calls.txt"
    #         calls="{folder}/{sample}/arbigent/mosaiclassifier/CN_calls.txt",
    #     log:
    #         "{folder}/log/arbigent/mosaiClassifier_make_CN_call_manual_segs/{sample}.log",
    #     conda:
    #         "../envs/rtools.yaml"
    #     script:
    #         "../scripts/arbigent_utils/mosaiclassifier_scripts/mosaiClassifier_CN_call.snakemake.R"
