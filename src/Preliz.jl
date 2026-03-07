module Preliz
using PythonCall, Distributions
include("docboilerplate.jl")

export maxent

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
                pz = pyimport("preliz")
                prior = pz.$(Symbol(dist_name))()
                pz.maxent(prior, lower=lower, upper=upper, mass=mass)
                $(esc(DistType))(pyconvert(Vector{Float64}, prior.params)...)
            end
        end
    end
    Expr(:block, funcs...)
end

@gen_maxent Beta Normal LogNormal Gamma

function __init__()
    dist_map = [
        (Beta, "preliz.distributions.beta:Beta"),
        (Normal, "preliz.distributions.normal:Normal"),
        (LogNormal, "preliz.distributions.lognormal:LogNormal"),
        (Gamma, "preliz.distributions.gamma:Gamma")
    ]
    for (DistType, tname) in dist_map
        PythonCall.pyconvert_add_rule(
            tname,
            DistType,
            (T, x) -> begin
                params = pyconvert(Vector{Float64}, x.params)
                PythonCall.pyconvert_return(T(params...))
            end,
            PythonCall.PYCONVERT_PRIORITY_NORMAL
        )
    end
end

end # module Preliz
