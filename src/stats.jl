using LsqFit: curve_fit
using Statistics: mean

export spincorrelation, buildmodel, ensembleaverage, fit, applyfit, average

function average(lattice::Lattice, dim)
    if dim == :x
        return map(sum, eachcol(lattice)) / size(lattice, 2)  # Note we sum over `y`!
    elseif dim == :y
        return map(sum, eachrow(lattice)) / size(lattice, 1)  # Note we sum over `x`!
    else
        throw(ArgumentError("argument `dim` must be either `x` or `y`!"))
    end
end

function spincorrelation(lattice::Lattice)
    Σx, Σy = average(lattice, :x), average(lattice, :y)
    return function (z)
        term1 = mean(Σx .* average(circshift(lattice, (-z, 0)), :x))
        term2 = mean(Σy .* average(circshift(lattice, (0, -z)), :y))
        return (term1 + term2) / 2
    end
end

function buildmodel(n)
    return function (z, params)
        a, b = float.(params)
        return @. a * (exp(-z / b) + exp(-(n - z) / b))
    end
end

function ensembleaverage(trace)
    m, n = size(trace[1])
    return map(1:n) do z  # ⟨Σ(z)⟩ is a function z
        mean(spincorrelation(lattice)(z) for lattice in trace)  # Time average
    end
end

function fit(trace, params)
    m, n = size(trace[1])
    model = buildmodel(n)
    𝐳 = 1:n
    𝚺̄z = ensembleaverage(trace)
    return curve_fit(model, 𝐳, 𝚺̄z, params)
end

function applyfit(lattice::Lattice, trace, params)
    m, n = size(lattice)
    a, b = fit(lattice, trace, params).param
    return z -> a * (exp.(-z ./ b) + exp.(-(n .- z) ./ b))
end
