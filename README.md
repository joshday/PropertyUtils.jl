<h1 align="center">PropertyUtils</h1>

This package lets you:

1. Change `getproperty` to `getfield` via `Fields(x)`
2. Change `getproperty` to `getindex` via `Indexes(x)` (most useful for `AbstractDict{Symbol, Any}`).
3. Similarly, `Fields`, and `Indexes` change the behavior of `setproperty!`.
4. Replace items in an expression with properties from a `src` via `@with src expr`.
5. Join together properties of different objects via `JoinProps`.


<br><br>

## `@with`

### Replace items in an expression with properties from a `src`.

```julia
@with src expr
```

- Every valid identifier `x` in `expr` gets changed to `hasproperty(src, :x) ? src.x : x`

```julia
z = 3
result = @with (x = 1, y = 2) begin
    x + y + z
end
result == 6
```

<br><br>

## `JoinProps`

### Join sources to create a union of their props.

Example:

```julia
a = (x = 1, y = 2)
b = (y = 3, z = 4)

j = JoinProps(a, b)

j.x == 1
j.y == 2  # non-unique props are taken from the first argument that has it
j.z == 4
```

<br><br>

## `Fields`

### Map `getproperty` to `getfield`.


```julia
struct A
    x::Int
end
Base.getproperty(::A, x::Symbol) = "hello!"

item = A(1)
f_item = Fields(a)

item.x == "hello!"
f_item.x == 1
```

<br><br>

## `Indexes`

### Map `getproperty` to `getindex`.

```julia
d = Dict(:x => 1, :y => 2)

Indexes(d).y == 2
```

<br><br>

## Composability

`@with`, `Fields`, `Indexes`, and `JoinProps` play nicely together:

```julia
result = @with JoinProps(Fields(A(10)), a, b, Indexes(Dict(:twenty => 20))) begin
           x + y + z + twenty
       end

result == 36
```

<br><br>

## How this all works with `setproperty!`

`setproperty!`, e.g. `thing.x = 1`, is supported if the underlying data structure supports mutation.

- `Indexes(x)`: `setproperty!` --> `setindex!`
- `Fields(x)`: `setproperty!` --> `setfield!`
- `JoinProps(x)`: `setproperty!` --> `setproperty!` on the first instance of the prop.  You cannot
    create new props.

```julia
Indexes(d).z = 3

d[:z] == 3
```

<br><br>

## Special Thanks

This package borrows ideas from [StatsModels.jl](https://github.com/JuliaStats/StatsModels.jl), [DataFramesMeta.jl](https://github.com/JuliaData/DataFramesMeta.jl), [StaticModules.jl](https://github.com/MasonProtter/StaticModules.jl), and [StatsPlots.jl](https://github.com/JuliaPlots/StatsPlots.jl), which are all fantastic.
