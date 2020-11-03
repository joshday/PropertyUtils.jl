using PropertyUtils
using Test

#-----------------------------------------------------------------------------# setup
struct A 
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
end

@testset "indexes" begin 
     d = Dict(:x => 1, :y => 2)
     @test indexes(d).x == 1
end

@testset "joinprops" begin 
    result = @with joinprops(fields(A(1)), B(2)) a + b
    @test result == 3
end

end
