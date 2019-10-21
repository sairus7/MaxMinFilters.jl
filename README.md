# MaxMinFilters.jl

Julia implementation of Daniel Lemire's Streaming Maximum-Minimum Filter:

_"Streaming Maximum-Minimum Filter Using No More than Three Comparisons per Element"_
http://arxiv.org/abs/cs.DS/0610046

Implemented both as functions over a moving window, and stateful filter objects. Available filters:
minimum, maximum, minimum+maximum, range, envelope 

# Installation
```julia
]add https://github.com/sairus7/MaxMinFilters.jl.git
```

# Comparison with other packages
There are two other packages with similar functionality for moving window maximum/minimum functions:
- [RollingFunctions.jl](https://github.com/JeffreySarnoff/RollingFunctions.jl)
- [Indicators.jl](https://github.com/dysonance/Indicators.jl)

Compared to these packages, [MaxMinFilters](https://github.com/sairus7/MaxMinFilters.jl) provides significant speed-up:

![plot](https://user-images.githubusercontent.com/20798349/67226660-26f12b80-f43e-11e9-8a3a-480e22a86462.png)

Also [MaxMinFilters](https://github.com/sairus7/MaxMinFilters.jl) provides stateful filter objects, allowing you to process a signal of indefinite length in RAM-friendly chunks, similar to [DSP.jl](https://juliadsp.github.io/DSP.jl/stable/filters/#stateful-filter-objects-1).

# Examples
```julia
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
```
![plot1](https://user-images.githubusercontent.com/20798349/67228143-61a89300-f441-11e9-8e0d-bd76209ec7a4.png)
```julia
envelope = movenvelope(x, w)
plot(x, label = "x")
plot!(envelope[w:end], label = "envelope")

#png("plot2.png")
```
![plot2](https://user-images.githubusercontent.com/20798349/67228184-71c07280-f441-11e9-996e-9f3cde248bd8.png)
