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
    runOver(Meta.parse(code))
end

@testset "Importing a function" begin
    model = DEModel()
    code = "function f()
    bar()
    zork()
end"
    importCode(model, code)
    @test numberOfFunctions(model) == 1
end