module DependencyExtraction

# EXPORT
export DEFunction, getName, numberOfOutgoingCallnames, getCallnames
export DEModel, numberOfFunctions, importCode, getFunction, dumpAsCSV
export parseString, runOver

# EXPORT FOR TESTING
export getFunctionNameFromAST

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
function addFunction!(model::DEModel, aFunction::DEFunction)
    push!(model.functions, aFunction)
end
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
    if(expr.head == Symbol)
        return
    end

    # call within a function body
    if(expr.head == :call) 
        onCall(expr.args[1])
    end

    # Assuming we have something like:
    # 2: Expr
    # head: Symbol function
    # args: Array{Any}((1,))
    #   1: Symbol record
    if(expr.head == :function) && (typeof(expr.args[1]) == Symbol)
        #print("DEBUG: ")
        #println(getFunctionNameFromAST(expr.args[1].args[1]))
        #println(expr)
        onFunction(getFunctionNameFromAST(expr.args[1]))
    end

    # Assuming we have something like:
    # 2: Expr
    # head: Symbol function
    # args: Array{Any}((2,))
    #   1: Expr
    #     head: Symbol call
    #     args: Array{Any}((1,))
    #       1: Symbol FooBarf
    if(expr.head == :function) && (typeof(expr.args[1]) == Expr) && (expr.args[1].head == :call)
        #print("DEBUG: ")
        #println(getFunctionNameFromAST(expr.args[1].args[1]))
        #println(expr)
        onFunction(getFunctionNameFromAST(expr.args[1].args[1]))
    end
    #runOver(expr.head, onFunction=onFunction, onCall=onCall, onValue=onValue, onSymbol=onSymbol)
    for i in expr.args
        runOver(i, onFunction=onFunction, onCall=onCall)
    end
end

function getFunctionNameFromAST(aSymbol::Symbol)
    return String(aSymbol)
end

"Could be something like 
Expr
          head: Symbol .
          args: Array{Any}((2,))
            1: Symbol FooBar
            2: QuoteNode
              value: Symbol f
"
function getFunctionNameFromAST(anExpression::Expr)
    return String(anExpression.args[1]) * String(anExpression.head) * String(anExpression.args[2].value)
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
