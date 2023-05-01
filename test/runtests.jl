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
    result2 = @with (x=1,y=2) (x=y,y=x)
    @test result2 == (x=2,y=1)

    # @testset "@with @." begin
    #     data = [(x=1, y=2), (x=2, y=3)]
    #     result = @with data @. data[x > 1]

    # end
end

@testset "fields" begin
    a = A(1)
    @test a.a == "hello"
    @test_deprecated fields(a)
    @test Fields(a).a == 1
    Fields(a).a = 2
    @test Fields(a).a == 2
end

@testset "indexes" begin
    d = Dict(:x => 1, :y => 2)
    @test_deprecated indexes(d)
    @test Indexes(d).x == 1
    Indexes(d).z = 3
    @test d[:z] == 3
end

@testset "joinprops" begin
    @test_deprecated joinprops(Fields(A(1)), B(2))
    j = JoinProps(Fields(A(1)), B(2))
    result = @with j a + b
    @test result == 3
    j.a = 2
    result2 = @with j a + b
    @test result2 == 4
    result3 = @with j a + b + 1
    @test result3 == 5
end

end
