module DependencyExtraction

# EXPORT
export DEFunction, getName, numberOfOutgoingCallnames, getCallnames
export DEModel, numberOfFunctions, importCode, getFunction

export parseString, runOver

mutable struct DEFunction
    name::String
    beginLOC::Int
    endLOC::Int
    outgoingCallnames::Array{String, 1}
end
DEFunction() = DEFunction("UNKNOWN", -1, -1, [])
DEFunction(aName::String) = DEFunction(aName, -1, -1, [])
getName(f::DEFunction) = f.name
getCallnames(f::DEFunction) = f.outgoingCallnames
numberOfOutgoingCallnames(f::DEFunction) = length(f.outgoingCallnames)

mutable struct DEModel
    filename::String
    functions::Array{DEFunction, 1}
end
DEModel() = DEModel("", [])
numberOfFunctions(model::DEModel) = length(model.functions)
addFunction!(model::DEModel, aFunction::DEFunction) = push!(model.functions, aFunction)
function getFunction(model::DEModel, aFunctionName::String) 
    answer = filter(aFunction -> aFunction.name == aFunctionName, model.functions)
    if(length(answer) > 0)
        return answer[1]
    else
        return nothing
    end
end


function parseString(code::String)
    Meta.parse("begin $code end")
end

function importCode(m::DEModel, code::String)
    expr = parseString(code)
    lastFunction::DEFunction = DEFunction()
    function createNewFunction(functionName) 
        lastFunction = DEFunction(String(functionName))
        addFunction!(m, lastFunction)
    end
    function addCallToLastFunction(aCallName::Symbol)
        push!(lastFunction.outgoingCallnames, String(aCallName))
    end
    runOver(expr, onFunction=createNewFunction, onCall=addCallToLastFunction)
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


function runExample() 
    path = "/Applications/Julia-1.6.app/Contents/Resources/julia/share/julia/stdlib/v1.6/Test/src/Test.jl"
    model = DEModel()
    f = open(path)
    

end
end
