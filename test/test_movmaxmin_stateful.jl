@testset "Stateful max-min filters" begin

    len = 1000
    Random.seed!(0)
    T = Float64
    vec = rand(T, len)
    window = 15

    mx_ref = similar(vec)
    mn_ref = similar(vec)

    for i = 1:len
        mx_ref[i] = maximum(vec[max(1, i-window+1) : i])
        mn_ref[i] = minimum(vec[max(1, i-window+1) : i])
    end
    range_ref = mx_ref .- mn_ref


    @testset "MaxMinFilter" begin
        f = MaxMinFilter{T}(window)
        mx, mn = filt(f, vec)
        @test mx == mx_ref
        @test mn == mn_ref
        # reset state
        reset!(f)
        mx, mn = filt(f, vec[1:len÷2])
        @test mx == mx_ref[1:len÷2]
        @test mn == mn_ref[1:len÷2]
        # maintain state
        mx, mn = filt(f, vec[len÷2+1:end])
        @test mx == mx_ref[len÷2+1:end]
        @test mn == mn_ref[len÷2+1:end]
    end

    @testset "RangeFilter" begin
        f = RangeFilter{T}(window)
        range = filt(f, vec)
        @test range == range_ref
        # reset state
        reset!(f)
        range = filt(f, vec[1:len÷2])
        @test range == range_ref[1:len÷2]
        # maintain state
        range = filt(f, vec[len÷2+1:end])
        @test range == range_ref[len÷2+1:end]
    end

    @testset "MaxFilter" begin
        f = MaxFilter{T}(window)
        mx = filt(f, vec)
        @test mx == mx_ref
        # reset state
        reset!(f)
        mx = filt(f, vec[1:len÷2])
        @test mx == mx_ref[1:len÷2]
        # maintain state
        mx = filt(f, vec[len÷2+1:end])
        @test mx == mx_ref[len÷2+1:end]
    end

    @testset "MinFilter" begin
        f = MinFilter{T}(window)
        mn = filt(f, vec)
        @test mn == mn_ref
        # reset state
        reset!(f)
        mn = filt(f, vec[1:len÷2])
        @test mn == mn_ref[1:len÷2]
        # maintain state
        mn = filt(f, vec[len÷2+1:end])
        @test mn == mn_ref[len÷2+1:end]
    end

end
