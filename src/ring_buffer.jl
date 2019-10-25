"""
Analog to CircularBuffer, but with better performance
Fixed-size - no preallocation
New items are pushed to the back of the list, overwriting values in a circular fashion.
"""
mutable struct RingBuffer{T} <: AbstractVector{T}
    buffer::Vector{T}
    len::Int
    first::Int
    last::Int
    contentLen::Int
    # counter::Int
    function RingBuffer{T}(maxlen::Int) where T
        new{T}(Vector{T}(undef, maxlen), maxlen, 1, 0, 0) #, 0)
    end
end

Base.@propagate_inbounds function _buffer_index_checked(buf::RingBuffer, i::Int)
    @boundscheck if i < firstindex(buf) || i > lastindex(buf)
        throw(BoundsError(buf, i))
    end
    _buffer_index(buf, i)
end

@inline function _buffer_index(buf::RingBuffer, i::Int)
    #idx = mod1(buf.first + i - 1, buf.len) # idx = (buf.first + i - 2) % buf.len + 1
    idx = buf.first + i - 1
    # idx > buf.len ? idx - buf.len : idx
    ifelse(idx > buf.len, idx - buf.len, idx)
end

@inline Base.@propagate_inbounds function Base.getindex(buf::RingBuffer, i::Int)
    buf.buffer[_buffer_index_checked(buf, i)]
end

@inline Base.@propagate_inbounds function Base.setindex!(buf::RingBuffer, data, i::Int)
    buf.buffer[_buffer_index_checked(buf, i)] = data
    buf
end

# pop_back
@inline function Base.pop!(buf::RingBuffer)
    i = buf.last
    if buf.contentLen > 0
        buf.contentLen -= 1
        buf.last = _buffer_index(buf, buf.contentLen)
    else
        throw(ArgumentError("array must be non-empty"))
    end
    buf.buffer[i]
end
@inline function Base.pop!(buf::RingBuffer, Npop::Int)
    if Npop > buf.contentLen
        Npop = buf.contentLen
    end
    if buf.contentLen > 0
        buf.contentLen -= Npop
        buf.last = _buffer_index(buf, buf.contentLen)
        # buf.counter -= Npop
    end
    buf
end


# pop_front
@inline function Base.popfirst!(buf::RingBuffer)
    i = buf.first
    if buf.contentLen > 0
        buf.contentLen -= 1
        buf.first = ifelse(buf.first == buf.len, 1, buf.first + 1)
    else
        throw(ArgumentError("array must be non-empty"))
    end
    buf.buffer[i]
end
@inline function Base.popfirst!(buf::RingBuffer, Npop::Int)
    if Npop > buf.contentLen
        Npop = buf.contentLen
    end
    if buf.contentLen > 0
        buf.first = _buffer_index(buf, 1 + Npop)
        buf.contentLen -= Npop
    end
    buf
end

# push_back
@inline function Base.push!(buf::RingBuffer, data)
    buf.last = _buffer_index(buf, buf.contentLen + 1)
    buf.buffer[buf.last] = data
    if buf.contentLen == buf.len
        buf.first = _buffer_index(buf, 2) # (buf.first == buf.len ? 1 : buf.first + 1)
    else
        buf.contentLen += 1
    end
    # buf.counter += 1
    buf
end
# push_front
function Base.pushfirst!(buf::RingBuffer, data)
    buf.first = _buffer_index(buf, 0) # (buf.first == 1 ? buf.len : buf.first - 1)
    buf.buffer[buf.first] = data
    if buf.contentLen == buf.len
        buf.last = _buffer_index(buf, 0)
    else
        buf.contentLen += 1
    end
    buf
end

# push_back vector
function Base.append!(buf::RingBuffer, datavec::AbstractVector)
    Nadd = length(datavec)
    for i = 1:Nadd
        buf[i + buf.last] = datavec[i]
    end
    if buf.contentLen == buf.len
        buf.first = _buffer_index(buf, 1 + Nadd)
    else
        if buf.len > buf.contentLen + Nadd
            buf.contentLen += Nadd;
        else
            buf.first = _buffer_index(buf, 1 + buf.contentLen + Nadd - buf.len);
            buf.contentLen = buf.len;
        end
    end
    buf.last = _buffer_index(buf, buf.contentLen)
    # buf.counter += Nadd
    buf
end

Base.first(buf::RingBuffer) = buf.buffer[buf.first]
Base.last(buf::RingBuffer) = buf.buffer[buf.last]

Base.length(buf::RingBuffer) = buf.contentLen
Base.size(buf::RingBuffer) = (buf.contentLen,)
#Base.convert{T}(::Type{Array}, buf::RingBuffer{T}) = T[x for x in buf]
Base.convert(::Type{Array}, buf::RingBuffer{T}) where T = T[x for x in buf]
Base.isempty(buf::RingBuffer) = isempty(buf.buffer)

capacity(buf::RingBuffer) = buf.len # full capacity
isfull(buf::RingBuffer) = buf.contentLen == buf.len
# bounds(buf::RingBuffer) = (buf.first, buf.last) # bounds indexes

function Base.empty!(buf::RingBuffer)
    buf.contentLen = buf.last = 0
    buf.first = 1
    buf
end
# clear and resize
function reset!(buf::RingBuffer, len::Int = buf.len) # clear and resize
    empty!(buf)
    if buf.len != len
        buf.len = len
        buf.buffer = Vector{T}(undef, len)
    end
end
