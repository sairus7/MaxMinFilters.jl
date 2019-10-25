using MaxMinFilters
using Test
using Random

len = 1000000
Random.seed!(0)
T = Float64
vec = rand(T, len)
window1 = 5
window2 = 200

mx_ref = similar(vec)
mn_ref = similar(vec)

mx = similar(vec)
mn = similar(vec)
using BenchmarkTools
deck1 = @benchmark movmaxmin!($mx, $mn, $vec, $window1)
cbuf1 = @benchmark movmaxmin_!($mx, $mn, $vec, $window1)
inli1 = @benchmark _movmaxmin!($mx,$mn, $vec, $window1)
deck2 = @benchmark movmaxmin!($mx, $mn, $vec, $window1)
cbuf2 = @benchmark movmaxmin_!($mx,$mn, $vec, $window1)
inli2 = @benchmark _movmaxmin!($mx,$mn, $vec, $window1)


t21 = @benchmark    _movmaxmin!($mx,$mn, $vec, $window2)
t22 = @benchmark  ie_movmaxmin!($mx,$mn, $vec, $window2)
t22 = @benchmark ien_movmaxmin!($mx,$mn, $vec, $window2)
t21 = @benchmark    _movmaxmin!($mx,$mn, $vec, $window2)
t22 = @benchmark  ie_movmaxmin!($mx,$mn, $vec, $window2)
t22 = @benchmark ien_movmaxmin!($mx,$mn, $vec, $window2)

t21 = @benchmark    _movmaxmin!($mx,$mn, $vec, $window2)
t22 = @benchmark  ie_movmaxmin!($mx,$mn, $vec, $window2)
t22 = @benchmark ien_movmaxmin!($mx,$mn, $vec, $window2)
t21 = @benchmark    _movmaxmin!($mx,$mn, $vec, $window2)
t22 = @benchmark  ie_movmaxmin!($mx,$mn, $vec, $window2)
t22 = @benchmark ien_movmaxmin!($mx,$mn, $vec, $window2)

e = 1
