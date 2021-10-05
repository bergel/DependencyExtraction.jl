module DependencyExtraction

# EXPORT
export DEFunction, getName, numberOfOutgoingCallnames, getCallnames
export DEModel, numberOfFunctions, importCode, getFunction, dumpAsCSV
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
    function addCallToLastFunction(aCallName::Any)
    end    
    runOver(expr, onFunction=createNewFunction, onCall=addCallToLastFunction)
end


function runOver(expr::Expr; onFunction=(x)->x, onCall=(x)->x)
    if(expr.head == :call) 
        onCall(expr.args[1])
    end
    if(expr.head == :function) 
        # print("DEBUG: ")
        # println(expr.args)
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


function dumpAsCSV(model::DEModel, fullPathname::String)
    open(fullPathname, "w") do f
        write(f, "FromFunction,ToFunction\n")
        for aFunction::DEFunction in model.functions
            for aToFunctionName in aFunction.outgoingCallnames
                write(f, getName(aFunction))
                write(f, ",")
                write(f, aToFunctionName)
                write(f, "\n")
            end
        end
    end
end
end
