using DependencyExtraction
using Test

@testset "Basic model" begin
    model = DEModel()
    @test numberOfFunctions(model) == 0
end

@testset "Basic function" begin
    myFunction = DEFunction()
    @test getName(myFunction) == "UNKNOWN"
end

@testset "Running a visitor" begin
    code = "function f()\n    bar()\n    zork()\nend"
    expr = parseString(code)
    definedFunctionNames = []
    calls = []
    @test length(definedFunctionNames) == 0
    @test length(calls) == 0
    runOver(expr, onFunction=(x)->(push!(definedFunctionNames, x)), onCall=(x)->(push!(calls, x)))
    @test length(definedFunctionNames) == 1
    @test length(calls) == 3
    @test calls == [:f, :bar, :zork]
end

@testset "Importing a function and fetching function" begin
    model = DEModel()
    code = "function f()\n    bar()\n    zork()\nend"
    importCode(model, code)
    @test numberOfFunctions(model) == 1

    myFunc = getFunction(model, "f")
    @test myFunc !== nothing
    @test typeof(myFunc) == DEFunction
    @test numberOfOutgoingCallnames(myFunc) == 3
    @test getCallnames(myFunc) == ["f", "bar", "zork"]

    @test getFunction(model, "zorkbar") === nothing
end

@testset "Extracting function name" begin
    code = "function FooBarf()\n    bar()\n    zork()\nend"
    expr = parseString(code)
    functionNameExpr = expr.args[2].args[1].args[1]
    @test getFunctionNameFromAST(functionNameExpr) == "FooBarf"

    code = "function FooBar.f()\n    bar()\n    zork()\nend"
    expr = parseString(code)
    functionNameExpr = expr.args[2].args[1].args[1]
    @test getFunctionNameFromAST(functionNameExpr) == "FooBar.f"
end

@testset "Importing a function with a weird name" begin
    model = DEModel()
    code = "function FooBar.f()\n    bar()\n    zork()\nend"
    importCode(model, code)
    @test numberOfFunctions(model) == 1

    myFunc = getFunction(model, "f")
    @test myFunc === nothing

    myFunc = getFunction(model, "FooBar.f")
    @test myFunc !== nothing

    @test typeof(myFunc) == DEFunction
    @test numberOfOutgoingCallnames(myFunc) == 2
    @test getCallnames(myFunc) == ["bar", "zork"]

    @test getFunction(model, "zorkbar") === nothing
end

@testset "Importing a function with a weird name (2)" begin
    model = DEModel()
    code = "function record end"
    importCode(model, code)
    @test numberOfFunctions(model) == 1

    myFunc = getFunction(model, "record")
    @test myFunc !== nothing

    @test typeof(myFunc) == DEFunction
    @test numberOfOutgoingCallnames(myFunc) == 0
    @test getCallnames(myFunc) == [ ]
end
