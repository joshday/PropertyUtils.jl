module PropertyUtils

export JoinProps, Fields, @with

#-----------------------------------------------------------------------------# joinprops
"""
    JoinProps(items...)

Join items into a single struct with shared properties.  If multiple items have the same property,

# Example 

    a = (x = 1, y = 2)
    b = (x = 3, z = 4)
    j = JoinProps(a,b)
    j.x == 1
    j.z == 4
"""
struct JoinProps{T}
    items::T 
end

JoinProps(args...) = JoinProps(args)

Base.hasproperty(j::JoinProps, x::Symbol) = any(item -> hasproperty(item,x), getfield(j, :items))

function Base.getproperty(j::JoinProps, x::Symbol)
    for item in getfield(j, :items)
        hasproperty(item, x) && return getproperty(item, x)
    end
    error("$j has no property $x")
end


#-----------------------------------------------------------------------------# Fields
"""
    Fields(x)

Change the dot syntax for `x` from `getproperty` to `getfield`.

# Example 
    struct A 
        x::Int 
    end
    Base.getproperty(a::A, x::Symbol) = "hello"

    a = A(1)
    a.x == "hello"

    Fields(a).x == 1
"""
struct Fields{T}
    item::T 
end
Base.hasproperty(f::Fields, x::Symbol) = hasfield(f, x)
Base.getproperty(f::Fields, x::Symbol) = getfield(f, x)


#-----------------------------------------------------------------------------# @with
"""
    @with src expr

For every symbol `x` in `expr`, replace it with `getproperty(src, x)` if `hasproperty(src, x)`.

# Example 

    @with (x = 1, y = 2) x + y
"""
macro with(src, ex)
    esc(quote
        eval(PropertyUtils.replace_props!($src, $(Meta.quot(ex))))
    end)
end

replace_props!(df, x) = x

replace_props!(src, x::Symbol) = hasproperty(src, x) ? getproperty(src, x) : x

function replace_props!(src, ex::Expr) 
    if ex.head === :call || ex.head === :.
        Expr(ex.head, vcat(ex.args[1], replace_props!.(Ref(src), ex.args[2:end]))...)
    else
        Expr(ex.head, replace_props!.(Ref(src), ex.args)...)
    end
end
end
