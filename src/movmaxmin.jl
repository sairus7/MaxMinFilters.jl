const Evt{T} = NamedTuple{(:pos, :val),Tuple{Int,T}}
Evt(pos::Int, val::T) where T = (pos = pos, val = val)
1
"""
`xmax, xmin = movmaxmin(x, w)`

Moving maximum-minimum filter of window `w`
"""
movmaxmin(x::AbstractArray{T}, w) where T = movmaxmin!(similar(x), similar(x), x, w)
# the fastest - with circular buffers inlined, but less obvious
function _movmaxmin!(xmax::AbstractArray{T}, xmin::AbstractArray{T}, x::AbstractArray{T}, w::Int) where T
    U_buf 	   = Vector{Evt{T}}(undef, w)
    U_first    = Int(1)
    U_last     = Int(w)
    U_capacity = Int(0)

    L_buf 	   = Vector{Evt{T}}(undef, w)
    L_first    = Int(1)
    L_last     = Int(w)
    L_capacity = Int(0)

    Len = length(x)
    xi = x[1]
    @inbounds for i=2:Len
        xi_1 = xi
        xi = x[i]
        xmax[i-1] = ifelse(U_capacity > 0, U_buf[U_first].val, xi_1) ### x[get_front[U]]
        xmin[i-1] = ifelse(L_capacity > 0, L_buf[L_first].val, xi_1) ### x[get_front[L]]

        if xi > xi_1
            ### L = push_back[L, i-1];
            L_last = ifelse(L_last < w, L_last+1, 1)
            L_buf[L_last] = Evt(i-1, xi_1)
            L_capacity += 1
            ###
            if i == w + L_buf[L_first].pos
                ### L = pop_front[L];
                L_first = ifelse(L_first < w, L_first+1, 1)
                L_capacity -= 1
                ###
            end
            while U_capacity > 0
                if xi <= U_buf[U_last].val
                    if i == w + U_buf[U_first].pos
                        ### U = pop_front[U];
                        U_first = ifelse(U_first < w, U_first+1, 1)
                        U_capacity -= 1
                        ###
                    end
                    break
                end
                ### U = pop_back[U];
                U_last = ifelse(U_last > 1, U_last-1, w)
                U_capacity -= 1
                ###
            end
        else
            ### U = push_back[U, i-1];
            U_last = ifelse(U_last < w, U_last+1, 1)
            U_buf[U_last] = Evt(i-1, xi_1)
            U_capacity += 1
            ###
            if i == w + U_buf[U_first].pos
                ### U = pop_front[U];
                U_first = ifelse(U_first < w, U_first+1, 1)
                U_capacity -= 1
                ###
            end
            while L_capacity > 0
                if xi >= L_buf[L_last].val
                    if i == w + L_buf[L_first].pos
                        ### L = pop_front[L];
                        L_first = ifelse(L_first < w, L_first+1, 1)
                        L_capacity -= 1
                        ###
                    end
                    break
                end
                ### L = pop_back[L];
                L_last = ifelse(L_last > 1, L_last-1, w)
                L_capacity -= 1
                ###
            end
        end
    end
    xmax[Len] = ifelse(U_capacity > 0, U_buf[U_first].val, x[Len]) ### x[get_front[U]]
    xmin[Len] = ifelse(L_capacity > 0, L_buf[L_first].val, x[Len]) ### x[get_front[L]]

    xmin, xmax
end
# clearer code, but a bit slower
function movmaxmin!(xmax::AbstractArray{T}, xmin::AbstractArray{T}, x::AbstractArray{T}, w::Int) where T
    U_buf = RingBuffer{Evt{T}}(w)
    L_buf = RingBuffer{Evt{T}}(w)
    Len = length(x)
    xi = x[1]
    @inbounds for i=2:Len
        xi_1 = xi
        xi = x[i]
        xmax[i-1] = ifelse(length(U_buf) > 0, first(U_buf).val, xi_1) ### x[get_front[U]]
        xmin[i-1] = ifelse(length(L_buf) > 0, first(L_buf).val, xi_1) ### x[get_front[L]]

        if xi > xi_1
            push!(L_buf, Evt(i-1, xi_1))
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
            push!(U_buf, Evt(i-1, xi_1))
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
    end

    xmax[Len] = ifelse(length(U_buf) > 0, first(U_buf).val, x[Len])
    xmin[Len] = ifelse(length(L_buf) > 0, first(L_buf).val, x[Len])

    xmax, xmin
end

"""
`xrange = movrange(x, w)`

Moving max-min range filter of window `w`.
"""
movrange(x::AbstractArray{T}, w) where T = movrange!(similar(x), x, w)
function movrange!(xrange::AbstractArray{T}, x::AbstractArray{T}, w::Int) where T
    U_buf = RingBuffer{Evt{T}}(w)
    L_buf = RingBuffer{Evt{T}}(w)
    Len = length(x)
    xi = x[1]
    @inbounds for i=2:Len
        xi_1 = xi
        xi = x[i]
        mx = ifelse(length(U_buf) > 0, first(U_buf).val, xi_1) ### x[get_front[U]]
        mn = ifelse(length(L_buf) > 0, first(L_buf).val, xi_1) ### x[get_front[L]]
        xrange[i-1] = mx - mn

        if xi > xi_1
            push!(L_buf, Evt(i-1, xi_1))
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
            push!(U_buf, Evt(i-1, xi_1))
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
    end

    mx = ifelse(length(U_buf) > 0, first(U_buf).val, x[Len])
    mn = ifelse(length(L_buf) > 0, first(L_buf).val, x[Len])
    xrange[Len] = mx - mn

    xrange
end

"""
`xmax = movmax(x, w)`

Moving maximum filter of window `w`.
"""
movmax(x::AbstractArray{T}, w) where T = movmax!(similar(x), x, w)
function movmax!(xmax::AbstractArray{T}, x::AbstractArray{T}, w::Int) where T
    U_buf = RingBuffer{Evt{T}}(w)
    Len = length(x)
    xi = x[1]
    @inbounds for i=2:Len
        xi_1 = xi
        xi = x[i]
        xmax[i-1] = ifelse(length(U_buf) > 0, first(U_buf).val, xi_1) ### x[get_front[U]]
        ### ...
        if xi > xi_1
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
            push!(U_buf, Evt(i-1, xi_1))
            if i == w + first(U_buf).pos
                popfirst!(U_buf)
            end
            ### ...
        end
    end
    xmax[Len] = ifelse(length(U_buf) > 0, first(U_buf).val, x[Len])

    xmax
end

"""
`xmin = movmin(x, w)`

Moving minimum filter of window `w`.
"""
movmin(x::AbstractArray{T}, w) where T = movmin!(similar(x), x, w)
function movmin!(xmin::AbstractArray{T}, x::AbstractArray{T}, w::Int) where T
    L_buf = RingBuffer{Evt{T}}(w)
    Len = length(x)
    xi = x[1]
    @inbounds for i=2:Len
        xi_1 = xi
        xi = x[i]
        # ...
        xmin[i-1] = ifelse(length(L_buf) > 0, first(L_buf).val, xi_1) ### x[get_front[L]]

        if xi > xi_1
            push!(L_buf, Evt(i-1, xi_1))
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
    end
    xmin[Len] = ifelse(length(L_buf) > 0, first(L_buf).val, x[Len])

    xmin
end

"""
`xenvelope = movenvelope(x, w)`

Moving max-min envelope filter.
Envelope is defined as consecutive `movrange` of window `w1` (1-d dilation)
and `movmin` of window `w2` (1-d erosion). By default `w2 = w1`.
Filter delay = `(w1 + w2) ÷ 2`
"""
movenvelope(x::AbstractArray{T}, w1, w2 = w1 - 1) where T = movenvelope!(similar(x), x, w1, w2)
function movenvelope!(xenvelope::AbstractArray{T}, x::AbstractArray{T}, w1::Int, w2::Int = w1 - 1) where T
    movrange!(xenvelope, x, w1)
    if (w2 > 0)
        movmin!(xenvelope, xenvelope, w2)
    end
    xenvelope
end
