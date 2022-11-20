using LsqFit: curve_fit
using Statistics: mean

export spatialcorrelation, buildmodel, fit

sigmax(lattice) = mean(lattice; dims=2)  # Note we sum over `y`!

sigmay(lattice) = mean(lattice; dims=1)  # Note we sum over `x`!

function spatialcorrelation(lattice::Lattice)
    Σx, Σy = sigmax(lattice), sigmay(lattice)  # Note we sum over `y` and `x`, respectively
    return function (z)
        term1 = mean(Σx .* sigmax(circshift(lattice, (-z, 0))))
        term2 = mean(Σy .* sigmay(circshift(lattice, (0, -z))))
        return (term1 + term2) / 2
    end
end

function buildmodel(lattice::Lattice)
    m, n = size(lattice)
    return function (z, p)
        a, b = float.(p)
        return a * (exp.(-z ./ b) + exp.(-(n .- z) ./ b))
    end
end

function ensembleaverage(trace)
    m, n = size(trace[1])
    return map(1:n) do z  # ⟨Σ(z)⟩ is a function z
        mean(spatialcorrelation(lattice)(z) for lattice in trace)  # Time average
    end
end

function fit(lattice::Lattice, trace, params)
    m, n = size(lattice)
    model = buildmodel(lattice)
    Σ̄z = ensembleaverage(trace)
    return curve_fit(model, 1:n, Σ̄z, params)
end
