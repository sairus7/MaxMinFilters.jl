using MaxMinFilters
using Test
using Random
# using Serialization

@test [] == detect_ambiguities(Base, Core)

tests = [
         "movmaxmin",
         "movmaxmin_stateful",
        ]

if length(ARGS) > 0
    tests = ARGS
end

@testset "MaxMinFilters" begin

for t in tests
    fp = joinpath(dirname(@__FILE__), "test_$t.jl")
    println("$fp ...")
    include(fp)
end

end # @testset
