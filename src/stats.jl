using LsqFit: curve_fit
using Statistics: mean

export spatialcorrelation, buildmodel, fit, applyfit

function average(lattice::Lattice, dim)
    if dim == :x
        return sum(eachcol(lattice)) / size(lattice, 2)  # Note we sum over `y`!
    elseif dim == :y
        return sum(eachrow(lattice)) / size(lattice, 1)  # Note we sum over `x`!
    else
        throw(ArgumentError("argument `dim` must be either `x` or `y`!"))
    end
end

function spatialcorrelation(lattice::Lattice)
    Σx, Σy = average(lattice, :x), average(lattice, :y)
    return function (z)
        term1 = mean(Σx .* average(circshift(lattice, (-z, 0)), :x))
        term2 = mean(Σy .* average(circshift(lattice, (0, -z)), :y))
        return (term1 + term2) / 2
    end
end

function buildmodel(lattice::Lattice)
    m, n = size(lattice)
    return function (z, params)
        a, b = float.(params)
        return @. a * (exp(-z / b) + exp(-(n - z) / b))
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

function applyfit(lattice::Lattice, trace, params)
    m, n = size(lattice)
    a, b = fit(lattice, trace, params).param
    return z -> a * (exp.(-z ./ b) + exp.(-(n .- z) ./ b))
end
