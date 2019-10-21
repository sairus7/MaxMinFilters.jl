"""
Julia implementation of Daniel Lemire's Streaming Maximum-Minimum Filter:
'''Streaming Maximum-Minimum Filter Using No More than Three Comparisons per Element'''
http://arxiv.org/abs/cs.DS/0610046
"""
module MaxMinFilters

export movmaxmin, movmaxmin!,
    movmax, movmax!,
    movmin, movmin!,
    movrange, movrange!,
    movenvelope, movenvelope!,
    
    MaxMinFilter, RangeFilter, MaxFilter, MinFilter, EnvelopeFilter,
    run, run!, filt, filt!, reset!, delay

include("ring_buffer.jl")
include("movmaxmin.jl")
include("movmaxmin_stateful.jl")


end # module


# how should delays be fixed, add a kw to mov functinos?

# naming of streaming algorithms: should all moving functions start with `mov`?
# naming of stateful functions - should they be named as filters in DSP terminology?

# relation to other packages, such as DSP, rolling functions, indicators -
# how should we make a concise libraries?

# what notation is better for stateful filters: run! / filter! / movmaxmin! ?

# should I split filter into different objects (MinMaxFilter, MinFilter, MaxFilter, RangeFilter),
# or use just one object with several filtering methods/modes?
