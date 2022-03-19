<h1 align="center">PropertyUtils</h1>

This package lets you:

1. Refer to properties by name only (`@with`).
2. Join together properties of different structs (`joinprops`).
3. Change `getproperty` (and `setproperty`) to `getfield` or `getindex` (`fields`, `indexes`).


<br><br>

## `@with`

### Replace items in an expression with properties from a `src`.

```julia
@with src expr
```

- For any Symbol `x` that appears in `expr` and `hasproperty(src, x)`, replace `x` with `getproperty(src, x)`.

```julia
z = 3
result = @with (x = 1, y = 2) begin
    x + y + z
end
result == 6
```

<br><br>

## `joinprops`

### Join sources to create a union of their props.

Example:

```julia
a = (x = 1, y = 2)
b = (y = 3, z = 4)

j = joinprops(a, b)

j.x == 1
j.y == 2  # non-unique props are taken from the first argument that has it
j.z == 4
```

<br><br>

## `fields`

### Map `getproperty` to `getfield`.


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

<br><br>

## `indexes`

### Map `getproperty` to `getindex`.

```julia
d = Dict(:x => 1, :y => 2)

indexes(d).y == 2
```

<br><br>

## Composability

`@with`, `fields`, `indexes`, and `joinprops` play nicely together:

```julia
result = @with joinprops(fields(A(10)), a, b, indexes(Dict(:twenty => 20))) begin
           x + y + z + twenty
       end

result == 36
```

<br><br>

## How this all works with `setproperty!`

`setproperty!`, e.g. `thing.x = 1`, is supported if the underlying data structure supports mutation.

- `indexes(x)`: `setproperty!` --> `setindex!`
- `fields(x)`: `setproperty!` --> `setfield!`
- `joinprops(x)`: `setproperty!` --> `setproperty!` on the first instance of the prop.  You cannot
    create new props.

```julia
indexes(d).z = 3

d[:z] == 3
```

<br><br>

## Special Thanks

This package borrows ideas from [StatsModels.jl](https://github.com/JuliaStats/StatsModels.jl), [DataFramesMeta.jl](https://github.com/JuliaData/DataFramesMeta.jl), [StaticModules.jl](https://github.com/MasonProtter/StaticModules.jl), and [StatsPlots.jl](https://github.com/JuliaPlots/StatsPlots.jl), which are all fantastic.
