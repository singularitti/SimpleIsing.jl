using LsqFit: curve_fit
using Statistics: mean

export Modeller, spincor, timeaverage_spincor, fit, applyfit, average

struct Modeller{T}
    n::T
end
Modeller(lattice::Lattice) = Modeller(size(lattice, 2))
function (m::Modeller)(z, params)
    a, b = float.(params)
    return @. a * (exp(-z / b) + exp(-(m.n - z) / b))
end

function average(lattice::Lattice, dim)
    if dim == :x
        return map(sum, eachcol(lattice)) / size(lattice, 2)  # Note we sum over `y`!
    elseif dim == :y
        return map(sum, eachrow(lattice)) / size(lattice, 1)  # Note we sum over `x`!
    else
        throw(ArgumentError("argument `dim` must be either `x` or `y`!"))
    end
end

function spincor(lattice::Lattice)
    Σx, Σy = average(lattice, :x), average(lattice, :y)
    return function (z)
        Σx₊z, Σy₊z = average(circshift(lattice, (0, -z)), :x),
        average(circshift(lattice, (-z, 0)), :y)
        term1 = mean(Σx .* Σx₊z)
        term2 = mean(Σy .* Σy₊z)
        return (term1 + term2) / 2
    end
end

timeaverage_spincor(trace) = z -> mean(spincor(lattice)(z) for lattice in trace)  # Time average

function fit(trace, params)
    m, n = size(trace[1])
    model = Modeller(n)
    𝐳 = 1:n
    𝚺̄z = ensembleaverage(trace)
    return curve_fit(model, 𝐳, 𝚺̄z, params)
end

function applyfit(trace, params)
    n = size(trace[1], 1)
    return Base.Fix2(Modeller(n), fit(trace, params).param)
end
