using DependencyExtraction

function runExample() 
    path = "/Applications/Julia-1.6.app/Contents/Resources/julia/share/julia/stdlib/v1.6/Test/src/Test.jl"
    # path = "/Users/alexandrebergel/.julia/dev/GeneticAlgorithm/src/GeneticAlgorithm.jl"
    f = open(path)
    content = read(f, String)
    close(f)

    model = DEModel()
    importCode(model, content)
    println("Number of functions = " * string(numberOfFunctions(model)))

    runFunction = getFunction(model, "run")
    println("Number of calls by run = " * string(numberOfOutgoingCallnames(runFunction)))
    println("Calls = " * string(runFunction.outgoingCallnames))

    dumpAsCSV(model, "/Users/alexandrebergel/Desktop/TMP/test.jl.csv")
end

function get42()
    return 42
end


runExample() 
