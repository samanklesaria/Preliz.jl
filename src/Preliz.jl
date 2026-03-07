module Preliz
using PythonCall, Distributions
include("docboilerplate.jl")
export maxent

pz = pyimport("preliz")

macro gen_maxent(DistTypes...)
    funcs = map(DistTypes) do DistType
        dist_name = string(DistType)
        quote
            """
            Find the maximum entropy $($dist_name) distribution that with `mass` in the interval defined by the
            `lower` and `upper` end-points.

            # Examples
            ```julia
            # Calculate the maxent $($dist_name) distribution with 90% of the mass between bounds
            maxent($($DistType), 1.0, 8.0, 0.9)
            ```

            # Notes
            This function uses the Python preliz package's maxent implementation internally.
            """
            function $(esc(:maxent))(::Type{$(esc(DistType))}, lower, upper, mass)
                prior = pz.$(Symbol(dist_name))()
                pz.maxent(prior, lower=lower, upper=upper, mass=mass)
                $(esc(DistType))(pyconvert(Vector{Float64}, prior.params)...)
            end
        end
    end
    Expr(:block, funcs...)
end

@gen_maxent Beta Normal LogNormal Gamma

function main()
    println(maxent(Beta, 0.01, 0.05, 0.9))
end

end # module Preliz
