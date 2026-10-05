params {
    step: Integer = 0
}


workflow{

    // Task 1 - Read in the samplesheet.

    if (params.step == 1) {
        channel.fromPath('./samplesheet.csv')
            .splitCsv(header: true)
            .view()
    }

    // Task 2 - Read in the samplesheet and create a meta-map with all metadata and another list with the filenames ([[metadata_1 : metadata_1, ...], [fastq_1, fastq_2]]).
    //          Set the output to a new channel "in_ch" and view the channel. YOU WILL NEED TO COPY AND PASTE THIS CODE INTO SOME OF THE FOLLOWING TASKS (sorry for that).

   if (params.step == 2) {
    in_ch = channel.fromPath('./samplesheet.csv')
        .splitCsv(header: true)
        .map { row ->
            def meta  = [id: row.sample, strandedness: row.strandedness]
            def reads = [file(row.fastq_1), file(row.fastq_2)]
            [meta, reads]
        }

    in_ch.view()
}

    // Task 3 - Now we assume that we want to handle different "strandedness" values differently. 
    //          Split the channel into the right amount of channels and write them all to stdout so that we can understand which is which.

    if (params.step == 3) {
        in_ch = channel.fromPath('./samplesheet.csv')
        .splitCsv(header: true)
        .map { row ->
            def meta  = [id: row.sample, strandedness: row.strandedness]
            def reads = [file(row.fastq_1), file(row.fastq_2)]
            [meta, reads]
        }

        strand_ch = in_ch.branch{ meta, reads ->
            auto: meta.strandedness == "auto"
            reverse: meta.strandedness == "reverse"
            forward: meta.strandedness == "forward"
        }

        strand_ch.auto.toList().view{list -> "Strand is auto: ${list}"}
        strand_ch.reverse.toList().view{list -> "Strand is reverse: ${list}"}
        strand_ch.forward.toList().view{list -> "Strand is forward: ${list}"}
    }

    // Task 4 - Group together all files with the same sample-id and strandedness value.

    if (params.step == 4) {
        in_ch = channel.fromPath('./samplesheet.csv')
        .splitCsv(header: true)
        .map { row ->
            def meta  = [id: row.sample, strandedness: row.strandedness]
            def reads = [file(row.fastq_1), file(row.fastq_2)]
            [meta, reads]
        }

        group_ch = in_ch.groupTuple()

        group_ch.view()
        
    }



}