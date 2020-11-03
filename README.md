# PropertyUtils

This package provides composable utility functions/macros for working with types that have \
`getproperty` methods.

### `@with`

#### Replace items in an expression with properties from a `src`.

Usage:

```julia
@with src expr
```

- For any Symbol `x` that appears in `expr` and `hasproperty(src, x)`, replace `x` with `getproperty(src, x)`.

Example:

```julia
z = 3
result = @with (x = 1, y = 2) begin 
    x + y + z
end
result == 6
```

### `joinprops`

#### Join sources to create a union of their props.

Example:

```julia
a = (x = 1, y = 2)
b = (y = 3, z = 4)

j = joinprops(a, b)

j.x == 1
j.y == 2  # non-unique props are taken from the first argument that has it
j.z == 4
```



### `fields`

#### Change an object's `getproperty` back to `getfield`.

Usage:

```julia
struct A 
    x::Int 
end
Base.getproperty(::A, x::Symbol) = "hello!"

item = A(1)
f_item = fields(a)

item.x == "hello!"
f_item.x == 1
```

### Composability

`@with`, `fields`, and `joinprops` play nicely together: 

```julia
result = @with joinprops(fields(A(10)), a, b) begin 
    x + y
end

result == 12
```

### Special Thanks

This package borrows ideas from [StatsModels.jl](https://github.com/JuliaStats/StatsModels.jl), [DataFramesMeta.jl](https://github.com/JuliaData/DataFramesMeta.jl), [StaticModules.jl](https://github.com/MasonProtter/StaticModules.jl), and [StatsPlots.jl](https://github.com/JuliaPlots/StatsPlots.jl), which are all fantastic.