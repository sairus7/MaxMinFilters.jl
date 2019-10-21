# MaxMinFilters.jl

Julia implementation of Daniel Lemire's Streaming Maximum-Minimum Filter:

"Streaming Maximum-Minimum Filter Using No More than Three Comparisons per Element"
http://arxiv.org/abs/cs.DS/0610046

Available filters:
minimum, maximum, minimum+maximum, range, envelope

Implemented both as functions over a moving window, and stateful filter objects.
