using Preliz, Distributions, PythonCall, Random, Test

Random.seed!(42)

pz = pyimport("preliz")
np = pyimport("numpy")
np.random.seed(42)

@testset "Convert Distributions" begin
    pydist = pz.Beta(2.0, 5.0)
    jldist = pyconvert(Beta, pydist)
end

@testset "Maxent" begin
    for i in 1:10
        min_val = rand() * 0.3
        max_val = max(1.0, min_val + rand() * 0.2)
        mass = 0.8 + rand() * 0.15

        julia_result = maxent(Beta, min_val, max_val, mass)
        julia_mean = mean(julia_result)

        b = pz.Beta()
        pz.maxent(b, min_val, max_val, mass)
        python_mean = pyconvert(Float64, b.mean())

        @test isapprox(julia_mean, python_mean, rtol=1e-6)
    end
end
