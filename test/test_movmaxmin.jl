@testset "Moving max-min functions" begin

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


    @testset "movmaxmin" begin
        mx, mn = movmaxmin(vec, window)
        @test mx == mx_ref
        @test mn == mn_ref
        fill!(mx, 0)
        fill!(mn, 0)
        movmaxmin!(mx, mn, vec, window)
        @test mx == mx_ref
        @test mn == mn_ref
    end

    @testset "movrange" begin
        range = movrange(vec, window)
        @test range == range_ref
        fill!(range, 0)
        movrange!(range, vec, window)
        @test range == range_ref
        fill!(range, 0)
    end

    @testset "movmax" begin
        mx = movmax(vec, window)
        @test mx == mx_ref
        fill!(mx, 0)
        movmax!(mx, vec, window)
        @test mx == mx_ref
    end

    @testset "movmin" begin
        mn = movmin(vec, window)
        @test mn == mn_ref
        fill!(mn, 0)
        movmin!(mn, vec, window)
        @test mn == mn_ref
    end

end
# @test_throws BoundsError first(buf)
