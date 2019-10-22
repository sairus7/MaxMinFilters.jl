# MaxMinFilters.jl

Julia implementation of Daniel Lemire's Streaming Maximum-Minimum Filter:

_Daniel Lemire, Streaming Maximum-Minimum Filter Using No More than Three Comparisons per Element. Nordic Journal of Computing, 13 (4), pages 328-339, 2006._
http://arxiv.org/abs/cs.DS/0610046

Implemented both as functions over a moving window, and stateful filter objects. 
Available filters: minimum, maximum, minimum+maximum, range, envelope 

## Installation
```julia
]add https://github.com/sairus7/MaxMinFilters.jl.git
```

## Comparison with other packages
There are three other Julia packages with overlapping functionality for moving window maximum/minimum functions:
- [RollingFunctions.jl](https://github.com/JeffreySarnoff/RollingFunctions.jl)
- [Indicators.jl](https://github.com/dysonance/Indicators.jl)
- [ImageFiltering.jl](https://github.com/JuliaImages/ImageFiltering.jl)

Compared to these packages, [MaxMinFilters.jl](https://github.com/sairus7/MaxMinFilters.jl) provides significant speed-up, and its complexity does not depend on window length (benchmark available at [examples/benchmark.jl](https://github.com/sairus7/MaxMinFilters.jl/blob/master/examples/benchmark.jl)):

![plot](https://user-images.githubusercontent.com/20798349/67251317-60925880-f477-11e9-895c-dbb6eda2bd06.png)

Also [MaxMinFilters.jl](https://github.com/sairus7/MaxMinFilters.jl) provides stateful filter objects, allowing you to process a signal of indefinite length in RAM-friendly chunks, similar to [DSP.jl](https://juliadsp.github.io/DSP.jl/stable/filters/#stateful-filter-objects-1).

## Examples
[examples/example.jl](https://github.com/sairus7/MaxMinFilters.jl/blob/master/examples/example.jl):
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
