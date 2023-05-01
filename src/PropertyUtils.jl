module PropertyUtils

export joinprops, fields, indexes, @with

#-----------------------------------------------------------------------------# joinprops
struct JoinProps{T}
    items::T
end

"""
    joinprops(items...)

Join items into a single struct with shared properties.  The first item that has the requested
property will be used.

# Example

    a = (x = 1, y = 2)
    b = (x = 3, z = 4)
    j = joinprops(a,b)
    j.x == 1
    j.z == 4
"""
joinprops(args...) = JoinProps(args)
Base.propertynames(j::JoinProps) = reduce(union, propertynames.(fields(j).items))
function Base.getproperty(j::JoinProps, x::Symbol)
    for item in getfield(j, :items)
        hasproperty(item, x) && return getproperty(item, x)
    end
    error("$j has no property $x")
end
function Base.setproperty!(j::JoinProps, name::Symbol, x)
    for item in getfield(j, :items)
        hasproperty(item, name) && return setproperty!(item, name, x)
    end
    error("`setproperty!(::JoinProps, args...) cannot create new properties.")
end

#-----------------------------------------------------------------------------# Indexes
struct Indexes{T}
    item::T
end

"""
    indexes(x)

Map `getproperty` to `getindex`.

# Example

    d = Dict(:x => 1, :y => 2)
    id = indexes(d)
    id.x
    id.z = 3
"""
indexes(x) = Indexes(x)
Base.propertynames(i::Indexes) = collect(keys(fields(i).item))
Base.getproperty(i::Indexes, x::Symbol) = getindex(getfield(i, :item), x)
Base.setproperty!(i::Indexes, name::Symbol, x) = setindex!(getfield(i, :item), x, name)


#-----------------------------------------------------------------------------# Fields
struct Fields{T}
    item::T
end

"""
    fields(x)

Map `getproperty` to `getfield`.

# Example
    struct A
        x::Int
    end
    Base.getproperty(a::A, x::Symbol) = "hello"

    a = A(1)
    a.x == "hello"

    fields(a).x == 1
"""
fields(x) = Fields(x)
Base.propertynames(f::Fields{T}) where {T} = fieldnames(T)
Base.getproperty(f::Fields, x::Symbol) = getfield(getfield(f, :item), x)
Base.setproperty!(f::Fields, name::Symbol, x) = setfield!(getfield(f, :item), name, x)

#-----------------------------------------------------------------------------# @with
"""
    @with src expr

- For every symbol `x` in `expr`, replace it with `hasproperty(src, x) ? src.x : x`.
- use `identity` to leave an identifier untouched.

# Example

    x = 3
    nt = (x = 1, y = 2)
    @with nt x + y + identity(x)  # 6
"""
macro with(src, ex)
    temp = gensym()
    quote
        $(esc(temp)) = $(esc(src))
        $(esc(PropertyUtils._replace(temp, ex)))
    end
end

function _replace(src, ex::Expr)
    if (ex.head === :kw) || ex.head === :(=)
        ex.args[2] = _replace(src, ex.args[2])
    elseif ex.head === :call && !(ex.args[1] === :identity)
        ex.args[2:end] .= _replace.(Ref(src), ex.args[2:end])
    else
        ex.args .= _replace.(Ref(src), ex.args)
    end
    ex
end

function _replace(src, ex::Symbol)
    if Base.isidentifier(ex)
        return :(hasproperty($src, $(QuoteNode(ex))) ? $src.$ex : $ex)
    else
        return ex
    end
end

_replace(src, ex) = ex

end #module
