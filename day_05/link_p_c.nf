#!/usr/bin/env nextflow
 
process SPLITLETTERS {
input:
    tuple val(meta), val(in_str), val(out_name)

    output:
    tuple val(meta), path("${out_name}_*")

    script:
    """
    printf '%s' "${in_str}" | split -b ${meta.id} - ${out_name}_
    """
} 

process CONVERTTOUPPER {
    input:
    path chunk

    output:
    stdout

    script:
    """
    cat ${chunk} | tr '[:lower:]' '[:upper:]'
    """
}

process LISTCHUNKS {
    debug true

    input:
    path chunks

    script:
    """
    echo "Chunk files: ${chunks}"
    ls -l ${chunks}
    """
}


workflow { 
    // 1. Read in the samplesheet (samplesheet_2.csv)  into a channel. The block_size will be the meta-map
    sheet2_ch = channel.fromPath('./samplesheet_2.csv')
        .splitCsv(header: true)
        .map { row -> [[id: row.block_size], row.input_str, row.out_name] }
    
    // 2. Create a process that splits the "in_str" into sizes with size block_size. The output will be a file for each block, named with the prefix as seen in the samplesheet_2
    split_ch = SPLITLETTERS(sheet2_ch)
    
    chunks_ch = split_ch
        .map { meta, files -> files }
        .flatten()


    // 4. Feed these files into a process that converts the strings to uppercase. The resulting strings should be written to stdout
    upper_ch = CONVERTTOUPPER(chunks_ch)
    upper_ch.view()
    // read in samplesheet}

    // split the input string into chunks
        
    // lets remove the metamap to make it easier for us, as we won't need it anymore

    // convert the chunks to uppercase and save the files to the results directory

    upper_ch.collectFile(name: 'upper.txt', storeDir: 'results', newLine: true)    


    //For listing the path to the chunk files:

    chunk_list_ch = chunks_ch.collect(sort: true)

    LISTCHUNKS(chunk_list_ch)

}