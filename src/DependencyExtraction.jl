module DependencyExtraction

# EXPORT
export DEFunction, getName
export DEModel, numberOfFunctions, importCode, addFunction!

export parseString, runOver


mutable struct DEFunction
    name::String
    beginLOC::Int
    endLOC::Int
    outgoingCalls
end
DEFunction() = DEFunction("UNKNOWN", -1, -1, [])
DEFunction(aName::String) = DEFunction(aName, -1, -1, [])

getName(f::DEFunction) = f.name

mutable struct DEModel
    filename::String
    functions
end
DEModel() = DEModel("", [])
numberOfFunctions(model::DEModel) = length(model.functions)
addFunction!(model::DEModel, aFunction::DEFunction) = push!(model.functions, aFunction)


function parseString(code::String)
    Meta.parse("begin $code end")
end

function importCode(m::DEModel, code::String)
    expr = parseString(code)

    function createNewFunction(functionName) 
        addFunction!(m, DEFunction(String(functionName)))
    end
    runOver(expr, onFunction=createNewFunction)
end


function runOver(expr::Expr; onFunction=(x)->x, onCall=(x)->x)
    if(expr.head == :call) 
        onCall(expr.args[1])
    end
    if(expr.head == :function) 
        onFunction(expr.args[1].args[1])
    end
    #runOver(expr.head, onFunction=onFunction, onCall=onCall, onValue=onValue, onSymbol=onSymbol)
    for i in expr.args
        runOver(i, onFunction=onFunction, onCall=onCall)
    end
end

function runOver(expr::Any; onFunction=(x)->x, onCall=(x)->x)
    # do nothing for now
end
end
