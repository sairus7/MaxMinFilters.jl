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
mx, mn = movmaxmin(x, w)
xrange = movrange(x, w)

plot(x, label = "x")
plot!(mx, label = "mx")
plot!(mn, label = "mn")
plot!(xrange, label = "range")

#png("plot1.png")

envelope = movenvelope(x, w)
plot(x, label = "x")
plot!(envelope[w-1:end], label = "envelope") # with delay fixed

#png("plot2.png")
