#const Evt{T} = NamedTuple{(:pos, :val),Tuple{Int,T}}
#Evt(pos::Int, val::T) where T = (pos = pos, val = val)

"""
`flt = MaxMinFilter{T}(w)`

Moving maximum-minimum filter of window `w` that maintains state between calls.
"""
mutable struct MaxMinFilter{T}
    window::Int
    x0::T
    need_restart::Bool
    U_buf::RingBuffer{Evt{T}}
    L_buf::RingBuffer{Evt{T}}
    MaxMinFilter{T}(window::Int) where T =
        new{T}(window, 0, true, RingBuffer{Evt{T}}(window), RingBuffer{Evt{T}}(window))
end

function reset!(state::MaxMinFilter)
    reset!(state.L_buf, state.window)
    reset!(state.U_buf, state.window)
    state.need_restart = true
    state
end

function _restart!(state::MaxMinFilter, x0)
    state.x0 = x0
    state.need_restart = false
    state
end

function run(state::MaxMinFilter{T}, x::AbstractArray{T}) where T
    xmax = similar(x)
    xmin = similar(x)
    run!(xmax, xmin, state, x)
    xmax, xmin
end
function run!(xmax::AbstractArray{T}, xmin::AbstractArray{T}, # output
              state::MaxMinFilter{T},
              x::AbstractArray{T}) where T # input

    if state.need_restart && !isempty(x)
        _restart!(state, first(x))
    end
    w = state.window
    x0 = state.x0
    U_buf = state.U_buf
    L_buf = state.L_buf

    @inbounds for i = eachindex(x)
        xi = x[i]
        if xi > x0
            push!(L_buf, Evt(i-1, x0))
            if i == w + first(L_buf).pos
                popfirst!(L_buf)
            end
            while length(U_buf) > 0
                if xi <= last(U_buf).val
                    if i == w + first(U_buf).pos
                        popfirst!(U_buf)
                    end
                    break
                end
                pop!(U_buf)
            end
        else
            push!(U_buf, Evt(i-1, x0))
            if i == w + first(U_buf).pos
                popfirst!(U_buf)
            end
            while length(L_buf) > 0
                if xi >= last(L_buf).val
                    if i == w + first(L_buf).pos
                        popfirst!(L_buf)
                    end
                    break
                end
                pop!(L_buf)
            end
        end
        xmax[i] = ifelse(length(U_buf) > 0, first(U_buf).val, xi) ### x[get_front[U]]
        xmin[i] = ifelse(length(L_buf) > 0, first(L_buf).val, xi) ### x[get_front[L]]
        x0 = xi
    end

    # iterate positions
    len = length(x)
    for i in eachindex(L_buf)
        L_buf[i] = Evt(L_buf[i].pos - len, L_buf[i].val)
    end
    for i in eachindex(U_buf)
        U_buf[i] = Evt(U_buf[i].pos - len, U_buf[i].val)
    end

    state.x0 = x0

    xmax, xmin
end
filt(state::MaxMinFilter, x) = run(state, x)
filt!(xmax, xmin, state::MaxMinFilter, x) = run!(xmax, xmin, state, x)

delay(state::MaxMinFilter) = state.window ÷ 2

"""
`flt = RangeFilter{T}(w)`

Moving max-min range filter of window `w` that maintains state between calls.
"""
mutable struct RangeFilter{T}
    window::Int
    x0::T
    need_restart::Bool
    U_buf::RingBuffer{Evt{T}}
    L_buf::RingBuffer{Evt{T}}
    RangeFilter{T}(window::Int) where T =
        new{T}(window, 0, true, RingBuffer{Evt{T}}(window), RingBuffer{Evt{T}}(window))
end

function reset!(state::RangeFilter)
    reset!(state.L_buf, state.window)
    reset!(state.U_buf, state.window)
    state.need_restart = true
    state
end

function _restart!(state::RangeFilter, x0)
    state.x0 = x0
    state.need_restart = false
    state
end

function run(state::RangeFilter{T}, x::AbstractArray{T}) where T
    xrange = similar(x)
    run!(xrange, state, x)
    xrange
end
function run!(xrange::AbstractArray{T}, # output
              state::RangeFilter{T},
              x::AbstractArray{T}) where T # input

    if state.need_restart && !isempty(x)
        _restart!(state, first(x))
    end
    w = state.window
    x0 = state.x0
    U_buf = state.U_buf
    L_buf = state.L_buf

    @inbounds for i = eachindex(x)
        xi = x[i]
        if xi > x0
            push!(L_buf, Evt(i-1, x0))
            if i == w + first(L_buf).pos
                popfirst!(L_buf)
            end
            while length(U_buf) > 0
                if xi <= last(U_buf).val
                    if i == w + first(U_buf).pos
                        popfirst!(U_buf)
                    end
                    break
                end
                pop!(U_buf)
            end
        else
            push!(U_buf, Evt(i-1, x0))
            if i == w + first(U_buf).pos
                popfirst!(U_buf)
            end
            while length(L_buf) > 0
                if xi >= last(L_buf).val
                    if i == w + first(L_buf).pos
                        popfirst!(L_buf)
                    end
                    break
                end
                pop!(L_buf)
            end
        end
        xmax = ifelse(length(U_buf) > 0, first(U_buf).val, xi) ### x[get_front[U]]
        xmin = ifelse(length(L_buf) > 0, first(L_buf).val, xi) ### x[get_front[L]]
        xrange[i] = xmax - xmin
        x0 = xi
    end

    # iterate positions
    len = length(x)
    for i in eachindex(L_buf)
        L_buf[i] = Evt(L_buf[i].pos - len, L_buf[i].val)
    end
    for i in eachindex(U_buf)
        U_buf[i] = Evt(U_buf[i].pos - len, U_buf[i].val)
    end
    state.x0 = x0

    xrange
end
filt(state::RangeFilter, x) = run(state, x)
filt!(xrange, state::RangeFilter, x) = run!(xrange, state, x)

delay(state::RangeFilter) = state.window ÷ 2

"""
`flt = MaxFilter{T}(w)`

Moving maximum filter of window `w` that maintains state between calls.
"""
mutable struct MaxFilter{T}
    window::Int
    x0::T
    need_restart::Bool
    U_buf::RingBuffer{Evt{T}}
    MaxFilter{T}(window::Int) where T =
        new{T}(window, 0, true, RingBuffer{Evt{T}}(window))
end

function reset!(state::MaxFilter)
    reset!(state.U_buf, state.window)
    state.need_restart = true
    state
end

function _restart!(state::MaxFilter, x0)
    state.x0 = x0
    state.need_restart = false
    state
end

function run(state::MaxFilter{T}, x::AbstractArray{T}) where T
    xmax = similar(x)
    run!(xmax, state, x)
    xmax
end
function run!(xmax::AbstractArray{T}, # output
              state::MaxFilter{T},
              x::AbstractArray{T}) where T # input

    if state.need_restart && !isempty(x)
        _restart!(state, first(x))
    end
    w = state.window
    x0 = state.x0
    U_buf = state.U_buf

    @inbounds for i = eachindex(x)
        xi = x[i]
        if xi > x0
            ### ...
            while length(U_buf) > 0
                if xi <= last(U_buf).val
                    if i == w + first(U_buf).pos
                        popfirst!(U_buf)
                    end
                    break
                end
                pop!(U_buf)
            end
        else
            push!(U_buf, Evt(i-1, x0))
            if i == w + first(U_buf).pos
                popfirst!(U_buf)
            end
            ### ...
        end
        xmax[i] = ifelse(length(U_buf) > 0, first(U_buf).val, xi) ### x[get_front[U]]
        x0 = xi
    end

    # iterate positions
    len = length(x)
    for i in eachindex(U_buf)
        U_buf[i] = Evt(U_buf[i].pos - len, U_buf[i].val)
    end
    state.x0 = x0

    xmax
end
filt(state::MaxFilter, x) = run(state, x)
filt!(xmax, state::MaxFilter, x) = run!(xmax, state, x)

delay(state::MaxFilter) = state.window ÷ 2

"""
`flt = MinFilter{T}(w)`

Moving minimum filter of window `w` that maintains state between calls.
"""
mutable struct MinFilter{T}
    window::Int
    x0::T
    need_restart::Bool
    L_buf::RingBuffer{Evt{T}}
    MinFilter{T}(window::Int) where T =
        new{T}(window, 0, true, RingBuffer{Evt{T}}(window))
end

function reset!(state::MinFilter)
    reset!(state.L_buf, state.window)
    state.need_restart = true
    state
end

function _restart!(state::MinFilter, x0)
    state.x0 = x0
    state.need_restart = false
    state
end

function run(state::MinFilter{T}, x::AbstractArray{T}) where T
    xmin = similar(x)
    run!(xmin, state, x)
    xmin
end
function run!(xmin::AbstractArray{T}, # output
              state::MinFilter{T},
              x::AbstractArray{T}) where T # input

    if state.need_restart && !isempty(x)
        _restart!(state, first(x))
    end
    w = state.window
    x0 = state.x0
    L_buf = state.L_buf

    @inbounds for i = eachindex(x)
        xi = x[i]
        if xi > x0
            push!(L_buf, Evt(i-1, x0))
            if i == w + first(L_buf).pos
                popfirst!(L_buf)
            end
            # ...
        else
            # ...
            while length(L_buf) > 0
                if xi >= last(L_buf).val
                    if i == w + first(L_buf).pos
                        popfirst!(L_buf)
                    end
                    break
                end
                pop!(L_buf)
            end
        end
        xmin[i] = ifelse(length(L_buf) > 0, first(L_buf).val, xi) ### x[get_front[U]]
        x0 = xi
    end

    # iterate positions
    len = length(x)
    for i in eachindex(L_buf)
        L_buf[i] = Evt(L_buf[i].pos - len, L_buf[i].val)
    end
    state.x0 = x0

    xmin
end
filt(state::MinFilter, x) = run(state, x)
filt!(xmin, state::MinFilter, x) = run!(xmin, state, x)

delay(state::MinFilter) = state.window ÷ 2

"""
`flt = EnvelopeFilter{T}(w1, w2)`

Moving max-min envelope filter that maintains state between calls.
Envelope is defined as consecutive min-max RangeFilter of window `w1` (1-d dilation)
and MinFilter of window `w2` (1-d erosion). By default `w2 = w1`.
Filter delay = `(w1 + w2) ÷ 2`
"""
mutable struct EnvelopeFilter{T}
    rangefilter::RangeFilter{T}
    minfilter::MinFilter{T}
    EnvelopeFilter{T}(w1::Int, w2::Int = w1-1) where T =
        new{T}(RangeFilter{T}(w1), MinFilter{T}(w2))
end

function reset!(state::EnvelopeFilter)
    reset!(state.rangefilter)
    reset!(state.minfilter)
    state
end

function run(state::EnvelopeFilter{T}, x::AbstractArray{T}) where T
    xenvelope = similar(x)
    run!(xenvelope, state, x)
    xenvelope
end
function run!(xenvelope::AbstractArray{T},
              state::EnvelopeFilter{T},
              x::AbstractArray{T}) where T
    run!(xenvelope, state.rangefilter, x)
    if (state.minfilter.window > 0)
        run!(xenvelope, state.minfilter, xenvelope)
    end
end
filt(state::EnvelopeFilter, x) = run(state, x)
filt!(xenvelope, state::EnvelopeFilter, x) = run!(xenvelope, state, x)

delay(state::EnvelopeFilter) = (state.rangefilter.window + state.minfilter.window) ÷ 2
