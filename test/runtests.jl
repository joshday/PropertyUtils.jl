using PropertyUtils
using Test

#-----------------------------------------------------------------------------# setup
mutable struct A 
    a 
end
Base.getproperty(a::A, x::Symbol) = "hello"

struct B 
    b 
end

#-----------------------------------------------------------------------------# tests
@testset "PropertyUtils" begin

@testset "@with" begin
    result = @with (x=1, y=2) x + y
    @test result == 3
end

@testset "fields" begin 
    a = A(1)
    @test a.a == "hello"
    @test fields(a).a == 1
    fields(a).a = 2
    @test fields(a).a == 2
end

@testset "indexes" begin 
    d = Dict(:x => 1, :y => 2)
    @test indexes(d).x == 1
    indexes(d).z = 3
    @test d[:z] == 3
end

@testset "joinprops" begin 
    j = joinprops(fields(A(1)), B(2))
    result = @with j a + b
    @test result == 3
    j.a = 2
    result2 = @with j a + b
    @test result2 == 4
    result3 = @with j a + b + 1 
    @test result3 == 5
end

end
