module DependencyExtraction

# EXPORT
export DEFunction, getName
export DEModel, numberOfFunctions, importCode

export runOver


mutable struct DEFunction
    name::String
    beginLOC::Int
    endLOC::Int
    outgoingCalls
end
DEFunction() = DEFunction("UNKNOWN", -1, -1, [])

getName(f::DEFunction) = f.name

mutable struct DEModel
    filename::String
    functions
end
DEModel() = DEModel("", [])
numberOfFunctions(model::DEModel) = length(model.functions)

function importCode(m::DEModel, code::String)
    expression = Meta.parse(code)
    println(expression)
end


function runOver(expr::Expr; onCall=(x)->println(x), onValue=(x)->println(x), onSymbol=(x)->println(x))
    runOver(expr.head, onCall=onCall, onValue=onValue, onSymbol=onSymbol)
    for i in expr.args
        runOver(i)
    end
end

function runOver(expr::Symbol; onCall=(x)->println(x), onValue=(x)->println(x), onSymbol=(x)->println(x))
    onSymbol(expr)
end
end
