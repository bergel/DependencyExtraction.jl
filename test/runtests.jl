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

@testset "Importing a function" begin
    model = DEModel()
    code = "function f()\n    bar()\n    zork()\nend"
    importCode(model, code)
    @test numberOfFunctions(model) == 1
end