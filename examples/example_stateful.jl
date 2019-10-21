using Plots
using MaxMinFilters
using Random

Random.seed!(0)
len = 300
x = randn(len)
x[1] = 0;
for i = 1+1:len
    x[i] = -(0.5 + x[i-1]*0.8 + x[i]*0.2)
end

w = 5
fmm = MaxMinFilter{Float64}(w)
fr = RangeFilter{Float64}(w)
mx, mn = filt(fmm, x) # or run(fmm, x)
xrange = filt(fr, x) # or run(fr, x)

plot(x, label = "x")
plot!(mx, label = "mx")
plot!(mn, label = "mn")
plot!(xrange, label = "range")

#png("plot1.png")

fenv = EnvelopeFilter{Float64}(w)
envelope = filt(fenv, x)
plot(x, label = "x")
plot!(envelope[w:end], label = "envelope")

#png("plot2.png")
