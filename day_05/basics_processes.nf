params {
    step: Integer = 0
    zip: String = 'zip'
}


process SAYHELLO {
    debug true
    script:
    """
    echo "Hello World!"
    """
}

process SAYHELLO_PYTHON{
    script:
      """
    #!/usr/bin/env python3
    
    x = 'Hello'
    y = 'world!'
    print(f"{x} - {y}")
    """
}

process SAYHELLO_PARAM{
    debug true
    
    input:
    val input

    script:
    """
    echo '$input'
    """
    
}

process SAYHELLO_FILE{
    debug true

    input:
    val greeting_ch

    output:
    path 'process_names.txt'

    script:
    """
    echo $greeting_ch > process_names.txt
    """
}

process UPPERCASE{
    debug true

    input:
    val greeting_ch

    output:
    path 'upper_names.txt'

    script:
    """
    echo "${greeting_ch}" | tr "[a-z]" "[A-Z]" > upper_names.txt
    """
}


process PRINTUPPER{
    debug true

    input:
    path upper_names

    script:
    """
    cat ${upper_names}
    """
}

process ZIP{
    debug true

    input:
    path upper_names

    output:
    path "${upper_names}.*"

    script:
    """
    zip ${upper_names}.zip ${upper_names}
    """
}

process ZIPAND{
    debug true

    input:
    path upper_names

    output:
    path "${upper_names}.*"

    script:
    """
    zip ${upper_names}.zip ${upper_names}

    gzip -c ${upper_names} > ${upper_names}.gz

    bzip2 -c ${upper_names} > ${upper_names}.bz2
    """
}

process WRITETOFILE {
    input:
    val list

    output:
    stdout

    script:
    """
    echo "${list.name}\t${list.title}"
    """
}



workflow {

    // Task 1 - create a process that says Hello World! (add debug true to the process right after initializing to be sable to print the output to the console)
    if (params.step == 1) {
        SAYHELLO()
    }

    // Task 2 - create a process that says Hello World! using Python
    if (params.step == 2) {
        SAYHELLO_PYTHON()
    }

    // Task 3 - create a process that reads in the string "Hello world!" from a channel and write it to command line
    if (params.step == 3) {
        greeting_ch = Channel.of("Hello world!")
        SAYHELLO_PARAM(greeting_ch)
    }

    // Task 4 - create a process that reads in the string "Hello world!" from a channel and write it to a file. WHERE CAN YOU FIND THE FILE?
    if (params.step == 4) {
        greeting_ch = Channel.of("Hello world!")
        SAYHELLO_FILE(greeting_ch)
    }

    // Task 5 - create a process that reads in a string and converts it to uppercase and saves it to a file as output. View the path to the file in the console
    if (params.step == 5) {
        greeting_ch = Channel.of("Hello world!")
        out_ch = UPPERCASE(greeting_ch)
        out_ch.view()
    }

    // Task 6 - add another process that reads in the resulting file from UPPERCASE and print the content to the console (debug true). WHAT CHANGED IN THE OUTPUT?
    if (params.step == 6) {
        greeting_ch = Channel.of("Hello world!")
        out_ch = UPPERCASE(greeting_ch)
        PRINTUPPER(out_ch)
    }

    
    // Task 7 - based on the paramater "zip" (see at the head of the file), create a process that zips the file created in the UPPERCASE process either in "zip", "gzip" OR "bzip2" format.
    //          Print out the path to the zipped file in the console
    if (params.step == 7) {
        greeting_ch = Channel.of("Hello world!")
        ZIP(UPPERCASE(greeting_ch))
    }

    // Task 8 - Create a process that zips the file created in the UPPERCASE process in "zip", "gzip" AND "bzip2" format. Print out the paths to the zipped files in the console

    if (params.step == 8) {
        greeting_ch = Channel.of("Hello world!")
        ZIPAND(UPPERCASE(greeting_ch)).flatten().view()
    }

    // Task 9 - Create a process that reads in a list of names and titles from a channel and writes them to a file.
    //          Store the file in the "results" directory under the name "names.tsv"

    if (params.step == 9) {
        in_ch = channel.of(
            ['name': 'Harry', 'title': 'student'],
            ['name': 'Ron', 'title': 'student'],
            ['name': 'Hermione', 'title': 'student'],
            ['name': 'Albus', 'title': 'headmaster'],
            ['name': 'Snape', 'title': 'teacher'],
            ['name': 'Hagrid', 'title': 'groundkeeper'],
            ['name': 'Dobby', 'title': 'hero'],
        )

        WRITETOFILE(in_ch)
           .map { line -> line.trim()}
           .collectFile(name: 'names.tsv', storeDir: 'results', newLine: true, seed: "name\ttitle")
           .view()
    }

}